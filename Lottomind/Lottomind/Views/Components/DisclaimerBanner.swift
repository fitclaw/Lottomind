// TASK-03 | DisclaimerBanner.swift | 2026-03-04
// AI-B: 免责声明横幅 - 固定合规文案

import SwiftUI

/// 免责声明横幅
/// 固定文案: "⚠️ 以上号码仅为统计分析参考，不构成任何中奖承诺"
/// 样式: sectionBg 背景, caption 字号, textSecondary 颜色, 8pt 圆角
struct DisclaimerBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(LMFont.caption)
                .foregroundStyle(LMColor.warning)
            
            Text("⚠️ 以上号码仅为统计分析参考，不构成任何中奖承诺")
                .font(LMFont.caption)
                .foregroundStyle(LMColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LMColor.sectionBg)
        .cornerRadius(8)
    }
}

// MARK: - Previews

#Preview("DisclaimerBanner") {
    VStack(spacing: 16) {
        DisclaimerBanner()
        
        // 深色模式预览
        DisclaimerBanner()
            .preferredColorScheme(.dark)
    }
    .padding()
    .background(LMColor.pageBg)
}

#Preview("DisclaimerBanner - 实际场景") {
    VStack(spacing: 0) {
        SectionCard(title: "今日推荐") {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    LottoBall(number: 3, type: .red, size: .medium)
                    LottoBall(number: 11, type: .red, size: .medium)
                    LottoBall(number: 18, type: .red, size: .medium)
                    LottoBall(number: 22, type: .red, size: .medium)
                    LottoBall(number: 29, type: .red, size: .medium)
                    LottoBall(number: 31, type: .red, size: .medium)
                    Rectangle()
                        .fill(LMColor.divider)
                        .frame(width: 1, height: 16)
                    LottoBall(number: 9, type: .blue, size: .medium)
                }
                
                ConfidenceBar(value: 0.76, style: .full)
                
                DisclaimerBanner()
            }
        }
    }
    .padding()
    .background(LMColor.pageBg)
}
