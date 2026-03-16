// TASK-01 | DashboardView.swift | 2026-03-03

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: DashboardViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                dashboardContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DashboardViewModel(modelContext: modelContext)
                viewModel?.loadData()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Application entered foreground
                // Removed aggressive silent fetch requirement per user feedback
            }
        }
    }
    
    private func dashboardContent(viewModel: DashboardViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if case .syncFailed(let message) = viewModel.state {
                    syncFailedBanner(message: message, viewModel: viewModel)
                }
                
                if viewModel.state == .empty || (viewModel.state == .loading && viewModel.latestDraw == nil && viewModel.latestRecommendations.isEmpty) {
                    emptyStateCard(viewModel: viewModel)
                } else {
                    jackpotCard(viewModel: viewModel)
                    recommendationsSection(viewModel: viewModel)
                    latestDrawSection(viewModel: viewModel)
                }
                
                DisclaimerBanner()
            }
            .padding()
        }
        .background(LMColor.pageBg)
        .navigationTitle("LottoMind")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: 打开通知列表
                }) {
                    Image(systemName: "bell")
                        .foregroundStyle(LMColor.textPrimaryAdaptive)
                }
            }
        }
        .refreshable {
            await viewModel.refreshData()
        }
        .overlay {
            if viewModel.state == .loading {
                ProgressView("正在同步数据中...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }
        }
    }
    
    private func syncFailedBanner(message: String, viewModel: DashboardViewModel) -> some View {
        Button(action: {
            Task { await viewModel.refreshData() }
        }) {
            HStack {
                Text("数据更新失败 · 点击重试")
                    .font(LMFont.callout)
                Spacer()
                Image(systemName: "arrow.clockwise")
            }
            .padding()
            .background(LMColor.error.opacity(0.1))
            .foregroundStyle(LMColor.error)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LMColor.error.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func emptyStateCard(viewModel: DashboardViewModel) -> some View {
        SectionCard {
            VStack(spacing: 16) {
                Image(systemName: "cloud.arrow.down")
                    .font(.system(size: 48))
                    .foregroundStyle(LMColor.brand)
                    .padding(.top, 20)
                
                Text(viewModel.state == .loading ? "同步中..." : "暂无分析数据")
                    .font(LMFont.h2)
                    .foregroundStyle(LMColor.textPrimary)
                
                Text("初次数据分析与推演模型构建需进行大规模历史数据同步。\n此过程将花费1-2分钟左右，请保持网络畅通并耐心等待。")
                    .font(LMFont.footnote)
                    .foregroundStyle(LMColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if viewModel.state == .loading {
                    ProgressView()
                        .padding()
                } else {
                    Button(action: {
                        Task {
                            await viewModel.refreshData()
                        }
                    }) {
                        Text("开始极客同步")
                            .font(LMFont.body.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 32)
                            .background(LMColor.brand)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.easeInOut, value: viewModel.state)
        }
    }
    
    private func jackpotCard(viewModel: DashboardViewModel) -> some View {
        if let draw = viewModel.latestDraw {
            return AnyView(JackpotGauge(amount: draw.jackpot, change: nil, pressureIndex: viewModel.pressureIndex))
        } else {
            return AnyView(JackpotGauge(amount: 0, change: nil, pressureIndex: 1.0))
        }
    }
    
    private func recommendationsSection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日推荐")
                .font(LMFont.h2)
            
            if viewModel.latestRecommendations.isEmpty {
                SectionCard {
                    Text("暂无推荐数据")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                        .foregroundStyle(LMColor.textSecondary)
                }
            } else {
                TabView {
                    ForEach(viewModel.latestRecommendations, id: \.id) { rec in
                        RecommendationCard(recommendation: rec)
                            .padding(.bottom, 40) // 为指示器留出空间
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 220)
            }
        }
    }
    
    private func latestDrawSection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最新开奖")
                .font(LMFont.h2)
            
            if let draw = viewModel.latestDraw {
                LatestDrawView(draw: draw)
            } else {
                SectionCard {
                    Text("暂无开奖数据")
                        .foregroundStyle(LMColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
