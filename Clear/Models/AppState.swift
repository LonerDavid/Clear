// MARK: - Main App File
import SwiftUI
import Photos
import PhotosUI

// MARK: - AppState.swift
class AppState: ObservableObject {
    @Published var currentView: ViewType = .landing
    @Published var currentEmotion: EmotionType = .neutral
    @Published var stressLevel: Float = 0.5
    @Published var clearCharacter = ClearCharacter()
    
    enum ViewType {
        case landing, emotionSelection, immersiveSpace, emotionReport, dailyTasks
    }
    
    enum EmotionType: String, CaseIterable {
        case happy = "滿足"
        case anxious = "焦慮"
        case peaceful = "平靜"
        case thoughtful = "想念"
        case relaxed = "放空"
        case focused = "專注"
        case angry = "憤怒"
        case sad = "無聊"
        case neutral = "普通"
        
        var color: Color {
            switch self {
            case .happy: return .yellow
            case .anxious: return .purple
            case .peaceful: return .green
            case .thoughtful: return .blue
            case .relaxed: return .mint
            case .focused: return .orange
            case .angry: return .red
            case .sad: return .gray
            case .neutral: return .white
            }
        }
        
        var emoji: String {
            switch self {
            case .happy: return "😊"
            case .anxious: return "😰"
            case .peaceful: return "😌"
            case .thoughtful: return "🤔"
            case .relaxed: return "😎"
            case .focused: return "🧐"
            case .angry: return "😠"
            case .sad: return "😔"
            case .neutral: return "😐"
            }
        }
    }
}

class ClearCharacter: ObservableObject {
    @Published var color: Color
    @Published var expression: String
    @Published var isFloating: Bool

    init(color: Color = .yellow, expression: String = "😊", isFloating: Bool = true) {
        self.color = color
        self.expression = expression
        self.isFloating = isFloating
    }
}


// MARK: - 4. 更新 AppState 類別 (在現有 AppState 後面新增方法)
extension AppState {
    func updateWithHealthData(_ healthManager: HealthManager) {
        let avgStress = (healthManager.stressAnalysis.acuteStressLevel + healthManager.stressAnalysis.chronicStressLevel) / 2
        
        switch avgStress {
        case 0..<25:
            clearCharacter.color = .yellow
            clearCharacter.expression = "😊"
        case 25..<50:
            clearCharacter.color = .yellow
            clearCharacter.expression = "😐"
        case 50..<75:
            clearCharacter.color = .orange
            clearCharacter.expression = "😰"
        default:
            clearCharacter.color = .red
            clearCharacter.expression = "😵‍💫"
        }
        
        self.stressLevel = Float(avgStress / 100)
    }
}
