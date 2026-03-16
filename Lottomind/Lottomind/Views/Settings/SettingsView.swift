// TASK-01 | SettingsView.swift | 2026-03-03

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("defaultLotteryType") private var defaultType: LotteryType = .ssq
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    @State private var apiKeyStatus: APIKeyStatus = .notConfigured
    @State private var showAPIKeySheet = false
    @State private var showClearDataAlert = false
    
    enum APIKeyStatus {
        case configured(provider: AIProvider, lastFour: String)
        case notConfigured
        case verifying
        
        var description: String {
            switch self {
            case .configured(let provider, let lastFour):
                return "已配置 \(provider.displayName) · 尾号 ...\(lastFour)"
            case .notConfigured:
                return "未配置"
            case .verifying:
                return "验证中..."
            }
        }
        
        var color: Color {
            switch self {
            case .configured:
                return .green
            case .notConfigured:
                return .red
            case .verifying:
                return .orange
            }
        }
    }

    
    var body: some View {
        NavigationStack {
            List {
                // 数据服务
                Section("数据服务") {
                    NavigationLink(destination: APIKeyView()) {
                        HStack {
                            Text("API Key 管理")
                            Spacer()
                            Text(apiKeyStatus.description)
                                .foregroundStyle(apiKeyStatus.color)
                        }
                    }
                    
                    Picker("默认彩种", selection: $defaultType) {
                        ForEach(LotteryType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("数据同步")
                        Spacer()
                        Text("今天 21:35")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 通知
                Section("通知") {
                    Toggle("开奖提醒", isOn: $notificationsEnabled)
                    Toggle("分析完成提醒", isOn: $notificationsEnabled)
                    Toggle("中奖提醒", isOn: $notificationsEnabled)
                }
                
                // 数据管理
                Section("数据管理") {
                    Button("清除分析缓存") {
                        try? modelContext.delete(model: Recommendation.self)
                    }
                    .foregroundStyle(.primary)
                    
                    Button("清除全部数据") {
                        showClearDataAlert = true
                    }
                    .foregroundStyle(.red)
                }
                
                // 关于
                Section("关于") {
                    HStack {
                        Text("版本号")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink("免责声明") {
                        DisclaimerFullView()
                    }
                    
                    NavigationLink("隐私政策") {
                        PrivacyView()
                    }
                }
            }
            .navigationTitle("设置")
            .alert("确认清除全部数据？", isPresented: $showClearDataAlert) {
                Button("取消", role: .cancel) {}
                Button("确认清除", role: .destructive) {
                    try? modelContext.delete(model: UserRecord.self)
                    try? modelContext.delete(model: Recommendation.self)
                    try? modelContext.delete(model: LotteryDraw.self)
                }
            } message: {
                Text("包括开奖记录、分析结果和购彩记录。此操作不可撤销。")
            }
        }
        .onAppear {
            Task {
                if let key = try? await AIAPIClient.shared.readAPIKey(), !key.isEmpty {
                    let provider = AIAPIClient.detectProvider(from: key)
                    apiKeyStatus = .configured(provider: provider, lastFour: String(key.suffix(4)))
                } else {
                    apiKeyStatus = .notConfigured
                }
            }
        }
    }
}

struct APIKeyView: View {
    @State private var apiKey = ""
    @State private var isSecure = true
    @State private var statusMessage = ""
    @State private var currentVerificationTask: Task<Void, Never>? = nil
    
    var body: some View {
        Form {
            Section {
                Text("AI API Key 用于请求您选择的 AI 服务商接口，以便抓取开奖信息并生成统计型推荐。程序支持 Claude、OpenAI、Gemini 与 Grok。Key 默认仅保存在本机 Keychain；发起请求时会直接发送到对应服务商，不经过本项目自建服务器。")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            Section("API Key 配置") {
                HStack {
                    if isSecure {
                        SecureField("输入您的 AI API Key", text: $apiKey)
                    } else {
                        TextField("输入您的 AI API Key", text: $apiKey)
                    }
                    
                    Button(action: { isSecure.toggle() }) {
                        Image(systemName: isSecure ? "eye" : "eye.slash")
                    }
                    .buttonStyle(.plain)
                }
                .onChange(of: apiKey) { _, newValue in
                    autoVerify(key: newValue)
                }
                
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                Task {
                    if let key = try? await AIAPIClient.shared.readAPIKey() {
                        apiKey = key
                        statusMessage = "读取本机 Keychain 成功"
                    }
                }
            }
            
            Section("获取方式") {
                Text("请前往您使用的 AI 服务商控制台申请 API Key，再粘贴到这里完成验证与保存。")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("API Key 配置")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            currentVerificationTask?.cancel()
        }
    }
    
    private func autoVerify(key: String) {
        currentVerificationTask?.cancel()
        
        guard !key.isEmpty else {
            statusMessage = "请输入 API Key"
            return
        }
        
        statusMessage = "输入稳定，验证中..."
        
        currentVerificationTask = Task {
            do {
                // Debounce for 0.8 seconds
                try await Task.sleep(nanoseconds: 800_000_000)
                if Task.isCancelled { return }
                
                // Perform quick network validation ping
                try await AIAPIClient.shared.saveAPIKey(key)
                let provider = AIAPIClient.detectProvider(from: key)
                let response = try await AIAPIClient.shared.sendMessage(prompt: "Hello, this is a connection test. Reply with 'OK'.")
                
                if Task.isCancelled { return }
                
                if !response.content.isEmpty {
                    statusMessage = "连接成功！已识别为 \(provider.displayName)"
                } else {
                    statusMessage = "连接失败，接收到空响应。"
                }
            } catch is CancellationError {
                // Ignored
            } catch {
                if !Task.isCancelled {
                    statusMessage = "连接失败: \(error.localizedDescription)"
                }
            }
        }
    }
}


struct DisclaimerFullView: View {
    var body: some View {
        ScrollView {
            Text(disclaimerText)
                .padding()
        }
        .navigationTitle("免责声明")
    }
    
    private var disclaimerText: String {
        """
        LottoMind 是一款基于历史开奖数据与统计分析模型的彩票号码参考工具。
        
        1. 本应用提供的所有号码组合仅为统计分析参考，不构成任何中奖承诺、金融建议或投资建议。
        
        2. 彩票开奖结果具有随机性，任何分析方法都无法保证中奖。
        
        3. 请理性购彩，量力而行，并遵守您所在地区的适用法律与平台规则。
        
        4. 本应用不运营代购彩票服务，也不隶属于任何官方彩票发行机构。
        
        5. 除您主动配置的 AI 服务商 API Key 外，本应用不采集任何用户个人信息；所有本地数据仅存储在您的设备上。
        """
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            Text(privacyText)
                .padding()
        }
        .navigationTitle("隐私政策")
    }
    
    private var privacyText: String {
        """
        LottoMind 尊重并保护您的隐私。
        
        数据收集：
        本应用不收集任何用户个人信息。所有数据（包括购彩记录、分析结果）均仅存储在您的设备本地。
        
        API 通信：
        应用会直接连接您选择的 AI 服务商接口，以获取开奖信息并生成统计分析。API Key 仅存储在您设备的 Keychain 中，请求发出时会直接发送到对应服务商完成身份校验，不经过本项目自建服务器。
        
        数据安全：
        所有本地数据均受 iOS 系统安全机制保护。
        """
    }
}

#Preview {
    SettingsView()
}
