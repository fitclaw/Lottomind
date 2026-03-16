// TASK-02 | SpacingTokens.swift | 2026-03-04
// AI-B: 设计系统Token实现

import CoreGraphics

enum LMSize {
    // 号码球
    static let ballLarge:  CGFloat = 52  // 首页推荐
    static let ballMedium: CGFloat = 40  // 分析页
    static let ballSmall:  CGFloat = 32  // 列表内嵌

    // 按钮
    static let buttonHeight: CGFloat = 52  // 主按钮
    static let buttonHeightSecondary: CGFloat = 48

    // 卡片
    static let cardCorner: CGFloat = 16
    static let cardPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 16

    // 间距
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
}
