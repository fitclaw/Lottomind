// TASK-04 | MockData.swift | 2026-03-04
import Foundation
import SwiftData

/// 专供 Preview 和 UI 开发测试使用的 Mock 数据
@MainActor
struct MockData {
    
    // MARK: - 模拟开奖数据 (LotteryDraw)
    static let draws: [LotteryDraw] = [
        LotteryDraw(
            id: UUID(),
            type: .ssq,
            period: "2026031",
            date: Date(),
            frontBalls: [2, 9, 14, 22, 27, 33],
            backBalls: [8],
            jackpot: 382_000_000,
            sales: 420_000_000,
            createdAt: Date()
        ),
        LotteryDraw(
            id: UUID(),
            type: .ssq,
            period: "2026030",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            frontBalls: [5, 11, 16, 21, 26, 30],
            backBalls: [12],
            jackpot: 380_000_000,
            sales: 390_000_000,
            createdAt: Date()
        )
    ]
    
    // MARK: - 模拟推荐组合 (Recommendation)
    static let recommendations: [Recommendation] = [
        Recommendation(
            id: UUID(),
            type: .ssq,
            period: "2026032",
            frontBalls: [3, 8, 15, 23, 28, 31],
            backBalls: [7],
            confidence: 0.85,
            moduleScores: [
                "M1": 90.0,
                "M2": 85.0,
                "M3": 80.0,
                "M4": 82.0,
                "M5": 88.0
            ],
            explanation: "本期奖池水位偏高（PressureIndex 1.62），模型倾向离散型号码组合。热号回避模块评分极高，推荐号码完美避开大众偏好。",
            createdAt: Date()
        ),
        Recommendation(
            id: UUID(),
            type: .ssq,
            period: "2026032",
            frontBalls: [1, 12, 17, 24, 29, 32],
            backBalls: [14],
            confidence: 0.72,
            moduleScores: [
                "M1": 70.0,
                "M2": 75.0,
                "M3": 78.0,
                "M4": 65.0,
                "M5": 72.0
            ],
            explanation: "组合结构均衡，序列衰减模块检测到 12 和 29 有回暖趋势。适合防守型投注。",
            createdAt: Date()
        )
    ]
    
    // MARK: - 模拟购彩记录 (UserRecord)
    static let userRecords: [UserRecord] = [
        UserRecord(
            id: UUID(),
            type: .ssq,
            period: "2026031",
            frontBalls: [2, 9, 14, 22, 27, 33],
            backBalls: [8], // 完全命中
            cost: 2,
            prize: 5_000_000,
            isChecked: true,
            createdAt: Date()
        ),
        UserRecord(
            id: UUID(),
            type: .ssq,
            period: "2026031",
            frontBalls: [1, 2, 3, 4, 5, 6],
            backBalls: [7], // 未命中
            cost: 2,
            prize: 0,
            isChecked: true,
            createdAt: Date()
        ),
        UserRecord(
            id: UUID(),
            type: .ssq,
            period: "2026032",
            frontBalls: [4, 15, 19, 26, 28, 31],
            backBalls: [10], // 待开奖
            cost: 10,
            prize: nil,
            isChecked: false,
            createdAt: Date()
        )
    ]
    
    // MARK: - 辅助方法：给 Preview 注入的 ModelContainer
    static var previewContainer: ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: LotteryDraw.self, Recommendation.self, UserRecord.self, configurations: config)
            
            // 写入 mock 数据
            for draw in draws { container.mainContext.insert(draw) }
            for rec in recommendations { container.mainContext.insert(rec) }
            for rec in userRecords { container.mainContext.insert(rec) }
            
            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error.localizedDescription)")
        }
    }
}
