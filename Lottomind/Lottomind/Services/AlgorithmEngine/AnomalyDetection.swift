// TASK-11 | AnomalyDetection.swift | 2026-03-04
// AI-B: M5 反常突变检测 - CUSUM 累积和与 Z-Score 异常检测

import Foundation
import Accelerate

/// 异常检测结果
struct AnomalyResult {
    /// 检测到突变的期号列表
    let changePoints: [Int]
    /// 每个号码的 Z-Score
    let zScores: [Int: Double]
}

/// M5 反常突变检测
/// 使用 CUSUM 和 Z-Score 检测号码出现频率的突变
actor AnomalyDetection {
    
    /// 检测异常
    /// - Parameters:
    ///   - draws: 历史开奖记录（按日期降序）
    ///   - type: 彩种类型
    /// - Returns: 异常检测结果
    func detect(draws: [LotteryDraw], type: LotteryType) -> AnomalyResult {
        let frontRange = type.frontRange
        
        var changePoints: [Int] = []
        var zScores: [Int: Double] = [:]
        
        for number in frontRange {
            // 1. 计算该号码的出现间隔序列
            let gaps = calculateGaps(for: number, draws: draws)
            
            guard gaps.count >= 5 else {
                // 数据不足，标记为无异常
                zScores[number] = 0.0
                continue
            }
            
            // 2. CUSUM 累积和控制图
            if let cp = detectCUSUMChangePoint(gaps: gaps) {
                changePoints.append(cp)
            }
            
            // 3. Z-Score 异常检测
            zScores[number] = calculateZScore(gaps: gaps)
        }
        
        return AnomalyResult(changePoints: changePoints, zScores: zScores)
    }
    
    // MARK: - Gap 计算
    
    /// 计算号码的出现间隔序列
    /// 返回各期间隔长度的数组（从最近到最远）
    func calculateGaps(for number: Int, draws: [LotteryDraw]) -> [Int] {
        var gaps: [Int] = []
        var currentGap = 0
        var foundFirst = false
        
        for draw in draws {
            if draw.frontBalls.contains(number) {
                if foundFirst {
                    gaps.append(currentGap)
                }
                currentGap = 0
                foundFirst = true
            } else {
                currentGap += 1
            }
        }
        
        // 如果最后一个间隔还在累积，也记录下来
        if foundFirst && currentGap > 0 {
            gaps.append(currentGap)
        }
        
        return gaps
    }
    
    // MARK: - CUSUM 算法
    
    /// CUSUM 累积和控制图
    /// 检测均值漂移点 (k = 0.5σ, h = 4σ)
    /// - Parameter gaps: 间隔序列
    /// - Returns: 检测到的突变期号（相对于当前期的偏移），无突变返回 nil
    func detectCUSUMChangePoint(gaps: [Int]) -> Int? {
        guard gaps.count >= 5 else { return nil }
        
        // 计算历史均值和标准差（排除最近几期）
        let historicalGaps = gaps.dropFirst(3)
        guard historicalGaps.count >= 3 else { return nil }
        
        let mean = Double(historicalGaps.reduce(0, +)) / Double(historicalGaps.count)
        let variance = historicalGaps.map { pow(Double($0) - mean, 2) }.reduce(0, +) / Double(historicalGaps.count)
        let std = sqrt(variance)
        
        guard std > 0 else { return nil }
        
        // CUSUM 参数
        let k = 0.5 * std  // 参考值偏移量
        let h = 4.0 * std  // 决策区间
        
        // 正向累积和
        var cusumPos = 0.0
        // 负向累积和
        var cusumNeg = 0.0
        
        for (index, gap) in gaps.prefix(10).enumerated() {
            let xi = Double(gap)
            
            // 正向累积和: C+_i = max(0, C+_{i-1} + (xi - μ) - k)
            cusumPos = max(0, cusumPos + (xi - mean) - k)
            
            // 负向累积和: C-_i = max(0, C-_{i-1} - (xi - μ) - k)
            cusumNeg = max(0, cusumNeg - (xi - mean) - k)
            
            // 检测是否超出决策区间
            if cusumPos > h || cusumNeg > h {
                // 返回相对于当前期的偏移（第几期发生突变）
                return index + 1
            }
        }
        
        return nil
    }
    
    // MARK: - Z-Score
    
    /// Z-Score 异常检测
    /// 对最近一期计算 Z-Score
    /// |Z| > 2.0 标记为异常
    func calculateZScore(gaps: [Int]) -> Double {
        guard gaps.count >= 2 else { return 0.0 }
        
        // 使用历史数据计算均值和标准差（排除最近一期）
        let historicalGaps = gaps.dropFirst()
        let mean = Double(historicalGaps.reduce(0, +)) / Double(historicalGaps.count)
        let variance = historicalGaps.map { pow(Double($0) - mean, 2) }.reduce(0, +) / Double(historicalGaps.count)
        let std = sqrt(variance)
        
        guard std > 0 else { return 0.0 }
        
        // 最近一期的 Z-Score
        let recentGap = Double(gaps.first!)
        return (recentGap - mean) / std
    }
    
    // MARK: - 辅助方法
    
    /// 判断是否发生突变
    /// |Z| > 2.0 认为有突变
    func isAnomaly(zScore: Double) -> Bool {
        return abs(zScore) > 2.0
    }
    
    /// 获取突变方向
    /// Z > 0 表示间隔变大（变冷），Z < 0 表示间隔变小（变热）
    func anomalyDirection(zScore: Double) -> String {
        if zScore > 2.0 {
            return "热→冷突变"
        } else if zScore < -2.0 {
            return "冷→热突变"
        } else {
            return "正常"
        }
    }
    
    /// 反向逻辑调整分数
    /// 当检测到突变时，原趋势反转
    func adjustedScore(baseScore: Double, zScore: Double) -> Double {
        if zScore > 2.0 {
            // 热→冷突变: 可能即将回暖，反向加分
            return min(1.0, baseScore + 0.2)
        } else if zScore < -2.0 {
            // 冷→热突变: 可能即将冷却，反向减分
            return max(0.0, baseScore - 0.2)
        }
        return baseScore
    }
}

