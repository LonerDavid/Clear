//
//  ClearAllButton.swift
//  Clear
//
//  Created by AppleUser on 2025/6/22.
//

import SwiftUI

struct ClearAllButton: ViewModifier {
    @Binding var text: String
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
//                .hoverEffectDisabled()
            }
        }
    }
}
