import SwiftUI
// MARK: -  API 設置界面
struct SimpleAPISetupView: View {
    @ObservedObject var chatManager: SimpleChatGPTManager
    @State private var apiKey: String = ""
    @State private var isValid: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String?
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 15) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("啟用 AI 智能對話")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("設置 OpenAI API Key 讓 Clear 擁有真正的 AI 智能")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("OpenAI API Key")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    SecureField("sk-proj-... 或 sk-...", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: apiKey) { _, newValue in
                            isValid = validateAPIKey(newValue)
                            errorMessage = nil
                        }
                    
                    HStack {
                        Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(isValid ? .green : .orange)
                        
                        Text(isValid ? "格式正確 ✓" : "請輸入完整的 API Key")
                            .font(.caption)
                            .foregroundStyle(isValid ? .green : .orange)
                    }
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 15) {
                Button("保存並啟用 AI") {
                    saveAPIKey()
                }
                #if os(visionOS)
                .buttonStyle(.bordered)
                #else
                .buttonStyle(ClearButtonStyle())
                #endif
                .disabled(!isValid)
                
                Button("暫時跳過") {
                    onComplete()
                }
                #if os(visionOS)
                .buttonStyle(.bordered)
                #else
                .buttonStyle(ClearButtonStyle(isPrimary: false))
                #endif
                
                Link("免費取得 API Key", destination: URL(string: "https://platform.openai.com/api-keys")!)
                    .font(.caption)
                    #if os(visionOS)
                    .foregroundStyle(.secondary)
                    #else
                    .foregroundStyle(.blue)
                    #endif
            }
            
            if showSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        #if os(visionOS)
                        .foregroundStyle(.primary)
                        #else
                        .foregroundStyle(.green)
                        #endif
                    Text("API Key 設置成功！AI 對話功能已啟用 🎉")
                        #if os(visionOS)
                        .foregroundStyle(.primary)
                        #else
                        .foregroundStyle(.green)
                        #endif
                        .font(.subheadline)
                }
                .padding()
                .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(30)
        .background(.clear, in: RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal, 20)
    }
    
    private func validateAPIKey(_ key: String) -> Bool {
        return key.hasPrefix("sk-") && key.count >= 40
    }
    
    private func saveAPIKey() {
        guard validateAPIKey(apiKey) else {
            errorMessage = "API Key 格式不正確，請檢查是否完整"
            return
        }
        
        chatManager.setAPIKey(apiKey)
        
        if chatManager.hasValidAPIKey {
            showSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        } else {
            errorMessage = "設置失敗，請重試"
        }
    }
}

// MARK: - API Key 管理視圖
struct APIKeyManagementView: View {
    @ObservedObject var chatManager: SimpleChatGPTManager
    @State private var showingSetup = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: chatManager.hasValidAPIKey ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(chatManager.hasValidAPIKey ? .green : .red)
                
                Text(chatManager.hasValidAPIKey ? "AI 智能已啟用" : "AI 智能未啟用")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
            }
            
            if chatManager.hasValidAPIKey {
                VStack(spacing: 10) {
                    Text("✅ ChatGPT API 已連接")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                    
                    Button("重新設置 API Key") {
                        showingSetup = true
                    }
                    .buttonStyle(ClearButtonStyle(isPrimary: false))
                    
                    Button("移除 API Key") {
                        chatManager.clearAPIKey()
                    }
                    .buttonStyle(ClearButtonStyle(isPrimary: false))
                }
            } else {
                VStack(spacing: 10) {
                    Text("❌ 需要設置 API Key 才能使用 AI 功能")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                    
                    Button("設置 API Key") {
                        showingSetup = true
                    }
                    .buttonStyle(ClearButtonStyle())
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .sheet(isPresented: $showingSetup) {
            SimpleAPISetupView(chatManager: chatManager) {
                showingSetup = false
            }
        }
    }
}


#Preview {
    SimpleAPISetupView(chatManager: SimpleChatGPTManager.shared, onComplete: {})
}
