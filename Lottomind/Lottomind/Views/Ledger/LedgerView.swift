// TASK-01 | LedgerView.swift | 2026-03-03

import SwiftUI
import SwiftData

struct LedgerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LedgerViewModel?
    @State private var showAddSheet = false
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                ledgerContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel = LedgerViewModel(modelContext: modelContext)
            viewModel?.loadRecords()
        }
        .sheet(isPresented: $showAddSheet) {
            RecordEntryView { record in
                viewModel?.addRecord(record)
            }
        }
    }
    
    private func ledgerContent(viewModel: LedgerViewModel) -> some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 汇总卡片
                    summaryCard(viewModel: viewModel)
                    
                    // 记录列表
                    recordsList(viewModel: viewModel)
                }
                .padding()
            }
            .background(LMColor.pageBg)
            .navigationTitle("我的账本")
            
            // 添加按钮
            addButton
        }
    }
    
    private func summaryCard(viewModel: LedgerViewModel) -> some View {
        SectionCard {
            HStack {
                SummaryItem(title: "总投入", value: viewModel.totalCost, color: LMColor.textPrimary)
                Divider()
                SummaryItem(title: "总回报", value: viewModel.totalPrize, color: LMColor.textPrimary)
                Divider()
                SummaryItem(
                    title: "盈亏",
                    value: viewModel.profit,
                    color: viewModel.profit >= 0 ? LMColor.success : LMColor.error
                )
            }
        }
    }
    
    private func recordsList(viewModel: LedgerViewModel) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.records) { record in
                RecordRow(record: record)
            }
        }
    }
    
    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(LMColor.brand)
                        .clipShape(Circle())
                        .shadow(color: LMColor.textPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

struct SummaryItem: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(formattedValue)
                .font(LMFont.h2)
                .foregroundStyle(color)
            Text(title)
                .font(LMFont.caption)
                .foregroundStyle(LMColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var formattedValue: String {
        if value >= 10000 {
            return String(format: "¥%.1f万", Double(value) / 10000)
        }
        return "¥\(value)"
    }
}

struct RecordRow: View {
    let record: UserRecord
    
    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(record.type.displayName) 第\(record.period)期")
                        .font(LMFont.callout)
                    Spacer()
                    Text(record.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(LMFont.caption)
                        .foregroundStyle(LMColor.textSecondary)
                }
                
                // 号码
                HStack(spacing: 4) {
                    ForEach(record.frontBalls, id: \.self) { number in
                        LottoBall(number: number, type: .red, size: .small)
                    }
                    LottoBall(number: record.backBalls.first ?? 0, type: .blue, size: .small)
                }
                
                // 状态
                HStack {
                    Text("投入 ¥\(record.cost)")
                    if let prize = record.prize {
                        Text("中奖 ¥\(prize)")
                            .foregroundStyle(prize > 0 ? LMColor.success : LMColor.textSecondary)
                    } else {
                        Text("待开奖 ⏳")
                            .foregroundStyle(LMColor.warning)
                    }
                }
                .font(LMFont.caption)
            }
        }
    }
}

#Preview {
    LedgerView()
}
