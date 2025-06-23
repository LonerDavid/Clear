import SwiftUI
import Photos
import PhotosUI

// MARK: - DailyTask.swift
struct DailyTask: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let duration: String
    let character: String
    let color: Color
    let description: String
    let clearname: String
    let backgroundcolor: Color
}

// MARK: - TaskCard.swift
struct TaskCard: View {
    let task: DailyTask
    @State private var isPressed = false
    @State private var isCompleted = false
    @State private var showDetail = false
    @State private var showSheet = false

    
    var body: some View {
        #if os(visionOS)
        VStack {
            VStack(spacing: 10) {
                HStack {
                    Text(task.subtitle)
                        .font(.subheadline)
                    Spacer()
                    Text(task.duration)
                        .font(.caption)
                }

                HStack {
                    Text(task.title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)

            
            
            Spacer()
            Image(task.clearname)
                .resizable()
                .scaledToFit()
        }
        .frame(width: 250, height: 350)
        .background{
            task.backgroundcolor
                .opacity(0.2)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.horizontal, 5)
        
        #else
        VStack(spacing: 0) {
            // 主要任務卡片
            HStack(spacing: 20) {
                // 任務圖標
                ZStack {
                    Circle()
                        .fill(task.color.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Text(task.character)
                        .font(.system(size: 35))
                }
                
                // 任務信息
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(task.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.title2)
                        }
                    }
                    
                    Text(task.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !task.duration.isEmpty {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(task.color)
                            Text(task.duration)
                                .font(.caption)
                                .foregroundStyle(task.color)
                        }
                    }
                }
                
                Spacer()
                
                // 詳情按鈕
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showDetail.toggle()
                    }
                }) {
                    Image(systemName: showDetail ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(task.color.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // 詳情展開區域
            if showDetail {
                VStack(alignment: .leading, spacing: 15) {
                    Text(task.description)
                        .font(.body)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 15) {
                        Button(isCompleted ? "已完成" : "開始任務") {
                            withAnimation(.spring(response: 0.6)) {
                                isCompleted.toggle()
                            }
                            
                            // 添加觸覺反饋
                            #if !os(visionOS)
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            #endif
                        }
                        .buttonStyle(TaskActionButtonStyle(color: task.color, isCompleted: isCompleted))
                        .disabled(isCompleted)
                        
                        if !isCompleted {
                            Button("稍後提醒") {
                                // 設置本地通知
                                scheduleNotification(for: task)
                            }
                            .buttonStyle(TaskActionButtonStyle(color: .gray, isCompleted: false, isSecondary: true))
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(task.color.opacity(0.05))
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            TaskDetailSheet(task: task)
        }
        #endif
    }
    
    private func scheduleNotification(for task: DailyTask) {
        let content = UNMutableNotificationContent()
        content.title = "晴境提醒"
        content.body = "是時候進行\(task.title)了，讓心靈得到療癒 ✨"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1小時後提醒
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - TaskActionButtonStyle.swift
struct TaskActionButtonStyle: ButtonStyle {
    let color: Color
    let isCompleted: Bool
    var isSecondary: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(isSecondary ? .white : (isCompleted ? .white : .black))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isCompleted ? .green : (isSecondary ? .clear : color))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSecondary ? .gray : .clear, lineWidth: isSecondary ? 1 : 0)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

struct TaskDetailSheet: View {
    let task: DailyTask
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 24) {
            Text(task.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, -16)

            Text(taskDetailDescription(for: task.title))
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)

//            Spacer()
            Button(action: { dismiss() }) {
                Text("我了解了")
                    .foregroundStyle(.primary)
                    .padding(8)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(minWidth: 350, minHeight: 300)
        .padding(.bottom, 20)
    }

    private func taskDetailDescription(for title: String) -> String {
        switch title {
        case "冥想":
            return "專注當下，閉上眼睛，隨著呼吸節奏緩慢地放鬆身心。3 分鐘的靜心練習，幫助你從忙碌中抽離，找回平靜的自己。"
        case "時空膠囊":
            return "完成一個時空膠囊：寫下一段話、畫一張圖，或存下一張有意義的照片，封存在 Clear 的時空膠囊中。這是給未來自己的訊息，也是一份情緒成長的紀錄。"
        case "聽音樂":
            return "播放一段療癒旋律，只要 30 秒，讓耳朵放鬆、心緒沉澱。無論你在哪個情緒階段，聲音都能成為安撫自己的力量。"
        default:
            return task.description
        }
    }
}
