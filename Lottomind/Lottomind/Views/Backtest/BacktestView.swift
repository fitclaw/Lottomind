// TASK-01 | BacktestView.swift | 2026-03-03

import SwiftUI
import SwiftData

struct BacktestView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: BacktestViewModel?
    @State private var selectedRange = 50
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                backtestContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel = BacktestViewModel(modelContext: modelContext)
            viewModel?.loadBacktestData()
        }
    }
    
    private func backtestContent(viewModel: BacktestViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // 时间范围选择
                Picker("时间范围", selection: $selectedRange) {
                    Text("近20期").tag(20)
                    Text("近50期").tag(50)
                    Text("近100期").tag(100)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedRange) { _, newValue in
                    viewModel.selectedRange = newValue
                    viewModel.loadBacktestData()
                }
                
                // 核心指标
                metricsRow(viewModel: viewModel)
                
                // 准确率趋势图
                AccuracyChart(data: viewModel.historyData.reversed().map {
                    AccuracyPoint(period: $0.period, hits: $0.hitCount)
                }, averageHits: viewModel.averageHits)
                    .frame(height: 200)
                
                // 逐期明细
                historyList(viewModel: viewModel)
            }
            .padding()
        }
        .background(LMColor.pageBg)
        .navigationTitle("历史回测")
    }
    
    private func metricsRow(viewModel: BacktestViewModel) -> some View {
        HStack(spacing: 12) {
            MetricCard(title: "命中率", value: "\(Int(viewModel.hitRate * 100))%")
            MetricCard(title: "平均命中", value: String(format: "%.1f个", viewModel.averageHits))
            MetricCard(title: "最佳单期", value: "\(viewModel.bestSingle)个")
        }
    }
    
    private func historyList(viewModel: BacktestViewModel) -> some View {
        SectionCard(title: "逐期明细") {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.historyData.prefix(10), id: \.period) { record in
                    HistoryRow(record: record)
                }
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        SectionCard {
            VStack(spacing: 4) {
                Text(value)
                    .font(LMFont.h1)
                    .foregroundStyle(LMColor.brand)
                Text(title)
                    .font(LMFont.caption)
                    .foregroundStyle(LMColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct HistoryRow: View {
    let record: BacktestViewModel.BacktestRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("第\(record.period)期")
                    .font(LMFont.callout)
                Text(record.draw.date.formatted(date: .abbreviated, time: .omitted))
                    .font(LMFont.caption)
                    .foregroundStyle(LMColor.textSecondary)
            }
            
            Spacer()
            
            // 推荐号码
            HStack(spacing: 4) {
                ForEach(record.recommendation.frontBalls.prefix(3), id: \.self) { _ in
                    Circle()
                        .fill(LMColor.redBall)
                        .frame(width: 8, height: 8)
                }
                Text("...")
            }
            
            Spacer()
            
            // 命中数
            Text("命中 \(record.hitCount)/6")
                .font(LMFont.callout)
                .foregroundStyle(record.hitCount >= 3 ? LMColor.success : LMColor.textSecondary)
        }
    }
}

#Preview {
    BacktestView()
}
