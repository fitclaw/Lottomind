// TASK-01 | AnalysisViewModel.swift | 2026-03-03

import Foundation
import SwiftData

@Observable
class AnalysisViewModel {
    private let modelContext: ModelContext
    
    var selectedPeriod: String?
    var recommendation: Recommendation?
    var isAnalyzing = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadAnalysis(for period: String? = nil) {
        if let period = period {
            selectedPeriod = period
            let descriptor = FetchDescriptor<Recommendation>(
                predicate: #Predicate { $0.period == period }
            )
            recommendation = try? modelContext.fetch(descriptor).first
        } else {
            let descriptor = FetchDescriptor<Recommendation>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            recommendation = try? modelContext.fetch(descriptor).first
            selectedPeriod = recommendation?.period
        }
    }
    
    func reanalyze() async {
        isAnalyzing = true
        
        // TODO: 重新运行算法
        isAnalyzing = false
    }
}
