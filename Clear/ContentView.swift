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
        NavigationStack {
            ZStack {
                // 背景圖片 - 添加 allowsHitTesting(false) 讓點擊事件穿透
//                Image("Immersive")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .clipped()
//                    .ignoresSafeArea()
//                    .allowsHitTesting(false) // 🔑
                
                // 可選：在圖片上加一層半透明遮罩以提高文字可讀性
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(false) // 🔑 遮罩層也不攔截點擊事件
                
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
        .environmentObject(appState)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

// MARK: - MemoryPhotosView.swift
struct MemoryPhotosView: View {
    let photos: [String]
    let screenSize: CGSize
    @State private var showPhotos = false
    
    var body: some View {
        ZStack {
            ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                MemoryPhotoCard(photo: photo, index: index, screenSize: screenSize)
                    .opacity(showPhotos ? 1 : 0)
                    .scaleEffect(showPhotos ? 1 : 0.3)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.6)
                        .delay(Double(index) * 0.2),
                        value: showPhotos
                    )
            }
        }
        .onAppear {
            withAnimation {
                showPhotos = true
            }
        }
    }
}

// MARK: - MemoryPhotoCard.swift
struct MemoryPhotoCard: View {
    let photo: String
    let index: Int
    let screenSize: CGSize
    @State private var rotation: Double = 0
    
    var body: some View {
        Text(photo)
            .font(.system(size: 50))
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .rotationEffect(.degrees(rotation))
            .position(
                x: CGFloat.random(in: 60...screenSize.width-60),
                y: CGFloat.random(in: 150...screenSize.height-150)
            )
            .onAppear {
                rotation = Double.random(in: -15...15)
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    rotation += Double.random(in: -5...5)
                }
            }
    }
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

// MARK: - DailyTasksView.swift
struct DailyTasksView: View {
    @EnvironmentObject var appState: AppState
    @State private var showTasks = false
    
    private let tasks = [
        DailyTask(
            title: "冥想",
            subtitle: "短期舒壓任務",
            duration: "3分鐘",
            character: "🧘‍♀️",
            color: .green,
            description: "透過正念冥想，讓心靈回到平靜狀態"
        ),
        DailyTask(
            title: "時空膠囊",
            subtitle: "長期任務卡",
            duration: "記錄美好",
            character: "📝",
            color: .orange,
            description: "記錄今天的美好時刻，為未來的自己留下溫暖"
        ),
        DailyTask(
            title: "聽音樂",
            subtitle: "快速任務卡",
            duration: "30秒",
            character: "🎧",
            color: .yellow,
            description: "聆聽療癒音樂，讓音符撫慰你的心靈"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("每日任務卡")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .opacity(showTasks ? 1 : 0)
                    .offset(y: showTasks ? 0 : -20)
                    .animation(.spring(response: 0.8).delay(0.2), value: showTasks)
                
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                        TaskCard(task: task)
                            .opacity(showTasks ? 1 : 0)
                            .scaleEffect(showTasks ? 1 : 0.8)
                            .animation(
                                .spring(response: 0.8, dampingFraction: 0.7)
                                .delay(Double(index) * 0.2 + 0.4),
                                value: showTasks
                            )
                    }
                }
                
                Button("返回主頁") {
                    withAnimation(.spring(response: 0.6)) {
                        appState.currentView = .landing
                    }
                }
                .buttonStyle(ClearButtonStyle(isPrimary: false))
                .opacity(showTasks ? 1 : 0)
                .animation(.spring(response: 0.8).delay(1.2), value: showTasks)
            }
            .padding(20)
        }
        .onAppear {
            withAnimation {
                showTasks = true
            }
        }
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

