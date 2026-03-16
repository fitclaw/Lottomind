// TASK-01 | Recommendation.swift | 2026-03-03

import Foundation
import SwiftData

@Model
class Recommendation {
    @Attribute(.unique) var id: UUID
    var type: LotteryType
    var period: String
    var frontBalls: [Int]
    var backBalls: [Int]
    var confidence: Double
    var moduleScores: [String: Double]
    var explanation: String
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        type: LotteryType,
        period: String,
        frontBalls: [Int],
        backBalls: [Int],
        confidence: Double,
        moduleScores: [String: Double] = [:],
        explanation: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.period = period
        self.frontBalls = frontBalls
        self.backBalls = backBalls
        self.confidence = confidence
        self.moduleScores = moduleScores
        self.explanation = explanation
        self.createdAt = createdAt
    }
}
