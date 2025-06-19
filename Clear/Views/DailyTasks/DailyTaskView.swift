//
//  DailyTaskView.swift
//  Clear
//
//  Created by Haruaki on 2025/6/19.
//

import SwiftUI

struct DailyTaskView: View {
    @EnvironmentObject var appState: AppState
    @State private var showTasks = false
    
    private let tasks = [
        DailyTask(
            title: "冥想",
            subtitle: "短期舒壓任務",
            duration: "3分鐘",
            character: "🧘‍♀️",
            color: .green,
            description: "透過正念冥想，讓心靈回到平靜狀態",
            clearname: "clear_green",
            backgroundcolor: .clearGreen
        ),
        DailyTask(
            title: "時空膠囊",
            subtitle: "長期任務卡",
            duration: "記錄美好",
            character: "📝",
            color: .orange,
            description: "記錄今天的美好時刻，為未來的自己留下溫暖",
            clearname: "clear_writing",
            backgroundcolor: .clearDefault
        ),
        DailyTask(
            title: "聽音樂",
            subtitle: "快速任務卡",
            duration: "30秒",
            character: "🎧",
            color: .yellow,
            description: "聆聽療癒音樂，讓音符撫慰你的心靈",
            clearname: "clear_music",
            backgroundcolor: .clearOrange
        )
    ]
    
    var body: some View {
        #if os(visionOS)
        VStack(spacing: 0) {
            Text("每日任務卡")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            LazyHGrid(rows: [GridItem(.flexible())]
            ) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) {
                    index, task in
                    TaskCard(task: task)
                }
            }
        }
        
        #else
        ScrollView {
            VStack(spacing: 0) {
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
        #endif
    }
}

#Preview {
    DailyTaskView()
}
