// MARK: - Main App File
import SwiftUI
import Photos
import PhotosUI

// MARK: - 聊天訊息氣泡
struct ChatMessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(message.content)
                        .padding(12)
                        .background(.blue.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: 250, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("🤖")
                            .font(.title3)
                        
                        Text(message.content)
                            .padding(12)
                            .background(.gray.opacity(0.3))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .padding(.leading, 32)
                }
                .frame(maxWidth: 250, alignment: .leading)
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 情緒顯示卡片
struct EmotionDisplayCard: View {
    let emotion: EmotionAnalysis
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text("情緒狀態")
                    .font(.caption)
                    .foregroundStyle(.gray)
                Text(emotion.emotionType)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("壓力程度")
                    .font(.caption)
                    .foregroundStyle(.gray)
                Text("\(Int(emotion.stressLevel))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(emotion.stressCategoryColor)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 更新的語音波形視圖
struct VoiceWaveView: View {
    @Binding var isAnimating: Bool
    let isAIActive: Bool
    @State private var waveHeights: [CGFloat] = Array(repeating: 15, count: 5)
    
    var body: some View {
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
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                startWaveAnimation()
            }
        }
        .scaleEffect(isAIActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isAIActive)
    }
    
    private func startWaveAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            for i in 0..<waveHeights.count {
                waveHeights[i] = CGFloat.random(in: 8...35)
            }
        }
    }
}

struct VoiceButtonStyle: ButtonStyle {
    let isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .background(
                Circle()
                    .fill(isActive ? .red.opacity(0.8) : .blue.opacity(0.8))
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}
