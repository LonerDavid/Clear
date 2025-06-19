//
//  MemoryPhotoCardView.swift
//  Clear
//
//  Created by Haruaki on 2025/6/19.
//

import SwiftUI

// MARK: - MemoryPhotoCard.swift
struct MemoryPhotoCardView: View {
    let photo: String
    let index: Int
    let screenSize: CGSize
    @State private var rotation: Double = 0
    
    var body: some View {
        Text(photo)
            .font(.system(size: 50))
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .rotationEffect(.degrees(rotation))
            .position(
                x: CGFloat.random(in: 60...screenSize.width-60),
                y: CGFloat.random(in: 150...screenSize.height-150)
            )
            .onAppear {
                rotation = Double.random(in: -15...15)
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    rotation += Double.random(in: -5...5)
                }
            }
    }
}

//#Preview {
//    MemoryPhotoCardView()
//}
