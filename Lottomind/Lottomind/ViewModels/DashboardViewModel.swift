// TASK-01 | DashboardViewModel.swift | 2026-03-03

import Foundation
import SwiftData

enum DashboardState: Equatable {
    case normal
    case empty
    case loading
    case syncFailed(message: String)
}

@Observable
class DashboardViewModel {
    private let modelContext: ModelContext
    
    var state: DashboardState = .loading
    var latestRecommendations: [Recommendation] = []
    var latestDraw: LotteryDraw?
    var pressureIndex: Double = 1.0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() {
        // 加载最新推荐，取最近同一期的所有推荐（通常是前5条）
        let recDescriptor = FetchDescriptor<Recommendation>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        if let recs = try? modelContext.fetch(recDescriptor), let firstRec = recs.first {
            latestRecommendations = recs.filter { $0.period == firstRec.period }
        } else {
            latestRecommendations = []
        }
        
        // 加载最新开奖
        let drawDescriptor = FetchDescriptor<LotteryDraw>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        latestDraw = try? modelContext.fetch(drawDescriptor).first
        
        // 计算奖池压力指数
        calculatePressureIndex()
        
        // 只有在非 loading/syncFailed 状态下才重置状态，避免覆盖正在发生的状态
        if state != .loading, case .syncFailed = state {
            // 保留 syncFailed 状态
        } else if latestRecommendations.isEmpty && latestDraw == nil {
            state = .empty
        } else {
            state = .normal
        }
    }
    
    func refreshData() async {
        state = .loading
        
        do {
            let drawsDescriptor = FetchDescriptor<LotteryDraw>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            let existingDraws = (try? modelContext.fetch(drawsDescriptor)) ?? []
            
            if existingDraws.isEmpty {
                // 初次启动：进行大规模历史数据拉取（消耗较高，需 1-2 分钟）
                let history = try await AIDataFetcher.shared.syncHistoricalData(type: .ssq)
                for d in history {
                    modelContext.insert(d)
                }
            } else {
                // 日常刷新：仅拉取最新一期快照（极速）
                let draw = try await AIDataFetcher.shared.fetchLatestDraw(type: .ssq)
                modelContext.insert(draw)
            }
            
            // Trigger 算法引擎基于最新本地全库重算
            let updatedDraws = (try? modelContext.fetch(drawsDescriptor)) ?? []
            let recommendations = await ReverseEngine.shared.analyze(type: .ssq, draws: updatedDraws)
            for r in recommendations {
                modelContext.insert(r)
            }
            try? modelContext.save()
            
            // 更新本对象状态
            loadData()
            state = .normal
        } catch {
            state = .syncFailed(message: error.localizedDescription)
        }
    }
    
    private func calculatePressureIndex() {
        let drawDescriptor = FetchDescriptor<LotteryDraw>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let draws = (try? modelContext.fetch(drawDescriptor)) ?? []
        pressureIndex = JackpotPressure().calculate(draws: draws, type: .ssq).index
    }
}
