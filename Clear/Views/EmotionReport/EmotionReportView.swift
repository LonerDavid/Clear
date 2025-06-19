import SwiftUI
import Photos
import PhotosUI

struct EmotionReportView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var healthManager = HealthManager()
    @State private var showContent = false
    @State private var showAcuteExplanation = false
    @State private var showChronicExplanation = false
    
    var body: some View {
#if os(visionOS)
        VStack(spacing: 10) {
            Text("今日情緒報告")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.vertical, 10)
            HStack {
                ClearCharacterView(
                    size: 300,
                    expression: appState.clearCharacter.expression,
                    color: appState.clearCharacter.color
                )
                
                Spacer()
                
                if healthManager.isAuthorized {
                    VStack(spacing: 20) {
                        StressInfoCard(
                            title: "短期壓力",
                            percentage: Int(healthManager.stressAnalysis.acuteStressLevel),
                            date: "即時",
                            color: .gray,
                            type: "acute"
                        )
                        .onTapGesture {
                            showAcuteExplanation = true
                        }
                        .padding()
                        .background(Material.thin)
                        .cornerRadius(20)
                        
                        StressInfoCard(
                            title: "長期壓力",
                            percentage: Int(healthManager.stressAnalysis.chronicStressLevel),
                            date: "本週",
                            color: .gray,
                            type: "chronic"
                        )
                        .onTapGesture {
                            showChronicExplanation = true
                        }
                        .padding()
                        .background(Material.thin)
                        .cornerRadius(20)
                    }
                    .padding()
                    .animation(.spring(response: 0.8).delay(0.8), value: showContent)
                } else {
                    VStack {
                        VStack(spacing: 10) {
                            Image(systemName: "applewatch.watchface")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                            
                            Text("未連接健康數據")
                                .font(.callout)
                                .foregroundStyle(.gray)
                        }
                        .padding(30)
                        .frame(minWidth:100  ,maxWidth: 200, minHeight: 80, maxHeight: 160)
                        
                        
                        Button("連接 Apple Watch 健康數據") {
                            healthManager.requestHealthKitPermission()
                        }
                        .background(.ultraThinMaterial, in: Capsule())
                        .buttonStyle(.borderless)
                    }
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(.horizontal, 20)
        }
        
#else
        ScrollView {
            VStack(spacing: 30) {
                Text("今日情緒報告")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    .animation(.spring(response: 0.8).delay(0.2), value: showContent)
                
                HStack(spacing: 40) {
                    // Clear 角色狀態
                    VStack(spacing: 15) {
                        ClearCharacterView(
                            size: 100,
                            expression: appState.clearCharacter.expression,
                            color: appState.clearCharacter.color
                        )
                        
                        VStack(spacing: 5) {
                            Text("當前狀態")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if healthManager.isAuthorized {
                                Text(healthManager.stressAnalysis.stressCategory.emoji + " " + healthManager.stressAnalysis.stressCategory.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(healthManager.stressAnalysis.stressCategory.color.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                                    .foregroundStyle(healthManager.stressAnalysis.stressCategory.color)
                            }
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .animation(.spring(response: 0.8).delay(0.4), value: showContent)
                    
                    // 健康數據
                    VStack(alignment: .leading, spacing: 15) {
                        if healthManager.isAuthorized {
                            HealthMetricCard(
                                icon: "heart.fill",
                                title: "心率",
                                value: String(format: "%.0f", healthManager.currentHeartRate),
                                unit: "bpm",
                                color: .red
                            )
                            
                            HealthMetricCard(
                                icon: "waveform.path.ecg",
                                title: "HRV",
                                value: String(format: "%.1f", healthManager.currentHRV),
                                unit: "ms",
                                color: .blue
                            )
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "applewatch.watchface")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.gray)
                                
                                Text("未連接健康數據")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(15)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(x: showContent ? 0 : 20)
                    .animation(.spring(response: 0.8).delay(0.6), value: showContent)
                }
                
                if healthManager.isAuthorized {
                    VStack(spacing: 20) {
                        StressInfoCard(
                            title: "短期壓力",
                            percentage: Int(healthManager.stressAnalysis.acuteStressLevel),
                            date: "即時",
                            color: .orange,
                            type: "acute"
                        )
                        .onTapGesture {
                            showAcuteExplanation = true
                        }
                        
                        StressInfoCard(
                            title: "長期壓力",
                            percentage: Int(healthManager.stressAnalysis.chronicStressLevel),
                            date: "本週",
                            color: .purple,
                            type: "chronic"
                        )
                        .onTapGesture {
                            showChronicExplanation = true
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)
                    .animation(.spring(response: 0.8).delay(0.8), value: showContent)
                }
                
                if healthManager.isAuthorized {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("個人化建議")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        
                        ForEach(Array(healthManager.getStressRecommendations().enumerated()), id: \.offset) { index, recommendation in
                            SuggestionCard(
                                icon: String(recommendation.prefix(2)),
                                title: extractTitle(from: recommendation),
                                description: extractDescription(from: recommendation),
                                color: getSuggestionColor(for: index)
                            )
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)
                    .animation(.spring(response: 0.8).delay(1.0), value: showContent)
                }
                
                VStack(spacing: 15) {
                    if !healthManager.isAuthorized {
                        Button("連接 Apple Watch 健康數據") {
                            healthManager.requestHealthKitPermission()
                        }
                        .buttonStyle(HealthConnectButtonStyle())
                    }
                    
                    Button("查看每日任務") {
                        withAnimation(.spring(response: 0.6)) {
                            appState.currentView = .dailyTasks
                        }
                    }
                    .buttonStyle(ClearButtonStyle())
                    
                    Button("返回主頁") {
                        withAnimation(.spring(response: 0.6)) {
                            appState.currentView = .landing
                        }
                    }
                    .buttonStyle(ClearButtonStyle(isPrimary: false))
                }
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.8).delay(1.2), value: showContent)
            }
            .padding(20)
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
            
            // 更新 Clear 角色狀態依據壓力分類
            updateClearCharacter()
        }
        .refreshable {
            healthManager.refreshHealthData()
        }
        .sheet(isPresented: $showAcuteExplanation) {
            StressExplanationDialog(
                title: "短期壓力怎麼算？",
                explanation: """
短期壓力反映你當下的壓力狀態，根據 HRV（心率變異性）計算。

我們的公式是：
(60 - HRV) × 2，並限制在 0～100。

HRV 越低，代表壓力越高；HRV 越高，則代表自律神經系統穩定、壓力較低。

舉例：若 HRV 平均為 45，短期壓力即為 (60-45)×2 = 30。

HRV 數據來自 Apple Watch 並透過 HealthKit 提供，建議搭配深呼吸或冥想進行調節。
""",
                isPresented: $showAcuteExplanation
            )
        }
        .sheet(isPresented: $showChronicExplanation) {
            StressExplanationDialog(
                title: "長期壓力怎麼算？",
                explanation: """
長期壓力代表你近一週的生活壓力累積情況，結合四個健康指標來評估：

1. REM 睡眠時長（< 60 分 → 壓力偏高）
2. 步行步數（< 3000 步 → 壓力偏高）
3. 呼吸頻率（> 18 次/分 → 壓力偏高）
4. 活動能量（< 250 kcal → 壓力偏高）

每項指標給予一定權重後平均，最後換算為 0～100 的分數。

舉例：如果你最近都缺乏運動、睡不好，分數會提高。這幫助你察覺壓力來源並及早調整。
""",
                isPresented: $showChronicExplanation
            )
        }
#endif
    }
    
    private func updateClearCharacter() {
        let category = healthManager.stressAnalysis.stressCategory
        var expression = "😐"
        var color: Color = .green
        
        switch category {
        case .low:
            expression = "😊"
            color = .yellow
        case .moderate:
            expression = "😐"
            color = .green
        case .high:
            expression = "😰"
            color = .orange
        case .severe:
            expression = "😵‍💫"
            color = .red
        }
        
        appState.clearCharacter = ClearCharacter(color: color, expression: expression)
    }
    
    private func extractTitle(from recommendation: String) -> String {
        let text = String(recommendation.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        return text.components(separatedBy: "，").first ?? text
    }
    
    private func extractDescription(from recommendation: String) -> String {
        let text = String(recommendation.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        let components = text.components(separatedBy: "，")
        return components.count > 1 ? components.dropFirst().joined(separator: "，") : "建議執行此活動"
    }
    
    private func getSuggestionColor(for index: Int) -> Color {
        let colors: [Color] = [.green, .blue, .orange, .purple]
        return colors[index % colors.count]
    }
}


// MARK: - 說明對話框元件
struct StressExplanationDialog: View {
    let title: String
    let explanation: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2).bold()
            
            ScrollView {
                Text(explanation)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
            }
            
            Button("我了解了") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: 500)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

#Preview {
    ContentView()
}
