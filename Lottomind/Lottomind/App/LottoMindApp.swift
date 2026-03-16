// TASK-01 | LottoMindApp.swift | 2026-03-03

import SwiftUI
import SwiftData

@main
struct LottoMindApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [LotteryDraw.self, Recommendation.self, UserRecord.self])
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Task {
            await BackgroundTaskManager.shared.registerTasks()
        }
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Task {
            await BackgroundTaskManager.shared.scheduleNextFetch()
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("首页", systemImage: "house")
            }
            .tag(0)
            
            NavigationStack {
                AnalysisView()
            }
            .tabItem {
                Label("分析", systemImage: "chart.bar.doc.horizontal")
            }
            .tag(1)
            
            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label("探索", systemImage: "magnifyingglass")
            }
            .tag(2)
            
            NavigationStack {
                LedgerView()
            }
            .tabItem {
                Label("账本", systemImage: "book.closed")
            }
            .tag(3)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("设置", systemImage: "gearshape")
            }
            .tag(4)
        }
        .tint(LMColor.brand)
    }
}

#Preview {
    MainTabView()
}
