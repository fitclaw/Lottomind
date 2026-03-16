// AlgorithmEngineTests.swift
// TASK-21

import XCTest
@testable import Lottomind

final class AlgorithmEngineTests: XCTestCase {

    var sampleDraws: [LotteryDraw]!

    override func setUp() {
        super.setUp()
        sampleDraws = [
            LotteryDraw(type: .ssq, period: "1", date: Date(), frontBalls: [1, 2, 3, 4, 5, 6], backBalls: [1], jackpot: 100_000_000),
            LotteryDraw(type: .ssq, period: "2", date: Date(), frontBalls: [2, 3, 4, 5, 6, 7], backBalls: [2], jackpot: 200_000_000)
        ]
    }

    func testHotNumberAvoidance() async {
        let algo = HotNumberAvoidance()
        let scores = await algo.calculate(draws: sampleDraws, type: .ssq)
        
        XCTAssertFalse(scores.isEmpty)
        XCTAssertEqual(scores.count, 33)
        XCTAssert(scores[1]! <= 1.0 && scores[1]! >= 0.0) // Within 0 to 1 bounds
    }
    
    func testJackpotPressure() {
        let algo = JackpotPressure()
        let draws = [
            LotteryDraw(type: .ssq, period: "3", date: Date(), frontBalls: [3, 4, 5, 6, 7, 8], backBalls: [3], jackpot: 200_000_000),
            LotteryDraw(type: .ssq, period: "2", date: Date(), frontBalls: [2, 3, 4, 5, 6, 7], backBalls: [2], jackpot: 100_000_000),
            LotteryDraw(type: .ssq, period: "1", date: Date(), frontBalls: [1, 2, 3, 4, 5, 6], backBalls: [1], jackpot: 200_000_000)
        ]
        let result = algo.calculate(draws: draws, type: .ssq)
        // Current is 200M, historical average is (100M + 200M) / 2 = 150M.
        // Index = 200M / 150M = 1.33, which should stay in the normal range.
        XCTAssertEqual(result.mode, .normal)
        XCTAssertTrue(result.index > 1.3 && result.index < 1.4)
    }
    
    func testAnomalyDetection() async {
        let algo = AnomalyDetection()
        let result = await algo.detect(draws: sampleDraws, type: .ssq)
        // With tiny sample, might return empty changePoints, but we test the structure
        XCTAssertNotNil(result.zScores)
        XCTAssertEqual(result.zScores.count, 33)
    }
}
