// TASK-01 | BacktestViewModel.swift | 2026-03-03

import Foundation
import SwiftData

@Observable
class BacktestViewModel {
    private let modelContext: ModelContext
    
    var selectedRange: Int = 50
    var hitRate: Double = 0
    var averageHits: Double = 0
    var bestSingle: Int = 0
    var historyData: [BacktestRecord] = []
    
    struct BacktestRecord {
        let period: String
        let recommendation: Recommendation
        let draw: LotteryDraw
        let hitCount: Int
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadBacktestData() {
        do {
            var descriptor = FetchDescriptor<LotteryDraw>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            descriptor.fetchLimit = selectedRange
            let targetDraws = try modelContext.fetch(descriptor)
            
            let recDescriptor = FetchDescriptor<Recommendation>()
            let allRecs = try modelContext.fetch(recDescriptor)
            
            var recMap: [String: Recommendation] = [:]
            for rec in allRecs { recMap[rec.period] = rec }
            
            var records: [BacktestRecord] = []
            for draw in targetDraws {
                guard let rec = recMap[draw.period] else { continue }
                let hitCount = Set(draw.frontBalls).intersection(Set(rec.frontBalls)).count
                records.append(BacktestRecord(period: draw.period, recommendation: rec, draw: draw, hitCount: hitCount))
            }
            
            self.historyData = records
            
            guard !records.isEmpty else {
                hitRate = 0; averageHits = 0; bestSingle = 0
                return
            }
            
            let totalHits = records.reduce(0) { $0 + $1.hitCount }
            let hitGe3Count = records.filter { $0.hitCount >= 3 }.count
            self.hitRate = Double(hitGe3Count) / Double(records.count)
            self.averageHits = Double(totalHits) / Double(records.count)
            self.bestSingle = records.map { $0.hitCount }.max() ?? 0
        } catch {
            print("Failed to load backtest data:", error)
        }
    }
}
