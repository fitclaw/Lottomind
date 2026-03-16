// TASK-01 | AnalysisView.swift | 2026-03-03

import SwiftUI
import SwiftData

struct AnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AnalysisViewModel?
    @State private var selectedType: LotteryType = .ssq
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                analysisContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AnalysisViewModel(modelContext: modelContext)
                viewModel?.loadAnalysis()
            }
        }
    }
    
    private func analysisContent(viewModel: AnalysisViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // 雷达图与综合置信度
                if let rec = viewModel.recommendation {
                    SectionCard(title: "综合分析") {
                        VStack(spacing: 20) {
                            RadarChartView(moduleScores: rec.moduleScores)
                                .frame(height: 280)
                            
                            VStack(spacing: 8) {
                                Text("推荐置信度")
                                    .font(LMFont.callout)
                                    .foregroundStyle(LMColor.textSecondary)
                                ConfidenceBar(value: rec.confidence, style: .full)
                            }
                        }
                    }
                    
                    // 模块列表
                    VStack(spacing: 12) {
                        ModuleDetailCard(
                            title: "热号回避 (M1)",
                            icon: "flame",
                            score: Int((rec.moduleScores["M1"] ?? 0) * 100),
                            description: "模拟大众选号偏好，计算每个号码的被追捧程度。得分越高意味着该组号码越不受大众追捧，从反向思维角度更值得关注。"
                        )
                        ModuleDetailCard(
                            title: "奖池压力 (M2)",
                            icon: "chart.bar",
                            score: Int((rec.moduleScores["M2"] ?? 0) * 100),
                            description: "根据奖池水位调整号码组合策略。奖池越高，越倾向于离散型的困难组合。"
                        )
                        ModuleDetailCard(
                            title: "序列衰减 (M3)",
                            icon: "waveform.path.ecg",
                            score: Int((rec.moduleScores["M3"] ?? 0) * 100),
                            description: "基于号码遗漏期数计算衰减系数，发现即将回暖的冷门号码。"
                        )
                        ModuleDetailCard(
                            title: "组合结构 (M4)",
                            icon: "square.grid.3x3",
                            score: Int((rec.moduleScores["M4"] ?? 0) * 100),
                            description: "评估号码组合的奇偶比、大小比等结构特征，剔除极度不平衡的组合。"
                        )
                        ModuleDetailCard(
                            title: "反常突变 (M5)",
                            icon: "exclamationmark.triangle",
                            score: Int((rec.moduleScores["M5"] ?? 0) * 100),
                            description: "检测号码出现频率的突变信号，识别冷热交替的拐点。"
                        )
                    }
                } else {
                    SectionCard {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass.circle")
                                .font(.largeTitle)
                                .foregroundStyle(LMColor.textPlaceholder)
                            Text("暂无分析数据，请前往首页刷新拉取")
                                .font(LMFont.callout)
                                .foregroundStyle(LMColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                
                DisclaimerBanner()
            }
            .padding()
        }
        .background(LMColor.pageBg)
        .navigationTitle("智能分析")
    }
}

#Preview {
    AnalysisView()
}
