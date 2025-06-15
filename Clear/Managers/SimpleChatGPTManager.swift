// MARK: - 完整修正的 ChatGPT 管理器
import SwiftUI
import Speech
import AVFoundation

// MARK: - 數據模型
struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    private enum CodingKeys: String, CodingKey {
        case content, isUser, timestamp
    }
}

struct EmotionAnalysis: Codable {
    let stressLevel: Double // 0-100
    let emotionScore: Double // -100 到 100，負數表示負面情緒
    let detectedKeywords: [String]
    let confidence: Double // 0-1
    
    var emotionType: String {
        switch emotionScore {
        case 50...100:
            return "非常開心"
        case 20..<50:
            return "開心"
        case -20..<20:
            return "平靜"
        case -50..<(-20):
            return "有些難過"
        default:
            return "很難過"
        }
    }
    
    var stressCategory: String {
        switch stressLevel {
        case 0..<25:
            return "低壓力"
        case 25..<50:
            return "中等壓力"
        case 50..<75:
            return "高壓力"
        default:
            return "極高壓力"
        }
    }
    
    var stressCategoryColor: Color {
        switch stressLevel {
        case 0..<25:
            return .green
        case 25..<50:
            return .yellow
        case 50..<75:
            return .orange
        default:
            return .red
        }
    }
}


