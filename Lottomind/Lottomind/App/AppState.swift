// TASK-01 | AppState.swift | 2026-03-03

import SwiftUI
import SwiftData

@Observable
class AppState {
    var isAPIKeyConfigured: Bool = false
    var currentLotteryType: LotteryType = .ssq
    var lastSyncDate: Date?
    var isAnalyzing: Bool = false
    var syncStatus: SyncStatus = .idle
}

enum SyncStatus {
    case idle
    case syncing
    case success(Date)
    case failed(LMError)
}

enum LMError: Error, LocalizedError {
    case apiKeyMissing
    case networkError
    case parseError
    case rateLimited
    case serverError
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "未配置 API Key"
        case .networkError:
            return "网络连接失败，请检查网络或配置"
        case .parseError:
            return "数据解析失败"
        case .rateLimited:
            return "请求过于频繁，请稍后再试"
        case .serverError:
            return "服务端发生错误，请重试"
        case .apiError(let message):
            return message
        }
    }
}
