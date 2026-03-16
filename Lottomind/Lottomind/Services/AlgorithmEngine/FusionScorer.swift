// TASK-01 | FusionScorer.swift | 2026-03-03

import Foundation

actor FusionScorer {
    
    private var moduleWeights: [String: Double] = [
        "M1": 0.25,
        "M2": 0.15,
        "M3": 0.20,
        "M4": 0.20,
        "M5": 0.20
    ]
    
    func generateRecommendations(
        type: LotteryType,
        comboStructure: ComboStructure,
        hotScores: [Int: Double],
        pressureResult: PressureResult,
        decayScores: [Int: Double],
        anomalyResult: AnomalyResult
    ) async -> [Recommendation] {
        let frontRange = Array(type.frontRange)
        var candidates: [(combo: [Int], backBalls: [Int], score: Double, moduleScores: [String: Double])] = []
        let period = "2026032" // Mock pending next period
        
        let backRange = type.backRange.map { Array($0) } ?? []
        
        for _ in 0..<10000 {
            let combo = Array(frontRange.shuffled().prefix(type.frontCount)).sorted()
            let backBalls = Array(backRange.shuffled().prefix(type.backCount)).sorted()
            
            let m4Result = await comboStructure.evaluate(combo: combo, type: type)
            
            let (finalScore, moduleScores) = calculateFinalScore(
                combo: combo,
                hotScores: hotScores,
                pressureResult: pressureResult,
                decayScores: decayScores,
                anomalyResult: anomalyResult,
                m4Score: m4Result.total
            )
            
            candidates.append((combo, backBalls, finalScore, moduleScores))
        }
        
        candidates.sort { $0.score > $1.score }
        let top5 = candidates.prefix(5)
        
        return top5.map { cand in
            let confidence = min(1.0, max(0.4, cand.score * 1.2))
            let explanation = generateExplanation(for: cand.combo, pressureResult: pressureResult)
            
            return Recommendation(
                type: type,
                period: period,
                frontBalls: cand.combo,
                backBalls: cand.backBalls,
                confidence: confidence,
                moduleScores: cand.moduleScores,
                explanation: explanation
            )
        }
    }
    
    private func calculateFinalScore(
        combo: [Int],
        hotScores: [Int: Double],
        pressureResult: PressureResult,
        decayScores: [Int: Double],
        anomalyResult: AnomalyResult,
        m4Score: Double
    ) -> (Double, [String: Double]) {
        
        let m1Score = combo.reduce(0.0) { $0 + (hotScores[$1] ?? 0.0) } / Double(combo.count)
        let m2Score = min(1.0, pressureResult.index / 2.0)
        let m3Score = combo.reduce(0.0) { $0 + (decayScores[$1] ?? 0.0) } / Double(combo.count)
        
        var m5Score = 0.0
        for n in combo {
            if anomalyResult.changePoints.contains(n) { m5Score += 0.5 }
            m5Score += min(0.5, abs(anomalyResult.zScores[n] ?? 0.0) / 4.0)
        }
        m5Score = min(1.0, m5Score / Double(combo.count))
        
        let finalScore = 
            moduleWeights["M1", default: 0.25] * m1Score +
            moduleWeights["M2", default: 0.15] * m2Score +
            moduleWeights["M3", default: 0.20] * m3Score +
            moduleWeights["M4", default: 0.20] * m4Score +
            moduleWeights["M5", default: 0.20] * m5Score
            
        let moduleScores: [String: Double] = [
            "M1": m1Score * 100,
            "M2": m2Score * 100,
            "M3": m3Score * 100,
            "M4": m4Score * 100,
            "M5": m5Score * 100
        ]
        
        return (finalScore, moduleScores)
    }
    
    private func generateExplanation(for combo: [Int], pressureResult: PressureResult) -> String {
        let modeDesc: String
        switch pressureResult.mode {
        case .hard: modeDesc = "倾向推荐离散型号码组合，降低与大众重合概率"
        case .normal: modeDesc = "采用均衡策略"
        case .easy: modeDesc = "适当放宽组合约束，允许常见号码模式"
        }
        
        let rawExplanation = "当前奖池压力指数 \(String(format: "%.2f", pressureResult.index))，模型\(modeDesc)。通过多模块融合评分筛选，本次结果仅供历史统计分析参考。"
        
        // 严格合规过滤
        let forbiddenWords = ["预测", "必中", "保证", "稳赚", "胜算", "包中"]
        var safeExplanation = rawExplanation
        for word in forbiddenWords {
            safeExplanation = safeExplanation.replacingOccurrences(of: word, with: "**") // 替换为脱敏符，虽然上面hardcode里没有，但是为了后续扩展安全
        }
        
        return safeExplanation
    }
}
