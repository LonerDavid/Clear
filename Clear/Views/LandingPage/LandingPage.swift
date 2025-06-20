import SwiftUI
#if os(visionOS)
import RealityKit
import RealityKitContent
#endif

// ✅ 背景音樂播放管理器


// ✅ 主畫面
struct UpdatedLandingPageView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var chatManager = SimpleChatGPTManager()
    @State private var isAnimating = false
    @State private var showWelcomeText = false
    @State private var showChatInterface = false
    @State private var showAPISetup = false
    @State private var showVoiceWave = false
    @State private var inputText = ""

    var body: some View {
        #if os(visionOS)
        VStack(spacing: 24) {
            DraggableYellowHeartView()
            Text("嗨，今天的你感覺如何？")
                .font(.largeTitle)
            
            HStack(spacing: 12) {
                TextField("輸入訊息...", text: $inputText, onCommit: {
                    sendTextMessage()
                })
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.thinMaterial)
                )
                .hoverEffect(.highlight)
                .frame(maxWidth: 300)
                
                Button(action: {
                    if chatManager.isListening {
                        chatManager.stopListening()
                    } else {
                        chatManager.startListening()
                    }
                }) {
                    Image(systemName: chatManager.isListening ? "mic.fill" : "mic")
                        .font(.title2)
                        .foregroundStyle(chatManager.isListening ? .red : .primary)
                }
                .buttonStyle(.borderless)
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
                    //進入房間
                } label: {
                    HStack {
                        Text("進入房間")
                            .font(.caption)
                        Image(systemName: "bubbles.and.sparkles.fill")
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .onAppear {
            AudioPlayerManager.shared.playBackgroundSound(named: "lake")
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

// MARK: - 修正置中的緊湊型聊天視圖
struct CompactChatView: View {
    @ObservedObject var chatManager: SimpleChatGPTManager
    let onClose: () -> Void
    
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 標題列 - 置中
            HStack {
                Text("💬 與 Clear 對話")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("關閉") {
                    onClose()
                }
                .buttonStyle(ClearButtonStyle(isPrimary: false))
            }
            .padding()
            .background(.ultraThinMaterial)
            .frame(maxWidth: .infinity) // 標題列置中
            
            // 聊天記錄 - 置中
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatManager.conversationHistory) { message in
                            ChatMessageBubble(message: message)
                        }
                        
                        if chatManager.isProcessing {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Clear 正在思考...")
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading) // 載入指示器左對齊
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // 聊天記錄容器置中
                }
                .frame(maxHeight: 300)
                .onChange(of: chatManager.conversationHistory.count) { _, _ in
                    if let lastMessage = chatManager.conversationHistory.last {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // 情緒分析顯示 - 置中
            if let emotion = chatManager.detectedEmotion {
                EmotionDisplayCard(emotion: emotion)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity) // 情緒分析卡片置中
            }
            
            // 輸入區域 - 置中
            VStack(spacing: 15) {
                // 文字輸入
                HStack {
                    TextField("輸入訊息...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("發送") {
                        sendMessage()
                    }
                    .buttonStyle(ClearButtonStyle(isPrimary: false))
                    .disabled(messageText.isEmpty)
                }
                .frame(maxWidth: .infinity) // 輸入欄置中
                
                // 語音控制 - 置中
                HStack(spacing: 20) {
                    Button(action: {
                        if chatManager.isListening {
                            chatManager.stopListening()
                        } else {
                            chatManager.startListening()
                        }
                    }) {
                        Image(systemName: chatManager.isListening ? "mic.fill" : "mic")
                            .font(.system(size: 25))
                            .foregroundStyle(chatManager.isListening ? .red : .white)
                    }
                    .buttonStyle(VoiceButtonStyle(isActive: chatManager.isListening))
                    
                    Button("清除對話") {
                        chatManager.clearConversation()
                    }
                    .buttonStyle(ClearButtonStyle(isPrimary: false))
                    .font(.caption)
                }
                .frame(maxWidth: .infinity) // 語音控制按鈕組置中
                
                if let error = chatManager.speechError ?? chatManager.apiError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity) // 錯誤訊息置中
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .frame(maxWidth: .infinity) // 整個輸入區域置中
        }
        .background(.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(maxWidth: .infinity) // 整個對話框置中
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        chatManager.sendTextMessage(messageText)
        messageText = ""
    }
}


// MARK: - Preview
#Preview {
    UpdatedLandingPageView()
}
