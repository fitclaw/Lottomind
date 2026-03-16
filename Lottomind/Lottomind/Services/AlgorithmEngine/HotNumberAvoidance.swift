// TASK-07 | HotNumberAvoidance.swift | 2026-03-04
// AI-B: M1 热号回避算法 - 模拟大众选号偏好，计算回避分数

import Foundation
import Accelerate

/// M1 热号回避算法
/// 输入: 历史开奖数据
/// 输出: 每个号码的回避分数 (0...1, 越高越应回避)
actor HotNumberAvoidance {
    
    /// 计算回避分数
    /// - Parameters:
    ///   - draws: 历史开奖记录（按日期降序排列）
    ///   - type: 彩种类型
    /// - Returns: 号码到回避分数的映射
    func calculate(draws: [LotteryDraw], type: LotteryType) -> [Int: Double] {
        let range = type.frontRange
        var scores: [Int: Double] = [:]
        
        // 1. Popularity Index (大众偏好指数)
        let popularityScores = calculatePopularityIndex(range: range)
        
        // 2. Recent Frequency (近期开出频率)
        let freqScores = calculateRecentFrequency(draws: draws, range: range)
        
        // 3. Birthday Bias (生日号码惩罚)
        let birthdayBias = calculateBirthdayBias(range: range)
        
        // 4. 融合: avoidanceScore = 0.4 × popularity + 0.4 × recentFreq + 0.2 × birthdayBias
        for number in range {
            let popularity = popularityScores[number, default: 0]
            let recentFreq = freqScores[number, default: 0]
            let bias = birthdayBias[number, default: 0]
            scores[number] = 0.4 * popularity + 0.4 * recentFreq + 0.2 * bias
        }
        
        return scores
    }
    
    // MARK: - 1. 大众偏好指数
    
    /// 计算大众偏好指数
    /// 模拟人们选号时的偏好模式
    private func calculatePopularityIndex(range: ClosedRange<Int>) -> [Int: Double] {
        var scores: [Int: Double] = [:]
        var rawScores: [Int: Double] = [:]
        
        for number in range {
            var score = 0.0
            
            // 生日偏好: 号码 1-31 基础权重 +0.3
            if number <= 31 { score += 0.3 }
            
            // 连号偏好: 相邻号码对 (模拟，相邻号码更常被一起选择)
            // 1-2, 11-12, 21-22 等连号组合
            if number % 10 == 1 || number % 10 == 2 {
                score += 0.2
            }
            
            // 吉祥数偏好: 6,8,9 权重 +0.15; 4 权重 -0.1
            if [6, 8, 9].contains(number % 10) { score += 0.15 }
            if number % 10 == 4 { score -= 0.1 }
            
            // 尾数偏好: 尾数 0,5 权重 +0.1
            if [0, 5].contains(number % 10) { score += 0.1 }
            
            rawScores[number] = score
        }
        
        // 归一化到 [0, 1]
        let minScore = rawScores.values.min() ?? 0
        let maxScore = rawScores.values.max() ?? 1
        let range = maxScore - minScore
        
        for (number, score) in rawScores {
            scores[number] = range > 0 ? (score - minScore) / range : 0.5
        }
        
        return scores
    }
    
    // MARK: - 2. 近期频率
    
    /// 计算近期开出频率
    /// 分别计算近 30/60/90 期各号码出现次数
    /// 加权: 0.5 × freq30 + 0.3 × freq60 + 0.2 × freq90
    private func calculateRecentFrequency(draws: [LotteryDraw], range: ClosedRange<Int>) -> [Int: Double] {
        guard !draws.isEmpty else {
            // 空数据返回均匀分布
            return Dictionary(uniqueKeysWithValues: range.map { ($0, 0.5) })
        }
        
        var freq30: [Int: Double] = [:]
        var freq60: [Int: Double] = [:]
        var freq90: [Int: Double] = [:]
        
        // 初始化
        for number in range {
            freq30[number] = 0
            freq60[number] = 0
            freq90[number] = 0
        }
        
        // 计算近30期
        let draws30 = draws.prefix(30)
        for draw in draws30 {
            for ball in draw.frontBalls {
                if range.contains(ball) {
                    freq30[ball, default: 0] += 1
                }
            }
        }
        
        // 计算近60期
        let draws60 = draws.prefix(60)
        for draw in draws60 {
            for ball in draw.frontBalls {
                if range.contains(ball) {
                    freq60[ball, default: 0] += 1
                }
            }
        }
        
        // 计算近90期
        let draws90 = draws.prefix(90)
        for draw in draws90 {
            for ball in draw.frontBalls {
                if range.contains(ball) {
                    freq90[ball, default: 0] += 1
                }
            }
        }
        
        // 归一化
        let max30 = max(freq30.values.max() ?? 1, 1)
        let max60 = max(freq60.values.max() ?? 1, 1)
        let max90 = max(freq90.values.max() ?? 1, 1)
        
        var weightedScores: [Int: Double] = [:]
        for number in range {
            let f30 = (freq30[number] ?? 0) / max30
            let f60 = (freq60[number] ?? 0) / max60
            let f90 = (freq90[number] ?? 0) / max90
            
            // 加权: 0.5 × freq30 + 0.3 × freq60 + 0.2 × freq90
            weightedScores[number] = 0.5 * f30 + 0.3 * f60 + 0.2 * f90
        }
        
        return weightedScores
    }
    
    // MARK: - 3. 生日号码惩罚
    
    /// 计算生日号码惩罚
    /// 号码 ≤ 12: bias = 0.5 (月份更集中)
    /// 号码 ≤ 31: bias = 0.3
    /// 号码 > 31: bias = 0.0
    private func calculateBirthdayBias(range: ClosedRange<Int>) -> [Int: Double] {
        var bias: [Int: Double] = [:]
        for number in range {
            if number <= 12 {
                bias[number] = 0.5
            } else if number <= 31 {
                bias[number] = 0.3
            } else {
                bias[number] = 0.0
            }
        }
        return bias
    }
}

// MARK: - 单元测试用例

#if DEBUG
extension HotNumberAvoidance {
    /// 测试用例：验证算法输出范围
    func testOutputRange(draws: [LotteryDraw], type: LotteryType) -> Bool {
        let scores = calculate(draws: draws, type: type)
        return scores.values.allSatisfy { $0 >= 0 && $0 <= 1 }
    }
    
    /// 测试用例：空数据不崩溃，返回均匀分布
    func testEmptyData(type: LotteryType) -> Bool {
        let scores = calculate(draws: [], type: type)
        return scores.count == type.frontRange.count
    }
}
#endif
