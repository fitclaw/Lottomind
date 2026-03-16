// TASK-02 | TypographyTokens.swift | 2026-03-04
// AI-B: 设计系统Token实现

import SwiftUI

enum LMFont {
    static let display    = Font.system(size: 36, weight: .bold, design: .rounded)
    static let h1         = Font.system(size: 28, weight: .bold)
    static let h2         = Font.system(size: 22, weight: .semibold)
    static let h3         = Font.system(size: 19, weight: .semibold)
    static let body       = Font.system(size: 17, weight: .regular)
    static let callout    = Font.system(size: 15, weight: .regular)
    static let footnote   = Font.system(size: 14, weight: .regular)
    static let caption    = Font.system(size: 13, weight: .regular)
    static let ballLarge  = Font.system(size: 28, weight: .bold, design: .rounded)
    static let ballMedium = Font.system(size: 20, weight: .bold, design: .rounded)
    static let ballSmall  = Font.system(size: 15, weight: .semibold, design: .rounded)
}
