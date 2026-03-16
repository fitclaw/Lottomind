// TASK-09 | SequenceDecay.swift | 2026-03-04
// AI-B: M3 序列衰减算法 - 基于遗漏期数和马尔可夫链的号码分析

import Foundation

/// 号码状态
enum NumberState {
    case hot   // 近5期出现≥2次
    case warm  // 中间态
    case cold  // 近20期未出现
}

/// M3 序列衰减算法
/// 分析号码的遗漏周期和状态转移概率
actor SequenceDecay {
    
    /// 计算衰减分数
    /// - Parameters:
    ///   - draws: 历史开奖记录（按日期降序）
    ///   - type: 彩种类型
    /// - Returns: 号码到衰减分数的映射 (0...1)
    func calculate(draws: [LotteryDraw], type: LotteryType) -> [Int: Double] {
        let range = type.frontRange
        var decayScores: [Int: Double] = [:]
        
        for number in range {
            // 1. 计算连续未出现期数 (gap)
            let gap = calculateGap(for: number, draws: draws)
            
            // 2. 指数衰减模型: decayScore = 1 - e^(-λ × gap)
            // λ = 平均遗漏期数的倒数 (假设平均遗漏期为 10 期)
            let lambda = 1.0 / 10.0
            let decayScore = 1.0 - exp(-lambda * Double(gap))
            
            // 3. 马尔可夫转移概率
            let transitionProb = calculateTransitionProb(for: number, draws: draws)
            
            // 4. 综合衰减分数 = 0.6 × decayScore + 0.4 × transitionProb
            decayScores[number] = 0.6 * decayScore + 0.4 * transitionProb
        }
        
        return decayScores
    }
    
    // MARK: - Gap 计算
    
    /// 计算号码的连续未出现期数
    /// 遍历历史记录，找到最近出现的期数
    func calculateGap(for number: Int, draws: [LotteryDraw]) -> Int {
        for (index, draw) in draws.enumerated() {
            if draw.frontBalls.contains(number) {
                return index  // 第 index 期未出现（0-indexed）
            }
        }
        // 从未出现，返回总期数
        return draws.count
    }
    
    // MARK: - 马尔可夫转移概率
    
    /// 计算马尔可夫转移概率
    /// 基于历史统计计算 Hot→Cold, Cold→Hot 等转移概率
    func calculateTransitionProb(for number: Int, draws: [LotteryDraw]) -> Double {
        guard draws.count >= 21 else {
            // 数据不足，返回中性概率
            return 0.5
        }
        
        // 获取号码最近20期的状态历史
        var stateHistory: [NumberState] = []
        for i in 0..<min(20, draws.count) {
            let recentDraws = draws.dropFirst(i).prefix(5)
            let count = recentDraws.filter { $0.frontBalls.contains(number) }.count
            
            let state: NumberState
            if count >= 2 {
                state = .hot
            } else if i < 20 {
                // 检查是否近20期未出现
                let last20 = draws.dropFirst(i).prefix(20)
                let appeared = last20.contains { $0.frontBalls.contains(number) }
                state = appeared ? .warm : .cold
            } else {
                state = .warm
            }
            stateHistory.append(state)
        }
        
        // 计算转移概率矩阵 (简化版)
        // 我们关注的是：从当前状态转移到出现的概率
        guard let currentState = stateHistory.first else {
            return 0.5
        }
        
        // 统计当前状态下的出现概率
        var sameStateCount = 0
        var transitionCount = 0
        
        for i in 0..<(stateHistory.count - 1) {
            if stateHistory[i] == currentState {
                sameStateCount += 1
                // 如果下一期出现（状态改变或保持hot）
                if stateHistory[i + 1] == .hot || (currentState != .hot && stateHistory[i + 1] != currentState) {
                    transitionCount += 1
                }
            }
        }
        
        guard sameStateCount > 0 else {
            return 0.5
        }
        
        // 回温概率
        return Double(transitionCount) / Double(sameStateCount)
    }
    
    // MARK: - 号码状态判断
    
    /// 获取号码当前状态
    /// - hot: 近5期出现≥2次
    /// - cold: 近20期未出现
    /// - warm: 其他
    func getNumberState(number: Int, draws: [LotteryDraw]) -> NumberState {
        let recent5 = draws.prefix(5)
        let count5 = recent5.filter { $0.frontBalls.contains(number) }.count
        
        if count5 >= 2 {
            return .hot
        }
        
        let recent20 = draws.prefix(20)
        let appearedIn20 = recent20.contains { $0.frontBalls.contains(number) }
        
        if !appearedIn20 {
            return .cold
        }
        
        return .warm
    }
    
    /// 获取号码遗漏期数统计
    func getGapStats(for number: Int, draws: [LotteryDraw]) -> (current: Int, max: Int, average: Double) {
        var gaps: [Int] = []
        var currentGap = 0
        var foundCurrent = false
        
        for draw in draws {
            if draw.frontBalls.contains(number) {
                if foundCurrent {
                    gaps.append(currentGap)
                }
                currentGap = 0
                foundCurrent = true
            } else {
                if !foundCurrent {
                    currentGap += 1
                }
            }
        }
        
        if !foundCurrent {
            currentGap = draws.count
        }
        
        let maxGap = gaps.max() ?? 0
        let avgGap = gaps.isEmpty ? 0 : Double(gaps.reduce(0, +)) / Double(gaps.count)
        
        return (current: currentGap, max: maxGap, average: avgGap)
    }
}

// MARK: - 单元测试用例

#if DEBUG
extension SequenceDecay {
    /// 测试衰减曲线是否符合指数形态
    func testDecayCurve() -> Bool {
        let testGaps = [0, 5, 10, 15, 20]
        let lambda = 1.0 / 10.0
        
        var scores: [Double] = []
        for gap in testGaps {
            let score = 1.0 - exp(-lambda * Double(gap))
            scores.append(score)
        }
        
        // 验证单调递增
        for i in 1..<scores.count {
            if scores[i] <= scores[i-1] {
                return false
            }
        }
        
        // 验证范围 [0, 1]
        return scores.allSatisfy { $0 >= 0 && $0 <= 1 }
    }
    
    /// 测试边界条件
    func testBoundaryConditions(draws: [LotteryDraw], type: LotteryType) -> [Bool] {
        let range = type.frontRange
        
        // 从未出现的号码
        let neverAppeared = calculateGap(for: -1, draws: draws) == draws.count
        
        // 每期都出现的号码（理论上不可能，但测试边界）
        let firstNumber = range.lowerBound
        let alwaysAppears = draws.allSatisfy { $0.frontBalls.contains(firstNumber) }
        let gapForAlways = calculateGap(for: firstNumber, draws: draws)
        
        return [neverAppeared, !alwaysAppears || gapForAlways == 0]
    }
}
#endif
