// TASK-02 | ColorTokens.swift | 2026-03-04
// AI-B: 完善深色模式适配

import SwiftUI

enum LMColor {
    // 品牌色
    static let brand          = Color(hex: "DA7756")  // 赤陶橙
    static let brandDark      = Color(hex: "B8553A")  // 深赤陶（按压态）
    static let brandLight     = Color(hex: "F3E0D8")  // 淡桃（背景块）

    // 中性色
    static let pageBg         = Color(hex: "FFFAF5")  // 暖白（页面底色）
    static let cardBg         = Color.white            // 卡片底色
    static let sectionBg      = Color(hex: "F5F0EB")  // 暖灰（分区底色）
    static let divider        = Color(hex: "E8E0D8")  // 沙色（分割线）
    static let borderLight    = Color(hex: "D5CEC6")  // 暖石（边框）

    // 文字色
    static let textPrimary    = Color(hex: "1A1A1A")  // 主标题/号码
    static let textBody       = Color(hex: "3D3D3D")  // 正文
    static let textSecondary  = Color(hex: "6B6360")  // 辅助文字
    static let textPlaceholder = Color(hex: "A89F98") // 占位符

    // 功能色
    static let success        = Color(hex: "2D8A56")  // 命中/成功
    static let warning        = Color(hex: "D4940A")  // 提醒/关注
    static let error          = Color(hex: "C4483E")  // 错误/未中
    static let info           = Color(hex: "4A7FB5")  // 信息/蓝球

    // 号码球
    static let redBall        = Color(hex: "DA7756")  // 红球 = 品牌色
    static let blueBall       = Color(hex: "4A7FB5")  // 蓝球 = 信息蓝
    static let hitBall        = Color(hex: "2D8A56")  // 命中球
    static let inactiveBall   = Color(hex: "E8E0D8")  // 未激活球
}

// Color 扩展支持 Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// 深色模式适配
extension LMColor {
    static var pageBgAdaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "1C1917"))
                : UIColor(pageBg)
        })
    }
    
    static var cardBgAdaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "292524"))
                : UIColor(cardBg)
        })
    }
    
    static var sectionBgAdaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "1C1917"))
                : UIColor(sectionBg)
        })
    }
    
    static var textPrimaryAdaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "F5F0EB"))
                : UIColor(textPrimary)
        })
    }
    
    static var textBodyAdaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "D6D0CA"))
                : UIColor(textBody)
        })
    }
    
    static var textSecondaryAdaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "A89F98"))
                : UIColor(textSecondary)
        })
    }
    
    static var dividerAdaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "3D3530"))
                : UIColor(divider)
        })
    }
    
    static var brandAdaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "E8956F"))
                : UIColor(brand)
        })
    }
}
