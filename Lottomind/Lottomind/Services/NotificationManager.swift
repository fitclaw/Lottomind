// TASK-01 | NotificationManager.swift | 2026-03-03

import Foundation
import UserNotifications

actor NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            return false
        }
    }
    
    func sendDataUpdateNotification(type: LotteryType, period: String) async {
        let content = UNMutableNotificationContent()
        content.title = "开奖数据已更新"
        content.body = "\(type.displayName)第\(period)期数据已更新，点击查看分析"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "data-update-\(period)",
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    func sendAnalysisCompleteNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "分析完成"
        content.body = "新一期推荐号码已生成"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "analysis-complete",
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    func sendWinNotification(hitCount: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "开奖结果"
        content.body = "您的号码命中了 \(hitCount) 个红球"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "win-\(hitCount)",
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
}
