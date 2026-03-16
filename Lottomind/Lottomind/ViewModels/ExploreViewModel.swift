// TASK-01 | ExploreViewModel.swift | 2026-03-03

import Foundation
import SwiftData

@Observable
class ExploreViewModel {
    private let modelContext: ModelContext
    
    var selectedTimeRange: TimeRange = .thirty
    var heatmapData: [Int: Double] = [:]
    var hotBalls: [Int] = []
    var coldBalls: [Int] = []
    var warmingBalls: [Int] = []
    
    enum TimeRange: Int, CaseIterable {
        case thirty = 30
        case sixty = 60
        case ninety = 90
        case all = 0
        
        var displayName: String {
            switch self {
            case .thirty: return "近30期"
            case .sixty: return "近60期"
            case .ninety: return "近90期"
            case .all: return "全部"
            }
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() {
        let limit = selectedTimeRange.rawValue
        let descriptor = FetchDescriptor<LotteryDraw>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            let allDraws = try modelContext.fetch(descriptor)
            let draws = limit > 0 ? Array(allDraws.prefix(limit)) : allDraws
            
            var frequencies: [Int: Double] = [:]
            for i in 1...33 { frequencies[i] = 0 }
            
            for draw in draws {
                for ball in draw.frontBalls {
                    frequencies[ball, default: 0] += 1
                }
            }
            
            let maxFreq = frequencies.values.max() ?? 1.0
            
            // Generate Heatmap data (normalized)
            for (ball, freq) in frequencies {
                heatmapData[ball] = maxFreq > 0 ? freq / maxFreq : 0.0
            }
            
            // Rank Hot and Cold
            let sortedBalls = frequencies.keys.sorted {
                frequencies[$0, default: 0] > frequencies[$1, default: 0]
            }
            hotBalls = Array(sortedBalls.prefix(5))
            coldBalls = Array(sortedBalls.suffix(5).reversed())
            
            // Simple logic for Warming Balls (could be derived from recent vs older comparison)
            if allDraws.count > limit && limit > 0 {
                let olderDraws = Array(allDraws.dropFirst(limit).prefix(limit))
                var olderFrequencies: [Int: Double] = [:]
                for draw in olderDraws {
                    for ball in draw.frontBalls { olderFrequencies[ball, default: 0] += 1 }
                }
                
                let diffs = frequencies.map { (ball, freq) in
                    (ball, freq - (olderFrequencies[ball] ?? 0))
                }.sorted { $0.1 > $1.1 }
                
                warmingBalls = diffs.prefix(5).map { $0.0 }
            } else {
                // Not enough data for calculating warming trend
                warmingBalls = Array(sortedBalls.shuffled().prefix(5))
            }
            
        } catch {
            print("Failed to load historical draws for ExploreView.")
        }
    }
}
