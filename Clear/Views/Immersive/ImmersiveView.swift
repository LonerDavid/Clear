//
//  ImmersiveView.swift
//  Clear
//
//  Created by Haruaki on 2025/6/19.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
            
            if let clearContentEntity = try? await Entity(named: "yellowheart", in: realityKitContentBundle) {
                content.add(clearContentEntity)
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
