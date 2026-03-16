// TASK-01 | BackgroundTaskManager.swift | 2026-03-03

import Foundation
import BackgroundTasks

actor BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    static let taskIdentifier = Constants.BackgroundTasks.fetch
    
    private let dataFetcher = AIDataFetcher.shared
    private let notificationManager = NotificationManager.shared
    
    private init() {}
    
    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let self = self else { return }
            Task {
                await self.handleBackgroundTask(task as! BGAppRefreshTask)
            }
        }
    }
    
    func scheduleNextFetch() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Calendar.current.date(bySettingHour: 21, minute: 30, second: 0, of: Date())
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("无法调度后台任务: \(error)")
        }
    }
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) async {
        scheduleNextFetch()
        
        task.expirationHandler = {
            // 任务即将过期时的清理
        }
        
        do {
            // 获取最新开奖数据
            _ = try await dataFetcher.fetchLatestDraw(type: .ssq)
            // 存入 SwiftData
            // 运行算法
            // 发送通知
            await notificationManager.sendAnalysisCompleteNotification()
            task.setTaskCompleted(success: true)
        } catch {
            // 记录失败原因
            task.setTaskCompleted(success: false)
        }
    }
}
