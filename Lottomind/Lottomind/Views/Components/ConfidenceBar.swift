// TASK-03 | ConfidenceBar.swift | 2026-03-04
// AI-B: 置信度进度条组件 - 支持 full/compact 两种样式

import SwiftUI

enum BarStyle {
    case full
    case compact
}

struct ConfidenceBar: View {
    let value: Double
    let style: BarStyle
    
    init(value: Double, style: BarStyle = .full) {
        self.value = max(0, min(1, value))
        self.style = style
    }
    
    // MARK: - Colors
    
    private var barColor: Color {
        if value >= 0.75 {
            return LMColor.success
        } else if value >= 0.4 {
            return LMColor.warning
        } else {
            return LMColor.textPlaceholder
        }
    }
    
    private var percentageText: String {
        String(format: "%d%%", Int(value * 100))
    }
    
    // MARK: - Body
    
    var body: some View {
        switch style {
        case .full:
            fullStyleBody
        case .compact:
            compactStyleBody
        }
    }
    
    // Full 样式：标签 + 进度条 + 百分比
    private var fullStyleBody: some View {
        HStack(spacing: 12) {
            Text("置信度")
                .font(LMFont.callout)
                .foregroundStyle(LMColor.textSecondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LMColor.sectionBg)
                    
                    // 进度
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geometry.size.width * value)
                }
            }
            .frame(height: 8)
            
            Text(percentageText)
                .font(LMFont.callout.weight(.bold))
                .foregroundStyle(LMColor.textPrimary)
                .frame(minWidth: 36, alignment: .trailing)
        }
        .frame(height: 20)
    }
    
    // Compact 样式：仅进度条
    private var compactStyleBody: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 4)
                    .fill(LMColor.sectionBg)
                
                // 进度
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(width: geometry.size.width * value)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Previews

#Preview("ConfidenceBar - 所有变体") {
    VStack(spacing: 24) {
        // Full 样式示例
        Group {
            Text("Full Style").font(LMFont.h3)
            
            VStack(spacing: 12) {
                ConfidenceBar(value: 0.85, style: .full)
                ConfidenceBar(value: 0.76, style: .full)
                ConfidenceBar(value: 0.55, style: .full)
                ConfidenceBar(value: 0.32, style: .full)
            }
        }
        
        Divider()
        
        // Compact 样式示例
        Group {
            Text("Compact Style").font(LMFont.h3)
            
            VStack(spacing: 16) {
                ConfidenceBar(value: 0.85, style: .compact)
                ConfidenceBar(value: 0.55, style: .compact)
                ConfidenceBar(value: 0.25, style: .compact)
            }
        }
        
        Divider()
        
        // 颜色阈值示例
        Group {
            Text("颜色阈值: ≥75% 绿色 / 40-74% 黄色 / <40% 灰色").font(LMFont.callout)
            HStack(spacing: 8) {
                ConfidenceBar(value: 0.75, style: .full)
                    .frame(width: 150)
                ConfidenceBar(value: 0.40, style: .full)
                    .frame(width: 150)
            }
        }
    }
    .padding()
}
