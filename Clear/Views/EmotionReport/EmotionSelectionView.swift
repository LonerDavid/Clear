
import SwiftUI
import Photos
import PhotosUI

// MARK: - EmotionSelectionView.swift
struct EmotionSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedEmotion: AppState.EmotionType?
    @State private var showGrid = false
    
    let emotions = AppState.EmotionType.allCases
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Clear 角色 - 冥想姿態
            ClearCharacterView(size: 100, expression: "🧘‍♀️", color: .mint)
                .opacity(showGrid ? 1 : 0)
                .scaleEffect(showGrid ? 1 : 0.8)
                .animation(.spring(response: 0.8).delay(0.2), value: showGrid)
            
            Text("今天的你感覺如何？")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .opacity(showGrid ? 1 : 0)
                .animation(.spring(response: 0.8).delay(0.4), value: showGrid)
            
            // 情緒氣泡網格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 20) {
                ForEach(Array(emotions.enumerated()), id: \.element) { index, emotion in
                    EmotionBubble(emotion: emotion, isSelected: selectedEmotion == emotion)
                        .opacity(showGrid ? 1 : 0)
                        .scaleEffect(showGrid ? 1 : 0.5)
                        .animation(.spring(response: 0.6).delay(Double(index) * 0.1 + 0.6), value: showGrid)
                        .onTapGesture {
                            selectedEmotion = emotion
                            appState.currentEmotion = emotion
                            appState.clearCharacter.color = emotion.color
                            appState.clearCharacter.expression = emotion.emoji
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation(.spring(response: 0.6)) {
                                    appState.currentView = .immersiveSpace
                                }
                            }
                        }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button("返回") {
                withAnimation(.spring(response: 0.6)) {
                    appState.currentView = .landing
                }
            }
            .buttonStyle(ClearButtonStyle(isPrimary: false))
            .opacity(showGrid ? 1 : 0)
            .animation(.spring(response: 0.8).delay(1.0), value: showGrid)
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showGrid = true
            }
        }
    }
}

// MARK: - EmotionBubble.swift
struct EmotionBubble: View {
    let emotion: AppState.EmotionType
    let isSelected: Bool
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 5) {
            Text(emotion.emoji)
                .font(.title)
            
            Text(emotion.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Circle()
                .fill(emotion.color.opacity(isSelected ? 0.6 : 0.3))
                .overlay(
                    Circle()
                        .stroke(emotion.color, lineWidth: isSelected ? 3 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.15 : (isPressed ? 0.95 : 1.0))
        .animation(.spring(response: 0.3), value: isSelected)
        .animation(.spring(response: 0.2), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

