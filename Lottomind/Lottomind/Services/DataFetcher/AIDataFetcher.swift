// TASK-01 | AIDataFetcher.swift | 2026-03-03

import Foundation

actor AIDataFetcher {
    static let shared = AIDataFetcher()
    
    private let apiClient = AIAPIClient.shared
    private let parser = DataParser.shared
    
    private init() {}
    
    func fetchLatestDraw(type: LotteryType) async throws -> LotteryDraw {
        let displayName = await MainActor.run { type.displayName }
        let prompt = """
        搜索中国福利彩票\(displayName)最新一期开奖结果。\
        返回严格JSON格式：{\"period\": \"期号\", \"date\": \"YYYY-MM-DD\", \"red_balls\": [int], \"blue_ball\": int, \"jackpot\": int, \"sales\": int}。\
        仅返回JSON，无其他文字。
        """
        
        let tools = [Tool(type: "web_search_20250305", name: "web_search")]
        
        let response = try await apiClient.sendMessage(prompt: prompt, tools: tools)
        
        guard let text = response.content.first?.text else {
            throw LMError.parseError
        }
        
        return try await parser.parseLotteryDraw(from: text, type: type)
    }
    
    func syncHistoricalData(type: LotteryType) async throws -> [LotteryDraw] {
        let displayName = await MainActor.run { type.displayName }
        let prompt = """
        搜索中国福利彩票\(displayName)最近30期的开奖结果（历史数据）。
        返回严格且纯粹的JSON数组格式，例如：
        [{\"period\": \"期号\", \"date\": \"YYYY-MM-DD\", \"red_balls\": [int, int, int, int, int, int], \"blue_ball\": int, \"jackpot\": int, \"sales\": int}]
        务必包含至少10期以上的数据，仅返回JSON数组。不要包含任何 markdown 代码块标识。
        """
        
        let tools = [Tool(type: "web_search_20250305", name: "web_search")]
        
        let response = try await apiClient.sendMessage(prompt: prompt, tools: tools)
        
        guard let text = response.content.first?.text else {
            throw LMError.parseError
        }
        
        return try await parser.parseLotteryDraws(from: text, type: type)
    }
}
