//
//  CompactChatView.swift
//  Clear
//
//  Created by AppleUser on 2025/6/22.
//
import SwiftUI

struct CompactChatView: View {
    @ObservedObject var chatManager: SimpleChatGPTManager
    let onClose: () -> Void
    @Environment(AppModel.self) var appModel
    @State private var messageText = ""
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        VStack(spacing: 0) {
            // 標題列 - 置中
            #if os(visionOS)
            HStack {
                Text("💬 與 Clear 對話")
                    .padding(.horizontal, 8)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    if !appModel.isMainWindowOpen {
                        openWindow(id: MyWindowID.mainWindow)
                    }
                    dismissWindow(id: MyWindowID.chatView)
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            #else
            HStack {
                Text("💬 與 Clear 對話")
                    .padding(.horizontal, 8)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                
                Button("關閉") {
                    onClose()
                }
                .buttonStyle(ClearButtonStyle(isPrimary: false))
                
            }
            .padding()
//            .background(.ultraThinMaterial)
            .frame(maxWidth: .infinity) // 標題列置中
            #endif
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
                    Button(action: {
                        if chatManager.isListening {
                            chatManager.stopListening()
                        } else {
                            chatManager.startListening()
                        }
                    }) {
                        Image(systemName: chatManager.isListening ? "mic.fill" : "mic")
                            .font(.system(size: 25))
                            .foregroundStyle(chatManager.isListening ? .red : .primary)
                            .frame(width: 42, height: 42)
                            .background(Material.thick)
                            .clipShape(Circle())
                    }
                    #if os(visionOS)
                    .buttonStyle(.plain)
                    #else
                    .buttonStyle(VoiceButtonStyle(isActive: chatManager.isListening))
                    #endif
                    
                    TextField("輸入訊息...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            HStack {
                                Spacer()
                                if !messageText.isEmpty {
                                    Button(action: {
                                        messageText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.trailing, 8)
                                }
                            }
                        )

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(messageText.isEmpty ? .black.opacity(0.3) : .primary)
                            .frame(width: 40, height: 40)
                    }
                    #if os(visionOS)
                    .buttonStyle(.plain)
                    #else
                    .buttonStyle(ClearButtonStyle(isPrimary: false))
                    #endif
                    .disabled(messageText.isEmpty)
                }
                .frame(maxWidth: .infinity) // 輸入欄置中
                
                if let error = chatManager.speechError ?? chatManager.apiError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity) // 錯誤訊息置中
                }
            }
            .padding()
            #if !os(visionOS)
            .background(.ultraThinMaterial)
            #endif
            .frame(maxWidth: .infinity) // 整個輸入區域置中
        }
        #if !os(visionOS)
        .background(.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 整個對話框置中
        #endif
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        chatManager.sendTextMessage(messageText)
        messageText = ""
    }
}

#Preview {
    CompactChatView(chatManager: SimpleChatGPTManager.shared, onClose: {})
}
