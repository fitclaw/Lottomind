// TASK-01 | ReverseEngine.swift | 2026-03-03

import Foundation

actor ReverseEngine {
    static let shared = ReverseEngine()
    
    private let hotNumberAvoidance = HotNumberAvoidance()
    private let jackpotPressure = JackpotPressure()
    private let sequenceDecay = SequenceDecay()
    private let comboStructure = ComboStructure()
    private let anomalyDetection = AnomalyDetection()
    private let fusionScorer = FusionScorer()
    
    private init() {}
    
    func analyze(type: LotteryType, draws: [LotteryDraw]) async -> [Recommendation] {
        // 并发运行 M1-M5
        async let hotResult = hotNumberAvoidance.calculate(draws: draws, type: type)
        async let pressureResult = jackpotPressure.calculate(draws: draws, type: type)
        async let decayResult = sequenceDecay.calculate(draws: draws, type: type)
        async let anomalyResult = anomalyDetection.detect(draws: draws, type: type)
        
        let (hot, pressure, decay, anomaly) = await (hotResult, pressureResult, decayResult, anomalyResult)
        
        return await fusionScorer.generateRecommendations(
            type: type,
            comboStructure: comboStructure,
            hotScores: hot,
            pressureResult: pressure,
            decayScores: decay,
            anomalyResult: anomaly
        )
    }
}
