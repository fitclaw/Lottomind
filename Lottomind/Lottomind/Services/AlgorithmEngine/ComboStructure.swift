// TASK-10 | ComboStructure.swift | 2026-03-04
// AI-B: M4 组合结构算法 - 评估号码组合的结构性特征

import Foundation
import Darwin  // For log2

/// 结构评分结果
struct StructureScore {
    /// 总分 (0...1)
    let total: Double
    /// 各特征分数
    let features: [String: Double]
}

/// M4 组合结构算法
/// 分析号码组合的结构特征（奇偶比、大小比、区间分布等）
actor ComboStructure {
    
    /// 评估号码组合
    /// - Parameters:
    ///   - combo: 待评估的号码组合（已排序）
    ///   - type: 彩种类型
    /// - Returns: 结构评分结果
    func evaluate(combo: [Int], type: LotteryType) -> StructureScore {
        // 在 MainActor 上获取需要的属性值
        let frontCount = type.frontCount
        let frontRange = type.frontRange
        
        var features: [String: Double] = [:]
        
        // 1. 奇偶比 (偏离均衡越远分越低)
        features["oddEvenRatio"] = evaluateOddEvenRatio(combo: combo, frontCount: frontCount)
        
        // 2. 大小比
        features["sizeRatio"] = evaluateSizeRatio(combo: combo, frontRange: frontRange, frontCount: frontCount)
        
        // 3. 区间分布 (信息熵)
        features["zoneEntropy"] = evaluateZoneDistribution(combo: combo, frontRange: frontRange, frontCount: frontCount)
        
        // 4. 和值偏离度
        features["sumDeviation"] = evaluateSumDeviation(combo: combo, frontRange: frontRange, frontCount: frontCount)
        
        // 5. 连号组数 (0组最优，连号越多少分越低)
        features["consecutiveCount"] = evaluateConsecutiveCount(combo: combo)
        
        // 6. AC值 (号码差值集合的去重数量)
        features["acValue"] = evaluateACValue(combo: combo, frontCount: frontCount)
        
        // 加权平均
        // 权重: 奇偶0.15 大小0.15 区间0.2 和值0.15 连号0.2 AC值0.15
        let weights: [String: Double] = [
            "oddEvenRatio": 0.15,
            "sizeRatio": 0.15,
            "zoneEntropy": 0.20,
            "sumDeviation": 0.15,
            "consecutiveCount": 0.20,
            "acValue": 0.15
        ]
        
        let total = weights.reduce(0.0) { sum, pair in
            sum + (features[pair.key] ?? 0) * pair.value
        }
        
        return StructureScore(total: total, features: features)
    }
    
    // MARK: - 1. 奇偶比
    
    /// 评估奇偶比
    /// 双色球 6 个红球，理想奇偶比为 3:3
    private func evaluateOddEvenRatio(combo: [Int], frontCount: Int) -> Double {
        let oddCount = combo.filter { $0 % 2 == 1 }.count
        _ = combo.count - oddCount  // evenCount (unused but calculated for clarity)
        
        // 理想情况下奇偶各半
        let idealOdd = Double(frontCount) / 2.0
        let deviation = abs(Double(oddCount) - idealOdd)
        
        // 偏离越小分数越高
        let maxDeviation = idealOdd  // 最大偏离
        return max(0, 1.0 - deviation / maxDeviation)
    }
    
    // MARK: - 2. 大小比
    
    /// 评估大小比
    /// 以中位数分割，偏离均衡越远分越低
    private func evaluateSizeRatio(combo: [Int], frontRange: ClosedRange<Int>, frontCount: Int) -> Double {
        let mid = (frontRange.lowerBound + frontRange.upperBound) / 2
        
        let bigCount = combo.filter { $0 > mid }.count
        _ = combo.count - bigCount  // smallCount
        
        // 理想均衡
        let idealCount = Double(frontCount) / 2.0
        let deviation = abs(Double(bigCount) - idealCount)
        
        let maxDeviation = idealCount
        return max(0, 1.0 - deviation / maxDeviation)
    }
    
    // MARK: - 3. 区间分布
    
    /// 评估区间分布均匀度 (信息熵)
    /// 将号码范围等分3区，计算分布的信息熵
    private func evaluateZoneDistribution(combo: [Int], frontRange: ClosedRange<Int>, frontCount: Int) -> Double {
        let zoneSize = Double(frontRange.upperBound - frontRange.lowerBound + 1) / 3.0
        
        // 分区计数
        var zoneCounts = [0, 0, 0]
        for num in combo {
            let zoneIndex = min(2, Int(Double(num - frontRange.lowerBound) / zoneSize))
            zoneCounts[zoneIndex] += 1
        }
        
        // 计算信息熵
        let total = Double(frontCount)
        var entropy = 0.0
        
        for count in zoneCounts {
            if count > 0 {
                let p = Double(count) / total
                entropy -= p * (log(p) / log(2.0))  // log2(x) = ln(x) / ln(2)
            }
        }
        
        // 最大熵为 log2(3) ≈ 1.585，归一化到 [0, 1]
        let maxEntropy = log(3.0) / log(2.0)  // log2(3)
        return entropy / maxEntropy
    }
    
    // MARK: - 4. 和值偏离度
    
    /// 评估和值偏离度
    /// 与理论均值比较
    private func evaluateSumDeviation(combo: [Int], frontRange: ClosedRange<Int>, frontCount: Int) -> Double {
        let sum = combo.reduce(0, +)
        
        // 理论最小和值 (选最小的 frontCount 个号码)
        let minSum = (1...frontCount).reduce(0, +)
        // 理论最大和值 (选最大的 frontCount 个号码)
        let maxSum = (0..<frontCount).map { frontRange.upperBound - $0 }.reduce(0, +)
        
        // 理论均值
        let theoreticalMean = Double(minSum + maxSum) / 2.0
        let theoreticalRange = Double(maxSum - minSum) / 2.0  // 半区间
        
        let deviation = abs(Double(sum) - theoreticalMean)
        
        // 偏离半区间的一半时分数为 0
        return max(0, 1.0 - deviation / (theoreticalRange * 0.5))
    }
    
    // MARK: - 5. 连号组数
    
    /// 评估连号情况
    /// 0组连号最优（分数最高），连号越多少分越低
    private func evaluateConsecutiveCount(combo: [Int]) -> Double {
        guard combo.count > 1 else { return 1.0 }
        
        var consecutiveGroups = 0
        var currentStreak = 1
        
        for i in 1..<combo.count {
            if combo[i] == combo[i-1] + 1 {
                currentStreak += 1
            } else {
                if currentStreak >= 2 {
                    consecutiveGroups += 1
                }
                currentStreak = 1
            }
        }
        
        if currentStreak >= 2 {
            consecutiveGroups += 1
        }
        
        // 0组满分，1组0.6分，2组0.3分，3组及以上0分
        switch consecutiveGroups {
        case 0: return 1.0
        case 1: return 0.6
        case 2: return 0.3
        default: return 0.0
        }
    }
    
    // MARK: - 6. AC值
    
    /// 评估 AC 值 (Arithmetic Complexity)
    /// 号码差值集合的去重数量，AC值越高组合越复杂
    private func evaluateACValue(combo: [Int], frontCount: Int) -> Double {
        guard combo.count >= 2 else { return 0.0 }
        
        // 计算所有两两差值
        var differences = Set<Int>()
        for i in 0..<combo.count {
            for j in (i+1)..<combo.count {
                differences.insert(combo[j] - combo[i])
            }
        }
        
        // AC值 = 不同差值的数量
        let acValue = differences.count
        
        // 最大可能的 AC 值 (组合数 C(n,2))
        let maxAC = (frontCount * (frontCount - 1)) / 2
        
        // 归一化
        return min(1.0, Double(acValue) / Double(maxAC))
    }
    
    // MARK: - 辅助方法
    
    /// 获取组合特征描述
    func comboDescription(combo: [Int], type: LotteryType) -> String {
        let frontRange = type.frontRange
        
        let oddCount = combo.filter { $0 % 2 == 1 }.count
        let evenCount = combo.count - oddCount
        
        let mid = (frontRange.lowerBound + frontRange.upperBound) / 2
        let bigCount = combo.filter { $0 > mid }.count
        let smallCount = combo.count - bigCount
        
        let sum = combo.reduce(0, +)
        
        return "奇偶比 \(oddCount):\(evenCount)，大小比 \(bigCount):\(smallCount)，和值 \(sum)"
    }
}

// MARK: - 单元测试用例

#if DEBUG
extension ComboStructure {
    /// 测试简单组合（如 1,2,3,4,5,6）得分明显低于复杂组合
    func testSimpleVsComplex() -> Bool {
        let simpleCombo = [1, 2, 3, 4, 5, 6]  // 简单组合
        let complexCombo = [3, 8, 15, 23, 28, 31]  // 复杂组合
        
        let simpleScore = evaluate(combo: simpleCombo, type: .ssq).total
        let complexScore = evaluate(combo: complexCombo, type: .ssq).total
        
        return complexScore > simpleScore
    }
    
    /// 测试各特征分数范围
    func testFeatureRanges(combo: [Int], type: LotteryType) -> Bool {
        let score = evaluate(combo: combo, type: type)
        
        // 总分在 [0, 1]
        guard score.total >= 0 && score.total <= 1 else { return false }
        
        // 各特征在 [0, 1]
        return score.features.values.allSatisfy { $0 >= 0 && $0 <= 1 }
    }
}
#endif
