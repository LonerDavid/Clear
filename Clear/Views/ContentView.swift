// MARK: - Main App File
import SwiftUI
import Photos
import HealthKit
import UserNotifications

// MARK: - 修正的 ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        #if os(visionOS)
        TabView {
            
            ImmersiveTestView()
                .tabItem {
                    Label("測試用", systemImage: "hammer.fill")
                }
                .environmentObject(appState)
                .frame(width: 800, height: 600)
            
            UpdatedLandingPageView()
                .tabItem {
                    Label("主頁", systemImage: "house")
                }
                .environmentObject(appState)
                .frame(width: 800, height: 600)
                
            EmotionSelectionView()
                .tabItem {
                    Label("療癒小語", systemImage: "heart.fill")
                }
                .environmentObject(appState)
                .frame(width: 600, height: 500)
            
//            ImmersiveSpaceView()
//                .tabItem {
//                    Label("沉浸", systemImage: "sparkles")
//                }
//                .environmentObject(appState)
            
            DailyTaskView()
                .tabItem {
                    Label("每日任務", systemImage: "heart.text.square")
                }
                .environmentObject(appState)
                .frame(width: 1000, height: 800)
            
            EmotionReportView()
                .tabItem {
                    Label("情緒報告", systemImage: "list.clipboard.fill")
                }
                .environmentObject(appState)
                .frame(width: 800, height: 600)
            
//            ImmersiveTestView()
//                .tabItem {
//                    Label("測試用", systemImage: "hammer.fill")
//                }
//                .environmentObject(appState)
//                .frame(width: 800, height: 600)
            
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
                        DailyTasksView()
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


// MARK: - SuggestionCard.swift
struct SuggestionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}


// MARK: - 健康相關 UI 組件
struct HealthMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(10)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct HealthConnectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: "applewatch")
                .font(.title3)
            
            configuration.label
        }
        .font(.headline)
        .foregroundStyle(.white)
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 25)
        )
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