// MARK: - SimpleChatGPTManager (修正版)
class SimpleChatGPTManager: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var isProcessing = false
    @Published var currentResponse = ""
    @Published var conversationHistory: [ChatMessage] = []
    @Published var detectedEmotion: EmotionAnalysis?
    @Published var speechError: String?
    @Published var apiError: String?
    @Published var hasValidAPIKey: Bool = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-TW"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    
    // API 配置
    private var apiKey: String = "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"
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    override init() {
        super.init()
        setupSpeech()
        setupInitialGreeting()
        loadAPIKey()
    }
    
    // MARK: - API Key 管理
    func setAPIKey(_ key: String) {
        self.apiKey = key
        hasValidAPIKey = !key.isEmpty && key.hasPrefix("sk-")
        saveAPIKey(key)
        if hasValidAPIKey {
            setupInitialGreeting()
        }
    }
    
    private func saveAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "openai_api_key")
    }
    
    private func loadAPIKey() {
        if let savedKey = UserDefaults.standard.string(forKey: "openai_api_key") {
            apiKey = savedKey
            hasValidAPIKey = !savedKey.isEmpty && savedKey.hasPrefix("sk-")
        }
    }
    
    func clearAPIKey() {
        apiKey = ""
        hasValidAPIKey = false
        UserDefaults.standard.removeObject(forKey: "openai_api_key")
        clearConversation()
    }
    
    // MARK: - 初始化
    private func setupInitialGreeting() {
        conversationHistory.removeAll()
        let greeting = ChatMessage(
            content: hasValidAPIKey ?
                "嗨！我是 Clear 💙 今天過得怎麼樣？" :
                "嗨！我是 Clear 💙 請先設置 API Key 來啟用對話功能。",
            isUser: false,
            timestamp: Date()
        )
        conversationHistory.append(greeting)
    }
    
    // MARK: - 修正的語音設置
    private func setupSpeech() {
        // 語音識別權限
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("語音識別已授權")
                case .denied, .restricted, .notDetermined:
                    self.speechError = "需要語音識別權限才能使用語音功能"
                @unknown default:
                    break
                }
            }
        }
        
        // 修正的麥克風權限請求 - 兼容舊版本
        requestMicrophonePermission()
    }
    
    private func requestMicrophonePermission() {
        if #available(iOS 17.0, *) {
            // iOS 17+ 使用新的 API - 修正版本
            Task {
                let granted = await AVAudioApplication.requestRecordPermission()
                await MainActor.run {
                    if !granted {
                        self.speechError = "需要麥克風權限才能錄音"
                    }
                }
            }
        } else {
            // iOS 16 及更早版本使用舊的 API
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.speechError = "需要麥克風權限才能錄音"
                    }
                }
            }
        }
    }
    
    // MARK: - 語音識別
    func startListening() {
        guard hasValidAPIKey else {
            apiError = "請先設置 OpenAI API Key"
            return
        }
        
        stopListening()
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            speechError = "語音識別功能暫時不可用"
            return
        }
        
        isListening = true
        speechError = nil
        
        Task {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                
                await MainActor.run {
                    self.startSpeechRecognition()
                }
            } catch {
                await MainActor.run {
                    self.speechError = "音頻設置錯誤: \(error.localizedDescription)"
                    self.isListening = false
                }
            }
        }
    }
    
    @MainActor
    private func startSpeechRecognition() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            speechError = "無法創建語音識別請求"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        let transcription = result.bestTranscription.formattedString
                        
                        if result.isFinal {
                            self?.processUserInput(transcription)
                            self?.stopListening()
                        }
                    }
                    
                    if let error = error {
                        self?.speechError = "語音識別錯誤: \(error.localizedDescription)"
                        self?.stopListening()
                    }
                }
            }
        } catch {
            speechError = "語音引擎啟動失敗: \(error.localizedDescription)"
            isListening = false
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
        
        Task {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("音頻會話停止錯誤: \(error)")
            }
        }
    }
    
    // MARK: - 訊息處理
    private func processUserInput(_ text: String) {
        guard !text.isEmpty else { return }
        guard hasValidAPIKey else {
            apiError = "請先設置 OpenAI API Key"
            return
        }
        
        let userMessage = ChatMessage(content: text, isUser: true, timestamp: Date())
        conversationHistory.append(userMessage)
        
        isProcessing = true
        apiError = nil
        
        Task {
            await sendToChatGPT(message: text)
        }
    }
    
    @MainActor
    private func sendToChatGPT(message: String) async {
        guard !apiKey.isEmpty else {
            apiError = "無法取得 API Key"
            isProcessing = false
            return
        }
        
        do {
            let response = try await callChatGPTAPI(message: message)
            let aiMessage = ChatMessage(content: response.cleanContent, isUser: false, timestamp: Date())
            conversationHistory.append(aiMessage)
            currentResponse = response.cleanContent
            
            if let emotionAnalysis = parseEmotionAnalysis(from: response.fullContent) {
                detectedEmotion = emotionAnalysis
                print("🧠 AI 情緒分析: \(emotionAnalysis.emotionType), 壓力: \(Int(emotionAnalysis.stressLevel))%")
            }
            
            isProcessing = false
            speakResponse(response.cleanContent)
            
        } catch {
            handleAPIError(error)
        }
    }
    
    private func handleAPIError(_ error: Error) {
        if let chatError = error as? ChatGPTError {
            apiError = chatError.errorDescription
            switch chatError {
            case .invalidAPIKey:
                hasValidAPIKey = false
            case .networkError:
                provideFallbackResponse(for: conversationHistory.last?.content ?? "")
            default:
                break
            }
        } else {
            apiError = "未知錯誤: \(error.localizedDescription)"
            provideFallbackResponse(for: conversationHistory.last?.content ?? "")
        }
        isProcessing = false
    }
    
    private func callChatGPTAPI(message: String) async throws -> (fullContent: String, cleanContent: String) {
        guard let url = URL(string: apiURL) else {
            throw ChatGPTError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let systemPrompt = """
        你是「Clear」，一個溫暖的 AI 情緒陪伴助手。用繁體中文回應，語氣親切自然。

        請在回應最後加上情緒分析：
        [EMOTION_ANALYSIS]
        STRESS: [0-100的壓力指數]
        EMOTION: [-100到100的情緒指數]
        KEYWORDS: [關鍵詞1,關鍵詞2,關鍵詞3]
        [/EMOTION_ANALYSIS]
        
        保持回應簡潔(50-100字)，富有同理心。
        """
        
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // 包含最近3條對話作為上下文
        let recentHistory = conversationHistory.suffix(3)
        for chatMessage in recentHistory {
            let role = chatMessage.isUser ? "user" : "assistant"
            var content = chatMessage.content
            content = cleanResponseContent(content)
            messages.append(["role": role, "content": content])
        }
        
        messages.append(["role": "user", "content": message])
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 200,
            "temperature": 0.7
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatGPTError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw ChatGPTError.invalidAPIKey
            }
            throw ChatGPTError.httpError(httpResponse.statusCode)
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = jsonResponse["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let messageDict = firstChoice["message"] as? [String: Any],
              let content = messageDict["content"] as? String else {
            throw ChatGPTError.parsingError
        }
        
        let cleanContent = cleanResponseContent(content)
        return (fullContent: content, cleanContent: cleanContent)
    }
    
    private func cleanResponseContent(_ content: String) -> String {
        let pattern = "\\[EMOTION_ANALYSIS\\][\\s\\S]*?\\[/EMOTION_ANALYSIS\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let range = NSRange(location: 0, length: content.count)
        let cleanContent = regex.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "")
        
        return cleanContent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseEmotionAnalysis(from content: String) -> EmotionAnalysis? {
        let pattern = "\\[EMOTION_ANALYSIS\\][\\s\\S]*?STRESS:\\s*(\\d+)[\\s\\S]*?EMOTION:\\s*(-?\\d+)[\\s\\S]*?KEYWORDS:\\s*([^\\]]*)[\\s\\S]*?\\[/EMOTION_ANALYSIS\\]"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.count)) else {
            return createFallbackEmotionAnalysis()
        }
        
        let stressRange = Range(match.range(at: 1), in: content)
        let emotionRange = Range(match.range(at: 2), in: content)
        let keywordsRange = Range(match.range(at: 3), in: content)
        
        guard let stressRange = stressRange,
              let emotionRange = emotionRange,
              let keywordsRange = keywordsRange else {
            return createFallbackEmotionAnalysis()
        }
        
        let stressString = String(content[stressRange])
        let emotionString = String(content[emotionRange])
        let keywordsString = String(content[keywordsRange])
        
        guard let stressLevel = Double(stressString),
              let emotionScore = Double(emotionString) else {
            return createFallbackEmotionAnalysis()
        }
        
        let keywords = keywordsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        return EmotionAnalysis(
            stressLevel: min(100, max(0, stressLevel)),
            emotionScore: min(100, max(-100, emotionScore)),
            detectedKeywords: keywords.filter { !$0.isEmpty },
            confidence: 0.85
        )
    }
    
    private func createFallbackEmotionAnalysis() -> EmotionAnalysis {
        let stressKeywords = ["壓力", "緊張", "焦慮", "累", "疲憊", "煩躁", "忙"]
        let happyKeywords = ["開心", "快樂", "興奮", "滿足", "愉快", "高興", "棒"]
        let sadKeywords = ["難過", "憂鬱", "沮喪", "失望", "悲傷", "低落"]
        
        var stressLevel: Double = 30
        var emotionScore: Double = 0
        var foundKeywords: [String] = []
        
        let userMessages = conversationHistory.filter { $0.isUser }.suffix(3)
        let recentText = userMessages.map { $0.content }.joined(separator: " ")
        
        for keyword in stressKeywords {
            if recentText.contains(keyword) {
                stressLevel += 15
                foundKeywords.append(keyword)
            }
        }
        
        for keyword in happyKeywords {
            if recentText.contains(keyword) {
                emotionScore += 20
                foundKeywords.append(keyword)
            }
        }
        
        for keyword in sadKeywords {
            if recentText.contains(keyword) {
                emotionScore -= 20
                foundKeywords.append(keyword)
            }
        }
        
        return EmotionAnalysis(
            stressLevel: min(100, max(0, stressLevel)),
            emotionScore: min(100, max(-100, emotionScore)),
            detectedKeywords: Array(Set(foundKeywords)),
            confidence: 0.6
        )
    }
    
    private func provideFallbackResponse(for input: String) {
        let fallbackResponse: String
        
        if input.contains("壓力") || input.contains("累") {
            fallbackResponse = "聽起來你最近很辛苦呢。雖然網路有點問題，但我還是想陪伴你。要不要試試深呼吸？💙"
        } else if input.contains("開心") || input.contains("高興") {
            fallbackResponse = "太好了！你的快樂也感染了我呢 😊"
        } else if input.contains("難過") || input.contains("憂鬱") {
            fallbackResponse = "我能感受到你的情緒...請記住你並不孤單，我在這裡 🤗"
        } else {
            fallbackResponse = "謝謝你願意和我分享。雖然網路有點問題，但我還是很珍惜和你的對話 💙"
        }
        
        let aiMessage = ChatMessage(content: fallbackResponse, isUser: false, timestamp: Date())
        conversationHistory.append(aiMessage)
        currentResponse = fallbackResponse
        speakResponse(fallbackResponse)
    }
    
    private func speakResponse(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        utterance.volume = 0.8
        
        synthesizer.speak(utterance)
    }
    
    // MARK: - 公開方法
    func sendTextMessage(_ text: String) {
        processUserInput(text)
    }
    
    func clearConversation() {
        conversationHistory.removeAll()
        detectedEmotion = nil
        currentResponse = ""
        apiError = nil
        setupInitialGreeting()
    }
    
    func getConversationSummary() -> String {
        guard let emotion = detectedEmotion else {
            return "還需要更多對話來了解你的情緒狀態"
        }
        
        let confidence = Int(emotion.confidence * 100)
        return "根據 AI 分析，你現在\(emotion.emotionType)，壓力程度是\(emotion.stressCategory) (置信度 \(confidence)%)"
    }
}
