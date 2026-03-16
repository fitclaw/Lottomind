// TASK-01 | LotteryType.swift | 2026-03-03

import Foundation

enum LotteryType: String, Codable, CaseIterable, Sendable {
    case ssq    // 双色球
    case dlt    // 大乐透
    case fc3d   // 福彩3D
    case qlc    // 七乐彩
    
    var displayName: String {
        switch self {
        case .ssq: return "双色球"
        case .dlt: return "大乐透"
        case .fc3d: return "福彩3D"
        case .qlc: return "七乐彩"
        }
    }
    
    var frontRange: ClosedRange<Int> {
        switch self {
        case .ssq: return 1...33
        case .dlt: return 1...35
        case .fc3d: return 0...9
        case .qlc: return 1...30
        }
    }
    
    var frontCount: Int {
        switch self {
        case .ssq: return 6
        case .dlt: return 5
        case .fc3d: return 3
        case .qlc: return 7
        }
    }
    
    var backRange: ClosedRange<Int>? {
        switch self {
        case .ssq: return 1...16
        case .dlt: return 1...12
        case .fc3d: return nil
        case .qlc: return 1...30
        }
    }
    
    var backCount: Int {
        switch self {
        case .ssq: return 1
        case .dlt: return 2
        case .fc3d: return 0
        case .qlc: return 1
        }
    }
    
    var drawDays: [Int] {
        switch self {
        case .ssq: return [2, 4, 7] // 周二、四、日
        case .dlt: return [1, 3, 6] // 周一、三、六
        case .fc3d: return [1, 2, 3, 4, 5, 6, 7] // 每日
        case .qlc: return [1, 3, 5] // 周一、三、五
        }
    }
}
