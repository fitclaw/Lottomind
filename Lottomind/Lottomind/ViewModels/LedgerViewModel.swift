// TASK-01 | LedgerViewModel.swift | 2026-03-03

import Foundation
import SwiftData

@Observable
class LedgerViewModel {
    private let modelContext: ModelContext
    
    var records: [UserRecord] = []
    var totalCost: Int = 0
    var totalPrize: Int = 0
    var profit: Int { totalPrize - totalCost }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadRecords() {
        let descriptor = FetchDescriptor<UserRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        records = (try? modelContext.fetch(descriptor)) ?? []
        calculateTotals()
    }
    
    func addRecord(_ record: UserRecord) {
        modelContext.insert(record)
        loadRecords()
    }
    
    func deleteRecord(_ record: UserRecord) {
        modelContext.delete(record)
        loadRecords()
    }
    
    func checkResults() {
        let drawDescriptor = FetchDescriptor<LotteryDraw>()
        guard let draws = try? modelContext.fetch(drawDescriptor) else { return }
        
        let drawDict = Dictionary(grouping: draws, by: { "\($0.type.rawValue)-\($0.period)" })
            .compactMapValues { $0.first }
        
        var hasChanges = false
        
        for record in records where record.prize == nil {
            let key = "\(record.type.rawValue)-\(record.period)"
            if let draw = drawDict[key] {
                let redHits = Set(record.frontBalls).intersection(Set(draw.frontBalls)).count
                let blueHits = Set(record.backBalls).intersection(Set(draw.backBalls)).count
                
                var prizeAmount = 0
                if record.type == .ssq {
                    if redHits == 6 && blueHits == 1 { prizeAmount = 5_000_000 }
                    else if redHits == 6 && blueHits == 0 { prizeAmount = 100_000 }
                    else if redHits == 5 && blueHits == 1 { prizeAmount = 3000 }
                    else if redHits == 5 && blueHits == 0 || redHits == 4 && blueHits == 1 { prizeAmount = 200 }
                    else if redHits == 4 && blueHits == 0 || redHits == 3 && blueHits == 1 { prizeAmount = 10 }
                    else if blueHits == 1 { prizeAmount = 5 } 
                } else {
                    if redHits == record.frontBalls.count { prizeAmount = 1000 }
                }
                
                record.prize = prizeAmount
                record.isChecked = true
                hasChanges = true
            }
        }
        
        if hasChanges {
            try? modelContext.save()
            loadRecords()
        }
    }
    
    private func calculateTotals() {
        totalCost = records.map(\.cost).reduce(0, +)
        totalPrize = records.compactMap(\.prize).reduce(0, +)
    }
}
