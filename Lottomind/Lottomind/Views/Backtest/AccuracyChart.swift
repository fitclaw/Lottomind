// TASK-01 | AccuracyChart.swift | 2026-03-03

import SwiftUI
import Charts

struct AccuracyChart: View {
    let data: [AccuracyPoint]
    let averageHits: Double
    
    init(data: [AccuracyPoint] = [], averageHits: Double = 0.0) {
        self.data = data
        self.averageHits = averageHits
    }
    
    var body: some View {
        SectionCard(title: "命中走势") {
            if data.isEmpty {
                Text("暂无数据")
                    .foregroundStyle(LMColor.textSecondary)
                    .frame(height: 160)
            } else {
                Chart(data) { point in
                    LineMark(
                        x: .value("期号", point.period),
                        y: .value("命中数", point.hits)
                    )
                    .foregroundStyle(LMColor.brand)
                    
                    PointMark(
                        x: .value("期号", point.period),
                        y: .value("命中数", point.hits)
                    )
                    .foregroundStyle(point.hits >= 3 ? LMColor.success : LMColor.brand)
                    
                    RuleMark(y: .value("均值", averageHits))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(LMColor.textSecondary)
                        .annotation(position: .top, alignment: .trailing) {
                            Text(String(format: "均值 %.1f", averageHits))
                                .font(LMFont.caption)
                                .foregroundStyle(LMColor.textSecondary)
                        }
                }
                .frame(height: 160)
            }
        }
    }
}

struct AccuracyPoint: Identifiable {
    let id = UUID()
    let period: String
    let hits: Int
}

#Preview {
    AccuracyChart()
}
