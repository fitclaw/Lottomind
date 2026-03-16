// DataParserTests.swift
// TASK-21

import XCTest
@testable import Lottomind

final class DataParserTests: XCTestCase {

    func testValidJSONParsing() async throws {
        let jsonResponse = """
        ```json
        {
            "period": "2026032",
            "date": "2026-03-03",
            "red_balls": [1, 5, 12, 15, 23, 31],
            "blue_ball": 9,
            "jackpot": 400000000
        }
        ```
        """
        
        let draw = try await DataParser.shared.parseLotteryDraw(from: jsonResponse, type: .ssq)
        XCTAssertEqual(draw.type, .ssq)
        XCTAssertEqual(draw.period, "2026032")
        XCTAssertEqual(draw.frontBalls, [1, 5, 12, 15, 23, 31])
        XCTAssertEqual(draw.backBalls, [9])
        XCTAssertEqual(draw.jackpot, 400000000)
    }
    
    func testInvalidJSONFormat() async {
        let invalidJSON = "not a json string"
        
        await XCTAssertThrowsErrorAsync(try await DataParser.shared.parseLotteryDraw(from: invalidJSON, type: .ssq)) { error in
            guard let lmError = error as? LMError else {
                XCTFail("Expected LMError, got \(error)")
                return
            }
            guard case .parseError = lmError else {
                XCTFail("Expected parseError, got \(lmError)")
                return
            }
        }
    }
    
    func testJSONMissingRequiredFields() async {
        let missingFieldsJSON = """
        ```json
        {
            "red_balls": [1, 2, 3, 4, 5, 6]
        }
        ```
        """
        
        await XCTAssertThrowsErrorAsync(try await DataParser.shared.parseLotteryDraw(from: missingFieldsJSON, type: .ssq))
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ errorHandler: ((Error) -> Void)? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw an error", file: file, line: line)
    } catch {
        errorHandler?(error)
    }
}