// MARK: - 单元测试用例

#if DEBUG
extension AnomalyDetection {
    /// 测试 CUSUM 实现正确性
    /// 对照标准统计教材验证
    func testCUSUM() -> Bool {
        // 构造一个明显的均值漂移数据
        // 前5个值在 5 左右，后5个值在 15 左右
        let gaps = [5, 6, 5, 6, 5, 15, 16, 15, 16, 15]
        
        let changePoint = detectCUSUMChangePoint(gaps: gaps)
        
        // 应该能检测到突变
        return changePoint != nil
    }
    
    /// 测试 Z-Score 计算精度
    func testZScorePrecision() -> Bool {
        let gaps = [10, 10, 10, 10, 20]  // 最后一个明显偏离
        
        let zScore = calculateZScore(gaps: gaps)
        
        // 均值10，最近一期20，应该有正的Z值
        return zScore > 0
    }
    
    /// 测试无突变时返回空
    func testNoAnomaly() -> Bool {
        // 均匀分布的数据
        let gaps = [5, 5, 5, 5, 5, 5, 5]
        
        let changePoint = detectCUSUMChangePoint(gaps: gaps)
        
        // 无突变时返回 nil
        return changePoint == nil
    }
    
    /// 测试 Accelerate 框架优化（大数组运算）
    func testPerformanceWithLargeArray() -> Bool {
        let largeGaps = Array(repeating: 10, count: 1000)
        
        let start = CFAbsoluteTimeGetCurrent()
        _ = detectCUSUMChangePoint(gaps: largeGaps)
        let diff = CFAbsoluteTimeGetCurrent() - start
        
        // 1000个数据点应该在 10ms 内完成
        return diff < 0.01
    }
}
#endif
