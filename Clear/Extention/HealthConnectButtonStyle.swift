//
//  HealthConnectButtonStyle.swift
//  Clear
//
//  Created by Haruaki on 2025/6/20.
//
import SwiftUI

struct HealthConnectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: "applewatch")
                .font(.title3)
            
            configuration.label
        }
        .font(.headline)
        .foregroundStyle(.white)
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 25)
        )
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}
