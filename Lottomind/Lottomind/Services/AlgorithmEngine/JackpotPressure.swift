// TASK-08 | JackpotPressure.swift | 2026-03-04
// AI-B: M2 奖池压力算法 - 根据奖池水位判断压力模式

import Foundation

/// 压力模式
enum PressureMode {
    case hard    // 难中型：奖池高位，需控制中奖人数
    case normal  // 常规型：奖池正常
    case easy    // 简单型：奖池低位，需吸引投注
}

/// 压力结果
struct PressureResult {
    /// 压力指数 (currentJackpot / avgJackpot)
    let index: Double
    /// 压力模式
    let mode: PressureMode
}

/// M2 奖池压力算法
/// 分析奖池水位对号码组合类型的影响
struct JackpotPressure {
    
    /// 计算奖池压力
    /// - Parameters:
    ///   - draws: 历史开奖记录（按日期降序，第一条为最新）
    ///   - type: 彩种类型
    /// - Returns: 压力结果
    func calculate(draws: [LotteryDraw], type: LotteryType) -> PressureResult {
        // 奖池为 0 时优雅降级为 normal
        guard !draws.isEmpty else {
            return PressureResult(index: 1.0, mode: .normal)
        }
        
        // 计算历史奖池均值（排除当前期）
        let historicalDraws = draws.dropFirst()
        let avgJackpot: Double
        
        if historicalDraws.isEmpty {
            // 只有一期数据时，用当期作为均值
            avgJackpot = Double(draws.first?.jackpot ?? 0)
        } else {
            let totalJackpot = historicalDraws.map { Double($0.jackpot) }.reduce(0, +)
            avgJackpot = totalJackpot / Double(historicalDraws.count)
        }
        
        let currentJackpot = Double(draws.first?.jackpot ?? 0)
        
        // 奖池为 0 时降级为 normal
        guard currentJackpot > 0, avgJackpot > 0 else {
            return PressureResult(index: 1.0, mode: .normal)
        }
        
        // 压力指数 = 当前奖池 / 历史均值
        let pressureIndex = currentJackpot / avgJackpot
        
        // 模式判定
        // - pressureIndex > 1.5 → .hard (难中型权重 +30%)
        // - pressureIndex 0.8...1.5 → .normal
        // - pressureIndex < 0.8 → .easy (常规型权重 +20%)
        let mode: PressureMode
        if pressureIndex > 1.5 {
            mode = .hard
        } else if pressureIndex < 0.8 {
            mode = .easy
        } else {
            mode = .normal
        }
        
        return PressureResult(index: pressureIndex, mode: mode)
    }
    
    /// 获取模式描述文字
    func modeDescription(_ mode: PressureMode) -> String {
        switch mode {
        case .hard:
            return "奖池处于高位，模型倾向离散型号码组合，降低与大众重合概率"
        case .normal:
            return "奖池处于正常区间，采用均衡策略"
        case .easy:
            return "奖池处于低位，适当放宽组合约束，允许常见号码模式"
        }
    }
    
    /// 根据压力模式调整组合权重
    /// - Returns: 组合结构特征的权重调整系数
    func comboWeights(for mode: PressureMode) -> [String: Double] {
        switch mode {
        case .hard:
            // 离散型组合：间距大、奇偶均衡、跨区间分布
            return [
                "span": 1.3,        // 号码跨度权重 +30%
                "oddEvenBalance": 1.3,
                "zoneDistribution": 1.3
            ]
        case .easy:
            // 连续型组合：允许连号、集中区间
            return [
                "span": 1.0,
                "oddEvenBalance": 1.0,
                "zoneDistribution": 1.0,
                "consecutive": 1.2  // 连号权重 +20%
            ]
        case .normal:
            return [
                "span": 1.0,
                "oddEvenBalance": 1.0,
                "zoneDistribution": 1.0
            ]
        }
    }
}

// MARK: - 单元测试用例

#if DEBUG
extension JackpotPressure {
    /// 测试三种模式的判定
    func testPressureModes() -> [Bool] {
        let testCases: [(jackpot: Int, historical: [Int], expected: PressureMode)] = [
            (300_000_000, [100_000_000, 100_000_000], .hard),  // 3x > 1.5
            (100_000_000, [100_000_000, 100_000_000], .normal), // 1.0
            (50_000_000, [100_000_000, 100_000_000], .easy),   // 0.5 < 0.8
        ]
        
        return testCases.map { test in
            let draw = LotteryDraw(
                type: .ssq,
                period: "2026031",
                date: Date(),
                frontBalls: [1, 2, 3, 4, 5, 6],
                backBalls: [1],
                jackpot: test.jackpot
            )
            let historical = test.historical.map { jackpot in
                LotteryDraw(
                    type: .ssq,
                    period: "2026030",
                    date: Date(),
                    frontBalls: [1, 2, 3, 4, 5, 6],
                    backBalls: [1],
                    jackpot: jackpot
                )
            }
            let result = calculate(draws: [draw] + historical, type: .ssq)
            return result.mode == test.expected
        }
    }
}
#endif
