import SwiftUI
import AVFoundation
#if os(visionOS)
import RealityKit
import RealityKitContent
#endif

// ✅ 背景音樂播放管理器


// ✅ 主畫面
struct UpdatedLandingPageView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var chatManager = SimpleChatGPTManager.shared
    #if os(visionOS)
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    #endif
    @State private var isAnimating = false
    @State private var showWelcomeText = false
    @State private var showChatInterface = false
    @State private var showAPISetup = false
    @State private var showVoiceWave = false
    @State private var inputText = ""

    var body: some View {
        #if os(visionOS)
        VStack(spacing: 20) {
            DraggableYellowHeartView()
                .opacity(showAPISetup ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: showAPISetup)
//            Text("嗨，今天的你感覺如何？")
            Text(getGreetingText())
                .font(.largeTitle)
            
            HStack(spacing: 12) {
                if chatManager.hasValidAPIKey {
                    Button {
                        openWindow(id: MyWindowID.chatView)
                            
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("開始與 Clear 對話")
                        }
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 12)
//                        .background(Material.thick)
//                        .clipShape(Capsule())
                        .foregroundStyle(.primary)
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        showAPISetup = true
                    } label: {
                        Text("設定 AI 功能，來跟Clear對話吧！")
                    }
                }
                
            }
            .padding(.horizontal)
            
            HStack {
                Button {
                    //說不出口
                } label: {
                    Text("說不出口?")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                
                Button {
                    if appModel.currentImmersiveSpaceID == appModel.forestImmersiveSpaceID {
                        Task {
                            await dismissImmersiveSpace()
                            _ = await openImmersiveSpace(id: appModel.immersiveSpaceID)
                            appModel.currentImmersiveSpaceID = appModel.immersiveSpaceID
                        }
                    } else {
                        Task {
                            await dismissImmersiveSpace()
                            _ = await openImmersiveSpace(id: appModel.forestImmersiveSpaceID)
                            appModel.currentImmersiveSpaceID = appModel.forestImmersiveSpaceID
                        }
                    }
                } label: {
                    HStack {
                        Text(appModel.currentImmersiveSpaceID == appModel.forestImmersiveSpaceID ? "離開房間" : "進入房間")
                            .font(.caption)
                        Image(systemName: appModel.currentImmersiveSpaceID == appModel.forestImmersiveSpaceID ? "rectangle.portrait.and.arrow.right.fill" : "bubbles.and.sparkles.fill")
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .onAppear {
            AudioPlayerManager.shared.playBackgroundSound(named: "lake")
        }
        .sheet(isPresented: $showAPISetup) {
            SimpleAPISetupView(chatManager: chatManager) {
                showAPISetup = false
            }
        }
        .onReceive(chatManager.$detectedEmotion) { newEmotion in
            if let emotion = newEmotion {
                updateAppStateFromEmotion(emotion)
            }
        }
        #else
        GeometryReader { geometry in
            ZStack {
                Color.clear
                    .background(
                        Image("Immersive")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                    )

                Color.black.opacity(0.3).ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    ClearCharacterView(
                        size: min(geometry.size.width * 0.3, 120),
                        expression: getCharacterExpression(),
                        color: getCharacterColor()
                    )
                    .opacity(showWelcomeText ? 1 : 0)
                    .scaleEffect(showWelcomeText ? 1 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showWelcomeText)

                    VStack(spacing: 20) {
                        Text(getGreetingText())
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .opacity(showWelcomeText ? 1 : 0)
                            .offset(y: showWelcomeText ? 0 : 20)
                            .animation(.spring(response: 0.8).delay(0.5), value: showWelcomeText)

                        SimpleVoiceWaveView(isAnimating: $isAnimating, isAIActive: chatManager.isProcessing)
                            .opacity(showWelcomeText ? 1 : 0)
                            .animation(.spring(response: 0.8).delay(0.8), value: showWelcomeText)
                            .onTapGesture {
                                if chatManager.hasValidAPIKey {
                                    toggleChatInterface()
                                } else {
                                    showAPISetup = true
                                }
                            }
                    }

                    Spacer()

                    VStack(spacing: 20) {
                        if chatManager.hasValidAPIKey {
                            Button(showChatInterface ? "關閉對話" : "🤖 開始與 Clear 對話") {
                                toggleChatInterface()
                            }
                            .buttonStyle(ClearButtonStyle())
                            .frame(maxWidth: 280)
                        } else {
                            Button("🔧 設置 AI 智能對話") {
                                showAPISetup = true
                            }
                            .buttonStyle(ClearButtonStyle())
                            .frame(maxWidth: 280)
                        }

                        Button("說不出口") {
                            withAnimation(.spring(response: 0.6)) {
                                appState.currentView = .emotionSelection
                            }
                        }
                        .buttonStyle(ClearButtonStyle(isPrimary: false))
                        .frame(maxWidth: 280)

                        Button("進入房間") {
                            if let emotion = chatManager.detectedEmotion {
                                updateAppStateFromEmotion(emotion)
                            }
                            withAnimation(.spring(response: 0.6)) {
                                appState.currentView = .immersiveSpace
                            }
                        }
                        .buttonStyle(ClearButtonStyle(isPrimary: false))
                        .frame(maxWidth: 280)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)

                if showChatInterface {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            toggleChatInterface()
                        }

                    VStack {
                        Spacer()
                        CompactChatView(chatManager: chatManager) {
                            toggleChatInterface()
                        }
                        .frame(maxWidth: min(geometry.size.width - 40, 400))
                        Spacer()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onAppear {
                isAnimating = true
                withAnimation(.easeInOut(duration: 0.8)) {
                    showWelcomeText = true
                }

                // ✅ 每次打開都說話
                let utterance = AVSpeechUtterance(string: "今天過得好嗎？")
                utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
                utterance.rate = 0.5
                AVSpeechSynthesizer().speak(utterance)

                // ✅ 每次打開都播放湖泊聲音
                AudioPlayerManager.shared.playBackgroundSound(named: "lake")
            }
            .sheet(isPresented: $showAPISetup) {
                SimpleAPISetupView(chatManager: chatManager) {
                    showAPISetup = false
                }
            }
            .onReceive(chatManager.$detectedEmotion) { newEmotion in
                if let emotion = newEmotion {
                    updateAppStateFromEmotion(emotion)
                }
            }
        }
        #endif
    }

    private func toggleChatInterface() {
        withAnimation(.spring(response: 0.6)) {
            showChatInterface.toggle()
        }
    }

    private func getCharacterExpression() -> String {
        if let emotion = chatManager.detectedEmotion {
            switch emotion.emotionScore {
            case 20...100: return "😊"
            case -20..<20: return "😐"
            case -50..<(-20): return "😔"
            default: return "😰"
            }
        }
        return "😊"
    }

    private func getCharacterColor() -> Color {
        if let emotion = chatManager.detectedEmotion {
            switch emotion.stressLevel {
            case 0..<25: return .green
            case 25..<50: return .yellow
            case 50..<75: return .orange
            default: return .red
            }
        }
        return .yellow
    }

    private func getGreetingText() -> String {
        if !chatManager.hasValidAPIKey {
            return "嗨，我是 Clear！今天你的感覺如何"
        } else if showChatInterface {
            return "我正在聆聽你的心聲... 💙"
        } else if let emotion = chatManager.detectedEmotion {
            return "我感受到你現在\(emotion.emotionType)\n想繼續聊聊嗎？"
        } else {
            return "嗨，我是 Clear！\n今天的你感覺如何？"
        }
    }

    private func updateAppStateFromEmotion(_ emotion: EmotionAnalysis) {
        let newEmotionType: AppState.EmotionType
        switch emotion.emotionScore {
        case 50...100: newEmotionType = .happy
        case 20..<50: newEmotionType = .peaceful
        case -20..<20: newEmotionType = .neutral
        case -50..<(-20): newEmotionType = .sad
        default: newEmotionType = .anxious
        }
        appState.currentEmotion = newEmotionType
        appState.clearCharacter.color = getCharacterColor()
        appState.clearCharacter.expression = getCharacterExpression()
    }

    private func sendTextMessage() {
        guard !inputText.isEmpty else { return }
        chatManager.sendTextMessage(inputText)
        inputText = ""
    }
}

// MARK: - 修正置中的語音波形視圖
struct SimpleVoiceWaveView: View {
    @Binding var isAnimating: Bool
    let isAIActive: Bool
    @State private var waveHeights: [CGFloat] = Array(repeating: 15, count: 5)
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white.opacity(isAIActive ? 1.0 : 0.8))
                        .frame(width: 6, height: waveHeights[index])
                        .animation(
                            .easeInOut(duration: Double.random(in: 0.3...0.8))
                            .repeatForever()
                            .delay(Double(index) * 0.1),
                            value: waveHeights[index]
                        )
                }
            }
            .frame(height: 30)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isAIActive ? .blue : .white.opacity(0.3), lineWidth: isAIActive ? 2 : 1)
                )
        )
        .frame(maxWidth: .infinity) // 確保波形視圖置中
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("StartWaveAnimation"))) { _ in
            if isAnimating {
                startWaveAnimation()
            }
        }
        .scaleEffect(isAIActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isAIActive)
        .onAppear {
            if isAnimating {
                startWaveAnimation()
            }
        }
    }
    
    private func startWaveAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            guard isAnimating else {
                timer.invalidate()
                return
            }
            
            for i in 0..<waveHeights.count {
                waveHeights[i] = CGFloat.random(in: 8...35)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    UpdatedLandingPageView()
}
