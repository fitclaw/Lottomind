// TASK-02 | ComponentStyles.swift | 2026-03-04
// AI-B: 设计系统Token实现 - 四种按钮样式

import SwiftUI

// MARK: - Button Styles

enum LMButtonStyle {
    case primary
    case secondary
    case ghost
    case text
}

struct LMButton: View {
    let title: String
    let style: LMButtonStyle
    let action: () -> Void
    
    init(_ title: String, style: LMButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LMFont.callout.weight(.semibold))
                .frame(maxWidth: style == .primary ? .infinity : nil)
                .padding(.horizontal, style == .primary ? 0 : 16)
                .frame(height: style == .primary ? LMSize.buttonHeight : LMSize.buttonHeightSecondary)
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .cornerRadius(12)
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return LMColor.brand
        case .secondary:
            return LMColor.sectionBg
        case .ghost, .text:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return LMColor.textPrimary
        case .ghost, .text:
            return LMColor.brand
        }
    }
}

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LMFont.callout.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: LMSize.buttonHeight)
            .background(LMColor.brand)
            .foregroundStyle(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LMFont.callout.weight(.semibold))
            .padding(.horizontal, 16)
            .frame(height: LMSize.buttonHeightSecondary)
            .background(LMColor.sectionBg)
            .foregroundStyle(LMColor.textPrimary)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Ghost Button Style

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LMFont.callout.weight(.semibold))
            .padding(.horizontal, 16)
            .frame(height: LMSize.buttonHeightSecondary)
            .foregroundStyle(LMColor.brand)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        LMButton("主要按钮", style: .primary) {}
        LMButton("次要按钮", style: .secondary) {}
        LMButton("幽灵按钮", style: .ghost) {}
        LMButton("文字按钮", style: .text) {}
    }
    .padding()
}
