// TASK-03 | LottoBall.swift | 2026-03-04
// AI-B: 完善号码球组件 - 支持3种尺寸×4种状态完整矩阵

import SwiftUI

enum BallType {
    case red
    case blue
}

enum BallSize {
    case large
    case medium
    case small
}

enum BallState {
    case `default`
    case selected
    case hit
    case inactive
}

struct LottoBall: View {
    let number: Int
    let type: BallType
    let size: BallSize
    let state: BallState
    let disabled: Bool
    
    init(
        number: Int,
        type: BallType,
        size: BallSize,
        state: BallState = .default,
        disabled: Bool = false
    ) {
        self.number = number
        self.type = type
        self.size = size
        self.state = state
        self.disabled = disabled
    }
    
    // MARK: - Dimensions
    
    private var dimension: CGFloat {
        switch size {
        case .large: return LMSize.ballLarge
        case .medium: return LMSize.ballMedium
        case .small: return LMSize.ballSmall
        }
    }
    
    private var font: Font {
        switch size {
        case .large: return LMFont.ballLarge
        case .medium: return LMFont.ballMedium
        case .small: return LMFont.ballSmall
        }
    }
    
    private var checkmarkSize: CGFloat {
        switch size {
        case .large: return 14
        case .medium: return 10
        case .small: return 0  // 小号不显示对勾
        }
    }
    
    // MARK: - Colors (状态矩阵见 SPEC.md S14.1)
    
    private var backgroundColor: Color {
        switch state {
        case .default:
            return type == .red ? LMColor.redBall : LMColor.blueBall
        case .selected:
            // 深色系 + 描边效果通过叠加实现
            return type == .red ? Color(hex: "B8553A") : Color(hex: "3A6A9A")
        case .hit:
            return LMColor.hitBall
        case .inactive:
            return LMColor.inactiveBall
        }
    }
    
    private var foregroundColor: Color {
        state == .inactive ? LMColor.textSecondary : .white
    }
    
    private var strokeColor: Color? {
        switch state {
        case .selected:
            return type == .red ? Color(hex: "B8553A") : Color(hex: "3A6A9A")
        case .hit:
            return LMColor.hitBall
        case .default, .inactive:
            return nil
        }
    }
    
    private var strokeWidth: CGFloat {
        switch state {
        case .selected, .hit: return 2
        case .default, .inactive: return 0
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 主球体
            Circle()
                .fill(backgroundColor)
                .overlay(
                    Group {
                        if let strokeColor = strokeColor {
                            Circle()
                                .stroke(strokeColor, lineWidth: strokeWidth)
                        }
                    }
                )
            
            // 数字
            Text(String(format: "%02d", number))
                .font(font)
                .monospacedDigit()
                .foregroundStyle(foregroundColor)
            
            // Hit 状态对勾标记 (仅大号和中号显示)
            if state == .hit && checkmarkSize > 0 {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.system(size: checkmarkSize, weight: .bold))
                            .foregroundStyle(.white)
                            .offset(x: -4, y: 4)
                    }
                    Spacer()
                }
            }
        }
        .frame(width: dimension, height: dimension)
        .opacity(disabled ? 0.4 : 1.0)
        .accessibilityLabel(accessibilityLabel)
    }
    
    // MARK: - Accessibility
    
    private var accessibilityLabel: String {
        let ballType = type == .red ? "红球" : "蓝球"
        let stateDesc: String
        switch state {
        case .hit:
            stateDesc = "已命中"
        case .selected:
            stateDesc = "已选中"
        case .inactive:
            stateDesc = "未激活"
        case .default:
            stateDesc = ""
        }
        return "\(ballType) \(String(format: "%02d", number)) \(stateDesc)".trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Previews

#Preview("LottoBall - 状态矩阵") {
    ScrollView {
        VStack(spacing: 24) {
            // 红球状态
            Group {
                Text("红球 - Large").font(LMFont.h3)
                HStack(spacing: 12) {
                    VStack {
                        LottoBall(number: 8, type: .red, size: .large, state: .default)
                        Text("default").font(LMFont.caption)
                    }
                    VStack {
                        LottoBall(number: 8, type: .red, size: .large, state: .selected)
                        Text("selected").font(LMFont.caption)
                    }
                    VStack {
                        LottoBall(number: 8, type: .red, size: .large, state: .hit)
                        Text("hit").font(LMFont.caption)
                    }
                    VStack {
                        LottoBall(number: 8, type: .red, size: .large, state: .inactive)
                        Text("inactive").font(LMFont.caption)
                    }
                }
            }
            
            Divider()
            
            // 蓝球状态
            Group {
                Text("蓝球 - Medium").font(LMFont.h3)
                HStack(spacing: 12) {
                    VStack {
                        LottoBall(number: 16, type: .blue, size: .medium, state: .default)
                        Text("default").font(LMFont.caption)
                    }
                    VStack {
                        LottoBall(number: 16, type: .blue, size: .medium, state: .selected)
                        Text("selected").font(LMFont.caption)
                    }
                    VStack {
                        LottoBall(number: 16, type: .blue, size: .medium, state: .hit)
                        Text("hit").font(LMFont.caption)
                    }
                    VStack {
                        LottoBall(number: 16, type: .blue, size: .medium, state: .inactive)
                        Text("inactive").font(LMFont.caption)
                    }
                }
            }
            
            Divider()
            
            // 小号球
            Group {
                Text("Small 尺寸").font(LMFont.h3)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { i in
                        LottoBall(number: i * 3, type: .red, size: .small, state: .default)
                    }
                }
            }
            
            Divider()
            
            // 禁用态
            Group {
                Text("Disabled 态").font(LMFont.h3)
                HStack(spacing: 12) {
                    LottoBall(number: 5, type: .red, size: .medium, state: .inactive, disabled: true)
                    LottoBall(number: 12, type: .blue, size: .medium, state: .inactive, disabled: true)
                }
            }
        }
        .padding()
    }
}

#Preview("LottoBall - 实际场景") {
    VStack(spacing: 20) {
        // 首页推荐样式
        HStack(spacing: 8) {
            ForEach([3, 11, 18, 22, 29, 31], id: \.self) { num in
                LottoBall(number: num, type: .red, size: .large)
            }
            Rectangle()
                .fill(LMColor.divider)
                .frame(width: 1, height: 20)
            LottoBall(number: 9, type: .blue, size: .large)
        }
        
        // 选号器样式
        HStack(spacing: 6) {
            ForEach([3, 11, 18], id: \.self) { num in
                LottoBall(number: num, type: .red, size: .small, state: .selected)
            }
            ForEach([22, 29, 31], id: \.self) { num in
                LottoBall(number: num, type: .red, size: .small, state: .inactive)
            }
        }
        
        // 开奖对比样式
        HStack(spacing: 6) {
            ForEach([3, 11, 18, 22, 29, 31], id: \.self) { num in
                let isHit = [3, 11, 22].contains(num)
                LottoBall(number: num, type: .red, size: .small, state: isHit ? .hit : .inactive)
            }
        }
    }
    .padding()
}
