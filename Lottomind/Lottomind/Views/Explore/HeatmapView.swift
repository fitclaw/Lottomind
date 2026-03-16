// TASK-01 | HeatmapView.swift | 2026-03-03

import SwiftUI

struct HeatmapView: View {
    let data: [Int: Double]
    
    private let columns = 7
    private let rows = 5
    
    var body: some View {
        VStack(spacing: 12) {
            // 热力图网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 6) {
                ForEach(1...33, id: \.self) { number in
                    NumberCell(
                        number: number,
                        intensity: data[number] ?? 0.0
                    )
                }
            }
            
            // 色阶图例
            HStack {
                Text("冷")
                    .font(LMFont.caption)
                    .foregroundStyle(LMColor.textSecondary)
                
                LinearGradient(
                    colors: [LMColor.sectionBg, LMColor.brandLight, LMColor.brand],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 12)
                .cornerRadius(6)
                
                Text("热")
                    .font(LMFont.caption)
                    .foregroundStyle(LMColor.textSecondary)
            }
        }
    }
}

struct NumberCell: View {
    let number: Int
    let intensity: Double
    
    var body: some View {
        Text(String(format: "%02d", number))
            .font(LMFont.callout.bold())
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(backgroundColor)
            .cornerRadius(10)
    }
    
    private var backgroundColor: Color {
        // 色阶插值
        if intensity < 0.5 {
            return LMColor.sectionBg
        } else if intensity < 0.8 {
            return LMColor.brandLight
        } else {
            return LMColor.brand
        }
    }
    
    private var textColor: Color {
        intensity >= 0.6 ? .white : LMColor.textBody
    }
}

#Preview {
    var sampleData: [Int: Double] = [:]
    for i in 1...33 {
        sampleData[i] = Double.random(in: 0...1)
    }
    return HeatmapView(data: sampleData)
        .padding()
}
