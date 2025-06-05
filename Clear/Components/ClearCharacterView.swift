// MARK: - Main App File
import SwiftUI
import Photos
import PhotosUI

struct ClearCharacterView: View {
    let size: CGFloat
    var expression: String = "😊"
    var color: Color = .yellow
    @State private var animationOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // 使用自定義圖片替代原本的心形，保持相同的架構
            Group {
                if let characterImage = getCharacterImage() {
                    Image(uiImage: characterImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                } else {
                    // 完全保持原本的備用設計
                    Image(systemName: "heart.fill")
                        .font(.system(size: size))
                        .foregroundStyle(color)
                    
                    // 表情符號保持在原本位置
                    Text(expression)
                        .font(.system(size: size * 0.35))
                        .offset(y: -size * 0.1)
                }
            }
            .shadow(color: color.opacity(0.6), radius: 15, x: 0, y: 5)
        }
        .offset(y: animationOffset)
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            // 保持原本的動畫邏輯
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                animationOffset = -15
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                rotationAngle = 5
            }
        }
    }
    
    // 根據情緒狀態選擇對應的圖片
    private func getCharacterImage() -> UIImage? {
        let imageName: String
        
        // 根據 color 參數選擇對應的圖片（與你原本的邏輯一致）
        switch color {
        case .yellow:
            imageName = "clear_happy"      // 對應第一張黃色開心圖片
        case .green:
            imageName = "clear_calm"      // 綠色也用開心圖片，或創建 clear_calm
        case .orange:
            imageName = "clear_stressed"   // 對應第二張橙色圖片
        case .red:
            imageName = "clear_sad"    // 對應第四張藍色焦慮圖片

        default:
            imageName = "clear_calm"      // 默認使用開心圖片
        }
        
        return UIImage(named: imageName)
    }
}
struct ClearButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(isPrimary ? .black : .white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isPrimary ? .white : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.white, lineWidth: isPrimary ? 0 : 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}
