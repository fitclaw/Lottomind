// TASK-01 | JackpotGauge.swift | 2026-03-03

import SwiftUI

struct JackpotGauge: View {
    let amount: Int
    let change: Double?
    let pressureIndex: Double
    
    var body: some View {
        SectionCard(title: "当前奖池") {
            VStack(alignment: .leading, spacing: 8) {
                Text(formatJackpot(amount))
                    .font(LMFont.h1)
                
                if let change = change {
                    HStack(spacing: 4) {
                        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("较上期\(change >= 0 ? "增长" : "下降") \(abs(change), specifier: "%.0f")%")
                    }
                    .font(LMFont.callout)
                    .foregroundStyle(change >= 0 ? LMColor.success : LMColor.error)
                }
                
                // 压力指数条
                VStack(alignment: .leading, spacing: 4) {
                    Text("压力指数")
                        .font(LMFont.caption)
                        .foregroundStyle(LMColor.textSecondary)
                    
                    HStack {
                        ConfidenceBar(value: min(pressureIndex / 3.0, 1.0))
                        Text(String(format: "%.2f", pressureIndex))
                            .font(LMFont.callout.bold())
                            .foregroundStyle(LMColor.textPrimary)
                    }
                }
            }
        }
    }
    
    private func formatJackpot(_ amount: Int) -> String {
        switch amount {
        case 100_000_000...:
            return String(format: "¥%.2f亿", Double(amount) / 100_000_000)
        case 10_000...:
            return String(format: "¥%.0f万", Double(amount) / 10_000)
        default:
            return "¥\(amount)"
        }
    }
}

#Preview {
    JackpotGauge(amount: 382_000_000, change: 12.0, pressureIndex: 1.62)
}
