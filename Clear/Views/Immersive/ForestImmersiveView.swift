//
//  ForestImmersiveView.swift
//  Clear
//
//  Created by Haruaki on 2025/6/19.
//
#if os(visionOS)
import SwiftUI
import RealityKit
import RealityKitContent

struct ForestImmersiveView: View {
    
    var body: some View {
        RealityView { content in
            if let forestContentEntity = try? await Entity(named: "TempForestScene", in: realityKitContentBundle) {
                content.add(forestContentEntity)
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ForestImmersiveView()
        .environment(AppModel())
}
#endif
