// TASK-01 | ColdHotRanking.swift | 2026-03-03

import SwiftUI

struct ColdHotRanking: View {
    let hotBalls: [Int]
    let coldBalls: [Int]
    let warmingBalls: [Int]
    
    var body: some View {
        HStack(spacing: 12) {
            // 最热
            RankingColumn(
                title: "🔥 最热",
                balls: hotBalls,
                state: .default
            )
            
            // 最冷
            RankingColumn(
                title: "❄️ 最冷",
                balls: coldBalls,
                state: .inactive
            )
            
            // 升温
            RankingColumn(
                title: "📈 升温",
                balls: warmingBalls,
                state: .selected
            )
        }
    }
}

struct RankingColumn: View {
    let title: String
    let balls: [Int]
    let state: BallState
    
    var body: some View {
        SectionCard(title: title) {
            VStack(spacing: 8) {
                ForEach(balls.prefix(5), id: \.self) { number in
                    HStack {
                        LottoBall(number: number, type: .red, size: .small, state: state)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    ColdHotRanking(
        hotBalls: [7, 12, 19, 23, 28],
        coldBalls: [3, 18, 5, 31, 9],
        warmingBalls: [9, 22, 15, 6, 27]
    )
    .padding()
}
