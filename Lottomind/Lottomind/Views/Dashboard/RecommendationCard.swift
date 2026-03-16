// TASK-01 | RecommendationCard.swift | 2026-03-03

import SwiftUI

struct RecommendationCard: View {
    let recommendation: Recommendation
    
    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                // 标题行
                HStack {
                    Text("\(recommendation.type.displayName) · 第\(recommendation.period)期")
                        .font(LMFont.h3)
                    Spacer()
                    Text("置信度 \(Int(recommendation.confidence * 100))%")
                        .font(LMFont.callout)
                        .foregroundStyle(LMColor.brand)
                }
                
                // 号码球
                HStack(spacing: 8) {
                    ForEach(recommendation.frontBalls, id: \.self) { number in
                        LottoBall(number: number, type: .red, size: .medium)
                    }
                    
                    Rectangle()
                        .fill(LMColor.divider)
                        .frame(width: 1, height: 20)
                    
                    ForEach(recommendation.backBalls, id: \.self) { number in
                        LottoBall(number: number, type: .blue, size: .medium)
                    }
                }
                
                // 算法解读
                if !recommendation.explanation.isEmpty {
                    Text(recommendation.explanation)
                        .font(LMFont.body)
                        .foregroundStyle(LMColor.textBody)
                        .lineLimit(3)
                        .padding(12)
                        .background(LMColor.sectionBg)
                        .cornerRadius(12)
                }
            }
        }
    }
}

#Preview {
    let rec = Recommendation(
        type: .ssq,
        period: "2026031",
        frontBalls: [3, 11, 18, 22, 29, 31],
        backBalls: [9],
        confidence: 0.76,
        explanation: "本期奖池水位偏高，模型倾向离散型号码组合。"
    )
    RecommendationCard(recommendation: rec)
}
