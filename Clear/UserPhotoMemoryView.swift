import SwiftUI
import Photos
import HealthKit
import UserNotifications

// MARK: - UserPhotoMemoryView.swift (圓形霧面邊框版)
struct UserPhotoMemoryView: View {
    let image: UIImage
    let position: CGPoint
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0
    @State private var isAnimating: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 150, height: 150)
                    .blur(radius: 6)
                    .opacity(0.6)

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 4)
                            .blur(radius: 4)
                    )
            }
            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)

            Text("💫")
                .font(.caption)
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .position(position)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                rotation = Double.random(in: -15...15)
            }

            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
