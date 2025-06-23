// MARK: - Main App File
import SwiftUI
import Photos
import HealthKit
import UserNotifications
#if os(visionOS)
import _RealityKit_SwiftUI
#endif

// MARK: - 修正的 ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    #if os(visionOS)
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    #endif
    
    var body: some View {
        #if os(visionOS)
        TabView {
            DraggableYellowHeartView()
//            ImmersiveTestView()
                .tabItem {
                    Label("測試用", systemImage: "hammer.fill")
                }
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 480)
            
            UpdatedLandingPageView()
                .tabItem {
                    Label("主頁", systemImage: "house")
                }
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 480)
                
            EmotionSelectionView()
                .tabItem {
                    Label("療癒小語", systemImage: "heart.fill")
                }
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 480)
            
            DailyTaskView()
                .tabItem {
                    Label("每日任務", systemImage: "heart.text.square")
                }
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 480)
            
            EmotionReportView()
                .tabItem {
                    Label("情緒報告", systemImage: "list.clipboard.fill")
                }
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 480)
            
        }
        .preferredColorScheme(.dark)
        .environmentObject(appState)

        
        #else
        NavigationStack {
            ZStack {
                // 主要界面導航
                Group {
                    switch appState.currentView {
                    case .landing:
                        UpdatedLandingPageView() // 使用新的主頁面
                    case .emotionSelection:
                        EmotionSelectionView()
                    case .immersiveSpace:
                        ImmersiveSpaceView() // 使用原本的沉浸式視圖
                    case .emotionReport:
                        EmotionReportView()
                    case .dailyTasks:
                        DailyTaskView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .preferredColorScheme(.dark)
        .environmentObject(appState)
        #endif
    }
}

#Preview {
    ContentView()
}


