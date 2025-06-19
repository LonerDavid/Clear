
import SwiftUI
import Photos
import PhotosUI

// MARK: - ForestEnvironmentView.swift
// 簡化的 ForestEnvironmentView - 移除樹木和遠山剪影，只保留備用功能
struct ForestEnvironmentView: View {
    var body: some View {
        // 🌲 現在只作為備用背景，當 foggy_forest 圖片不存在時使用
        Color.clear
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
// 修正的 CloudsOverlayView - 替換你現有的版本
struct CloudsOverlayView: View {
    let opacity: Double
    let dispersedClouds: Set<Int>
    let onCloudTap: (Int) -> Void

    // 固定的雲朵配置
    let cloudConfigs: [(position: CGPoint, size: CGFloat)] = [
        (CGPoint(x: 100, y: 200), 110),
        (CGPoint(x: 280, y: 180), 130),
        (CGPoint(x: 350, y: 250), 120),
        (CGPoint(x: 70, y: 350), 115),
        (CGPoint(x: 300, y: 380), 125),
        (CGPoint(x: 180, y: 500), 135),
        (CGPoint(x: 320, y: 480), 110),
        (CGPoint(x: 200, y: 320), 120)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<cloudConfigs.count, id: \.self) { index in
                if !dispersedClouds.contains(index) {
                    let config = cloudConfigs[index]
                    DreamyCloudView(
                        size: config.size,
                        opacity: opacity,
                        index: index
                    )
                    .position(config.position)
                    .zIndex(2)
                    .contentShape(Circle())
                    .onTapGesture {
                        print("✨ 點擊雲朵 \(index)")
                        onCloudTap(index)
                    }
                }
            }
        }
    }
}


struct DreamyCloudView: View {
    let size: CGFloat
    let opacity: Double
    let index: Int
    @State private var animationOffset: CGFloat = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // 🌟 主雲霧體
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(opacity * 0.9),
                            .white.opacity(opacity * 0.6),
                            .white.opacity(opacity * 0.3)
                        ],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size * 0.6)
            
            // 🌟 左側雲朵
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(opacity * 0.8),
                            .white.opacity(opacity * 0.4)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.7, height: size * 0.5)
                .offset(x: -size * 0.3, y: -size * 0.1)
            
            // 🌟 右側雲朵
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(opacity * 0.8),
                            .white.opacity(opacity * 0.4)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.7, height: size * 0.5)
                .offset(x: size * 0.3, y: -size * 0.1)
            
            // 🌟 頂部小雲朵
            Circle()
                .fill(.white.opacity(opacity * 0.7))
                .frame(width: size * 0.5, height: size * 0.4)
                .offset(x: 0, y: -size * 0.3)
        }
        .blur(radius: 8)
        .offset(x: animationOffset, y: sin(rotationAngle * .pi / 180) * 8)
        .scaleEffect(scaleEffect)
        .frame(width: size + 100, height: size + 100) // 🔑 確保點擊區域足夠大
        .contentShape(Circle()) // 🔑 圓形點擊區域
        .onAppear {
            // 🎭 多層動畫效果
            withAnimation(.easeInOut(duration: Double.random(in: 5...8)).repeatForever(autoreverses: true)) {
                animationOffset = CGFloat.random(in: -20...20)
            }
            
            withAnimation(.easeInOut(duration: Double.random(in: 6...10)).repeatForever(autoreverses: true)) {
                scaleEffect = CGFloat.random(in: 0.9...1.1)
            }
            
            withAnimation(.linear(duration: Double.random(in: 15...25)).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}
