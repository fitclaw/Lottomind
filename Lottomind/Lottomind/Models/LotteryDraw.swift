// TASK-01 | LotteryDraw.swift | 2026-03-03

import Foundation
import SwiftData

@Model
class LotteryDraw {
    @Attribute(.unique) var id: UUID
    var type: LotteryType
    var period: String
    var date: Date
    var frontBalls: [Int]
    var backBalls: [Int]
    var jackpot: Int
    var sales: Int?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        type: LotteryType,
        period: String,
        date: Date,
        frontBalls: [Int],
        backBalls: [Int],
        jackpot: Int,
        sales: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.period = period
        self.date = date
        self.frontBalls = frontBalls
        self.backBalls = backBalls
        self.jackpot = jackpot
        self.sales = sales
        self.createdAt = createdAt
    }
}
