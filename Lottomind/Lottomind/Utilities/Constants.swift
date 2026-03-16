// TASK-01 | Constants.swift | 2026-03-03

import Foundation

enum Constants {
    // MARK: - App Info
    static let appName = "LottoMind"
    static let bundleID = "io.github.lottomind.app"
    
    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastSyncDate = "lastSyncDate"
        static let defaultLotteryType = "defaultLotteryType"
    }
    
    // MARK: - Keychain Keys
    enum KeychainKeys {
        static let aiAPIKey = "\(Constants.bundleID).ai-api-key"
    }
    
    // MARK: - Notification Identifiers
    enum Notifications {
        static let dataUpdate = "\(Constants.bundleID).notification.data-update"
        static let analysisComplete = "\(Constants.bundleID).notification.analysis-complete"
        static let winResult = "\(Constants.bundleID).notification.win-result"
    }
    
    // MARK: - Background Task Identifiers
    enum BackgroundTasks {
        static let fetch = "\(Constants.bundleID).background-fetch"
    }
    
    // MARK: - Algorithm Constants
    enum Algorithm {
        static let defaultSampleSize = 10000  // 蒙特卡洛采样数
        static let historyLookbackDays = 90   // 历史数据回溯天数
    }
}
