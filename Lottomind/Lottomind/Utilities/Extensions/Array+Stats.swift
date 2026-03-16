// TASK-01 | Array+Stats.swift | 2026-03-03

import Foundation
import Accelerate

extension Array where Element == Double {
    /// 平均值
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
    
    /// 标准差
    var standardDeviation: Double {
        guard count > 1 else { return 0 }
        let avg = average
        let variance = map { pow($0 - avg, 2) }.reduce(0, +) / Double(count - 1)
        return sqrt(variance)
    }
    
    /// 使用 Accelerate 框架快速计算均值
    func fastMean() -> Double {
        guard !isEmpty else { return 0 }
        var result: Double = 0
        vDSP_meanvD(self, 1, &result, vDSP_Length(count))
        return result
    }
    
    /// Z-Score 标准化
    func zScores() -> [Double] {
        let mean = average
        let std = standardDeviation
        guard std > 0 else { return Array(repeating: 0, count: count) }
        return map { ($0 - mean) / std }
    }
}

extension Array where Element == Int {
    /// 平均值
    var average: Double {
        guard !isEmpty else { return 0 }
        return Double(reduce(0, +)) / Double(count)
    }
    
    /// 众数
    var mode: [Int] {
        let frequency = reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        guard let maxCount = frequency.values.max(), maxCount > 1 else { return [] }
        return frequency.filter { $0.value == maxCount }.map { $0.key }
    }
    
    /// 中位数
    var median: Double {
        guard !isEmpty else { return 0 }
        let sorted = self.sorted()
        let mid = count / 2
        if count % 2 == 0 {
            return Double(sorted[mid - 1] + sorted[mid]) / 2.0
        } else {
            return Double(sorted[mid])
        }
    }
}

// MARK: - 数组分块

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
