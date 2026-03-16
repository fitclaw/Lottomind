// TASK-01 | Date+Ext.swift | 2026-03-03

import Foundation

extension Date {
    /// 返回 yyyy-MM-dd 格式的字符串
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /// 返回 yyyy年MM月dd日 格式的字符串
    var formattedChineseDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: self)
    }
    
    /// 获取日期是星期几 (1=周日, 2=周一...)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    /// 获取日期的年月日
    var ymd: (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return (components.year!, components.month!, components.day!)
    }
    
    /// 获取当天开始时间
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// 获取当天结束时间
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    /// 减去指定天数
    func minus(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self)!
    }
    
    /// 加上指定天数
    func plus(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}
