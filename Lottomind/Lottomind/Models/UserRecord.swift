// TASK-01 | UserRecord.swift | 2026-03-03

import Foundation
import SwiftData

@Model
class UserRecord {
    @Attribute(.unique) var id: UUID
    var type: LotteryType
    var period: String
    var frontBalls: [Int]
    var backBalls: [Int]
    var cost: Int
    var prize: Int?
    var isChecked: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        type: LotteryType,
        period: String,
        frontBalls: [Int],
        backBalls: [Int],
        cost: Int,
        prize: Int? = nil,
        isChecked: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.period = period
        self.frontBalls = frontBalls
        self.backBalls = backBalls
        self.cost = cost
        self.prize = prize
        self.isChecked = isChecked
        self.createdAt = createdAt
    }
}
