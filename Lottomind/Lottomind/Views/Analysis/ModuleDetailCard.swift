// TASK-01 | ModuleDetailCard.swift | 2026-03-03

import SwiftUI

struct ModuleDetailCard: View {
    let title: String
    let icon: String
    let score: Int
    let description: String
    
    @State private var isExpanded = false
    
    var body: some View {
        SectionCard {
            VStack(spacing: 0) {
                // 折叠态头部
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: icon)
                            .foregroundStyle(LMColor.brand)
                        Text(title)
                            .font(LMFont.h3)
                        Spacer()
                        Text("\(score)分")
                            .font(LMFont.h2)
                            .foregroundStyle(LMColor.brand)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(LMColor.textSecondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .buttonStyle(.plain)
                
                // 进度条
                ConfidenceBar(value: Double(score) / 100.0)
                    .padding(.top, 8)
                
                // 展开内容
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()
                        
                        Text(description)
                            .font(LMFont.body)
                            .foregroundStyle(LMColor.textBody)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

#Preview {
    VStack {
        ModuleDetailCard(
            title: "热号回避",
            icon: "flame",
            score: 82,
            description: "本模块模拟大众选号偏好，计算每个号码的被追捧程度。得分越高意味着该组号码越不受大众追捧，从反向思维角度更值得关注。"
        )
    }
    .padding()
}
