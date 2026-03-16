// TASK-01 | RecordEntryView.swift | 2026-03-03

import SwiftUI

struct RecordEntryView: View {
    let onSave: (UserRecord) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: LotteryType = .ssq
    @State private var period = "2026031"
    @State private var selectedRedBalls: Set<Int> = []
    @State private var selectedBlueBall: Int?
    @State private var cost = 2
    
    var isValid: Bool {
        selectedRedBalls.count == 6 && selectedBlueBall != nil && cost > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 彩种选择
                Section("彩种") {
                    Picker("彩种", selection: $selectedType) {
                        ForEach(LotteryType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
                
                // 期号
                Section("期号") {
                    TextField("期号", text: $period)
                        .keyboardType(.numberPad)
                }
                
                // 红球选择
                Section("选择红球 (已选 \(selectedRedBalls.count)/6)") {
                    BallGrid(
                        range: 1...33,
                        selectedBalls: selectedRedBalls,
                        maxSelection: 6,
                        type: .red
                    ) { number in
                        toggleRedBall(number)
                    }
                }
                
                // 蓝球选择
                Section("选择蓝球") {
                    BallGrid(
                        range: 1...16,
                        selectedBalls: selectedBlueBall.map { [$0] } ?? [],
                        maxSelection: 1,
                        type: .blue
                    ) { number in
                        selectedBlueBall = (selectedBlueBall == number) ? nil : number
                    }
                }
                
                // 金额
                Section("投入金额") {
                    TextField("金额", value: $cost, format: .number)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        ForEach([2, 10, 20], id: \.self) { amount in
                            Button("¥\(amount)") {
                                cost = amount
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("添加购彩记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func toggleRedBall(_ number: Int) {
        if selectedRedBalls.contains(number) {
            selectedRedBalls.remove(number)
        } else if selectedRedBalls.count < 6 {
            selectedRedBalls.insert(number)
        }
    }
    
    private func saveRecord() {
        guard let blueBall = selectedBlueBall else { return }
        
        let record = UserRecord(
            type: selectedType,
            period: period,
            frontBalls: Array(selectedRedBalls).sorted(),
            backBalls: [blueBall],
            cost: cost
        )
        onSave(record)
        dismiss()
    }
}

struct BallGrid: View {
    let range: ClosedRange<Int>
    let selectedBalls: Set<Int>
    let maxSelection: Int
    let type: BallType
    let onSelect: (Int) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(range, id: \.self) { number in
                let isSelected = selectedBalls.contains(number)
                let isDisabled = !isSelected && selectedBalls.count >= maxSelection
                
                LottoBall(
                    number: number,
                    type: type,
                    size: .small,
                    state: isSelected ? .selected : .inactive
                )
                .opacity(isDisabled ? 0.5 : 1.0)
                .onTapGesture {
                    if !isDisabled {
                        onSelect(number)
                    }
                }
            }
        }
    }
}

#Preview {
    RecordEntryView { _ in }
}
