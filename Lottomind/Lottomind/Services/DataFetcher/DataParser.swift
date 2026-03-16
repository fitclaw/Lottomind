// TASK-01 | DataParser.swift | 2026-03-03

import Foundation

actor DataParser {
    static let shared = DataParser()
    
    private init() {}
    
    func parseLotteryDraw(from text: String, type: LotteryType) async throws -> LotteryDraw {
        let frontRange = await MainActor.run { type.frontRange }
        let backRange = await MainActor.run { type.backRange }
        let data = try extractJSON(from: text)
        let raw = try JSONDecoder().decode(RawDraw.self, from: data)
        
        // 验证号码范围
        guard raw.red_balls.allSatisfy({ frontRange.contains($0) }),
              backRange?.contains(raw.blue_ball) ?? true else {
            throw LMError.parseError
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: raw.date) else {
            throw LMError.parseError
        }
        
        return LotteryDraw(
            type: type,
            period: raw.period,
            date: date,
            frontBalls: raw.red_balls.sorted(),
            backBalls: [raw.blue_ball],
            jackpot: raw.jackpot,
            sales: raw.sales
        )
    }
    
    struct RawDraw: Codable {
        let period: String
        let date: String
        let red_balls: [Int]
        let blue_ball: Int
        let jackpot: Int
        let sales: Int?
    }
    
    func parseLotteryDraws(from text: String, type: LotteryType) async throws -> [LotteryDraw] {
        let frontRange = await MainActor.run { type.frontRange }
        let backRange = await MainActor.run { type.backRange }
        let data = try extractJSONArray(from: text)
        
        let raws = try JSONDecoder().decode([RawDraw].self, from: data)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var draws: [LotteryDraw] = []
        for raw in raws {
            guard raw.red_balls.allSatisfy({ frontRange.contains($0) }),
                  backRange?.contains(raw.blue_ball) ?? true else {
                continue // Skip invalid entries instead of failing all
            }
            guard let date = dateFormatter.date(from: raw.date) else {
                continue
            }
            let draw = LotteryDraw(
                type: type,
                period: raw.period,
                date: date,
                frontBalls: raw.red_balls.sorted(),
                backBalls: [raw.blue_ball],
                jackpot: raw.jackpot,
                sales: raw.sales
            )
            draws.append(draw)
        }
        
        guard !draws.isEmpty else { throw LMError.parseError }
        return draws
    }
    
    func extractJSON(from text: String) throws -> Data {
        let pattern = #"\{[\s\S]*?\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) else {
            throw LMError.parseError
        }
        
        let jsonString = String(text[Range(match.range, in: text)!])
        guard let data = jsonString.data(using: .utf8) else {
            throw LMError.parseError
        }
        return data
    }
    
    func extractJSONArray(from text: String) throws -> Data {
        let pattern = #"\[[\s\S]*?\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) else {
            throw LMError.parseError
        }
        
        let jsonString = String(text[Range(match.range, in: text)!])
        guard let data = jsonString.data(using: .utf8) else {
            throw LMError.parseError
        }
        return data
    }
}
