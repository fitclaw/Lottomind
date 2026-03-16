// TASK-01 | ExploreView.swift | 2026-03-03

import SwiftUI
import SwiftData

struct ExploreView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ExploreViewModel?
    @State private var selectedTimeRange: ExploreViewModel.TimeRange = .thirty
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                exploreContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel = ExploreViewModel(modelContext: modelContext)
            viewModel?.loadData()
        }
    }
    
    private func exploreContent(viewModel: ExploreViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // 时间范围选择
                Picker("时间范围", selection: $selectedTimeRange) {
                    ForEach(ExploreViewModel.TimeRange.allCases, id: \.self) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedTimeRange) { _, newValue in
                    viewModel.selectedTimeRange = newValue
                    viewModel.loadData()
                }
                
                // 热力图
                HeatmapView(data: viewModel.heatmapData)
                
                // 冷热排行
                ColdHotRanking(
                    hotBalls: viewModel.hotBalls,
                    coldBalls: viewModel.coldBalls,
                    warmingBalls: viewModel.warmingBalls
                )
            }
            .padding()
        }
        .background(LMColor.pageBg)
        .navigationTitle("号码探索")
    }
}

#Preview {
    ExploreView()
}
