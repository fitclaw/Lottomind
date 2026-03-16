// TASK-01 | RadarChartView.swift | 2026-03-03

import SwiftUI

struct RadarChartView: View {
    let moduleScores: [String: Double]
    
    private let labels = ["热号回避", "奖池压力", "序列衰减", "组合结构", "反常突变"]
    private let keys = ["M1", "M2", "M3", "M4", "M5"]
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2 - 10)
            let radius = size / 2 - 40
            
            ZStack {
                // 背景网格
                radarGrid(center: center, radius: radius)
                
                // 数据区域
                dataArea(center: center, radius: radius)
                
                // 轴标签
                axisLabels(center: center, radius: radius)
            }
        }
    }
    
    private func radarGrid(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<3) { i in
            let r = radius * CGFloat(i + 1) / 3
            PolygonShape(sides: 5, radius: r)
                .stroke(LMColor.divider, lineWidth: 0.5)
        }
    }
    
    private func dataArea(center: CGPoint, radius: CGFloat) -> some View {
        let values = keys.map { moduleScores[$0] ?? 0.5 }
        return PolygonShape(sides: 5, radius: radius, values: values)
            .fill(LMColor.brand.opacity(0.15))
            .overlay(
                PolygonShape(sides: 5, radius: radius, values: values)
                    .stroke(LMColor.brand, lineWidth: 2)
            )
    }
    
    private func axisLabels(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<5) { i in
            let angle = Double(i) * 72.0 * .pi / 180.0 - .pi / 2
            let x = center.x + (radius + 20) * cos(CGFloat(angle))
            let y = center.y + (radius + 20) * sin(CGFloat(angle))
            
            Text(labels[i])
                .font(LMFont.caption)
                .foregroundStyle(LMColor.textBody)
                .position(x: x, y: y)
        }
    }
}

// 五边形形状
struct PolygonShape: Shape {
    let sides: Int
    let radius: CGFloat
    var values: [Double]?
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        
        for i in 0..<sides {
            let angle = Double(i) * 2.0 * .pi / Double(sides) - .pi / 2
            let value = values?[i] ?? 1.0
            let r = radius * CGFloat(value)
            let x = center.x + r * cos(CGFloat(angle))
            let y = center.y + r * sin(CGFloat(angle))
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    RadarChartView(moduleScores: [
        "M1": 0.82,
        "M2": 0.76,
        "M3": 0.68,
        "M4": 0.85,
        "M5": 0.71
    ])
    .frame(height: 300)
}
