// TASK-01 | LatestDrawView.swift | 2026-03-03

import SwiftUI

struct LatestDrawView: View {
    let draw: LotteryDraw
    
    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                // 期号和日期
                HStack {
                    Text("第\(draw.period)期")
                        .font(LMFont.h3)
                    Spacer()
                    Text(draw.date.formatted(date: .abbreviated, time: .omitted))
                        .font(LMFont.callout)
                        .foregroundStyle(LMColor.textSecondary)
                }
                
                // 号码球
                HStack(spacing: 8) {
                    ForEach(draw.frontBalls, id: \.self) { number in
                        LottoBall(number: number, type: .red, size: .medium)
                    }
                    
                    Rectangle()
                        .fill(LMColor.divider)
                        .frame(width: 1, height: 20)
                    
                    ForEach(draw.backBalls, id: \.self) { number in
                        LottoBall(number: number, type: .blue, size: .medium)
                    }
                }
                
                // 操作按钮
                HStack {
                    Spacer()
                    Button("对比我的号码") {
                        // TODO: 跳转账本
                    }
                    .font(LMFont.callout)
                    .foregroundStyle(LMColor.brand)
                }
            }
        }
    }
}

#Preview {
    let draw = LotteryDraw(
        type: .ssq,
        period: "2026030",
        date: Date(),
        frontBalls: [5, 12, 19, 24, 28, 33],
        backBalls: [11],
        jackpot: 350_000_000
    )
    LatestDrawView(draw: draw)
}
