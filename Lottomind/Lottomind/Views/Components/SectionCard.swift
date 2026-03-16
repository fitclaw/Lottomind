// TASK-03 | SectionCard.swift | 2026-03-04
// AI-B: 通用卡片容器 - 支持标题和自定义内容

import SwiftUI

/// 通用卡片容器
/// 样式: cardBg 背景, 16pt 圆角, 20pt 内边距
/// 阴影: color 1A1A1A 8%, offset(0,2), blur 12
struct SectionCard<Content: View>: View {
    let title: String?
    let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: title != nil ? 12 : 0) {
            if let title = title {
                Text(title)
                    .font(LMFont.h2)
                    .foregroundStyle(LMColor.textPrimaryAdaptive)
            }
            
            content
                .padding(LMSize.cardPadding)
                .background(LMColor.cardBgAdaptive)
                .cornerRadius(LMSize.cardCorner)
                .shadow(
                    color: shadowColor,
                    radius: 12,
                    x: 0,
                    y: 2
                )
        }
    }
    
    /// 深色模式下阴影调整 (SPEC.md S14.2)
    private var shadowColor: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.3)
                : UIColor(Color(hex: "1A1A1A")).withAlphaComponent(0.08)
        })
    }
}

// MARK: - Previews

#Preview("SectionCard - 所有变体") {
    ScrollView {
        VStack(spacing: 20) {
            // 带标题的卡片
            SectionCard(title: "带标题的卡片") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("卡片内容区域")
                        .font(LMFont.body)
                    Text("可以放置任意视图")
                        .font(LMFont.callout)
                        .foregroundStyle(LMColor.textSecondary)
                }
            }
            
            // 无标题的卡片
            SectionCard {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(LMColor.brand)
                    Text("无标题的卡片")
                        .font(LMFont.body)
                    Spacer()
                }
            }
            
            // 复杂内容
            SectionCard(title: "复杂内容示例") {
                VStack(spacing: 12) {
                    HStack {
                        LottoBall(number: 8, type: .red, size: .small)
                        LottoBall(number: 16, type: .blue, size: .small)
                        Spacer()
                        Text("¥3.82亿")
                            .font(LMFont.h2)
                            .foregroundStyle(LMColor.brand)
                    }
                    
                    Divider()
                    
                    ConfidenceBar(value: 0.76, style: .full)
                }
            }
        }
        .padding()
    }
    .background(LMColor.pageBg)
}

#Preview("SectionCard - 深色模式") {
    VStack(spacing: 16) {
        SectionCard(title: "深色模式卡片") {
            Text("内容区域")
                .font(LMFont.body)
        }
    }
    .padding()
    .background(LMColor.pageBg)
    .preferredColorScheme(.dark)
}
