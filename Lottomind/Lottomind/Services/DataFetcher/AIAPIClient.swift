// TASK-22 | AIAPIClient.swift | 2026-03-04

import Foundation
import Security

struct Tool: Codable, Sendable {
    let type: String
    let name: String
}

struct APIResponse: Codable, Sendable {
    let content: [Content]
    
    struct Content: Codable, Sendable {
        let type: String
        let text: String?
    }
}

enum AIProvider: String, Codable, Sendable {
    case claude
    case openai
    case gemini
    case grok
    
    var displayName: String {
        switch self {
        case .claude: return "Claude"
        case .openai: return "OpenAI"
        case .gemini: return "Gemini"
        case .grok: return "Grok"
        }
    }
}

actor AIAPIClient {
    static let shared = AIAPIClient()
    
    private let keychainKey = Constants.KeychainKeys.aiAPIKey
    
    private init() {}
    
    static func detectProvider(from key: String) -> AIProvider {
        if key.hasPrefix("sk-ant-") { return .claude }
        if key.hasPrefix("AIza") { return .gemini }
        if key.hasPrefix("xai-") { return .grok }
        return .openai
    }
    
    func sendMessage(prompt: String, tools: [Tool]? = nil) async throws -> APIResponse {
        guard let apiKey = try? readAPIKey() else {
            throw LMError.apiKeyMissing
        }
        
        let provider = Self.detectProvider(from: apiKey)
        let maxRetries = 2
        var attempt = 0
        
        while true {
            let request = try buildRequest(for: provider, apiKey: apiKey, prompt: prompt, tools: tools)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LMError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200:
                return try parseResponse(data: data, provider: provider)
            case 429, 500...599:
                if attempt < maxRetries {
                    attempt += 1
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    continue
                }
                
                // Extract API error info if available safely
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let err = extractErrorMessage(from: json) {
                    throw LMError.apiError(err)
                }
                
                throw httpResponse.statusCode == 429 ? LMError.rateLimited : LMError.serverError
            default:
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let err = extractErrorMessage(from: json) {
                    throw LMError.apiError(err)
                }
                throw LMError.networkError
            }
        }
    }
    
    private func extractErrorMessage(from json: [String: Any]) -> String? {
        if let errorObj = json["error"] as? [String: Any], let msg = errorObj["message"] as? String {
            return msg
        }
        if let errMsg = json["error"] as? String {
            return errMsg
        }
        return nil
    }
    
    private func buildRequest(for provider: AIProvider, apiKey: String, prompt: String, tools: [Tool]?) throws -> URLRequest {
        var request: URLRequest
        var body: [String: Any] = [:]
        
        switch provider {
        case .claude:
            request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            body = [
                "model": "claude-3-5-sonnet-latest",
                "max_tokens": 1024,
                "messages": [["role": "user", "content": prompt]]
            ]
            if let tools = tools {
                body["tools"] = tools.map { ["type": $0.type, "name": $0.name] }
            }
            
        case .gemini:
            // For general generation
            request = URLRequest(url: URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            body = [
                "contents": [
                    ["parts": [["text": prompt]]]
                ]
            ]
            // We ignore tools for Gemini since standard API payload is drastically different
            
        case .openai, .grok:
            let baseURL = provider == .grok ? "https://api.x.ai/v1/chat/completions" : "https://api.openai.com/v1/chat/completions"
            request = URLRequest(url: URL(string: baseURL)!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let model = provider == .grok ? "grok-4-latest" : "gpt-4o"
            body = [
                "model": model,
                "messages": [["role": "user", "content": prompt]]
            ]
            
            // X.ai needs valid system mappings, but user role is enough for a basic ping test.
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }
    
    private func parseResponse(data: Data, provider: AIProvider) throws -> APIResponse {
        do {
            if provider == .claude {
                return try JSONDecoder().decode(APIResponse.self, from: data)
            } else if provider == .gemini {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let candidates = json?["candidates"] as? [[String: Any]] ?? []
                let firstPartText = (candidates.first?["content"] as? [String: Any])?["parts"] as? [[String: Any]]
                let text = firstPartText?.first?["text"] as? String
                return APIResponse(content: [APIResponse.Content(type: "text", text: text)])
            } else {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let choices = json?["choices"] as? [[String: Any]] ?? []
                let text = (choices.first?["message"] as? [String: Any])?["content"] as? String
                return APIResponse(content: [APIResponse.Content(type: "text", text: text)])
            }
        } catch {
            throw LMError.parseError
        }
    }
    
    func saveAPIKey(_ key: String) throws {
        try upsertKey(key, account: keychainKey)
    }
    
    func readAPIKey() throws -> String? {
        try readKey(account: keychainKey)
    }
    
    func deleteAPIKey() throws {
        deleteKey(account: keychainKey)
    }
    
    private func upsertKey(_ key: String, account: String) throws {
        let data = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw LMError.networkError
        }
    }
    
    private func readKey(account: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        return key
    }
    
    private func deleteKey(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
