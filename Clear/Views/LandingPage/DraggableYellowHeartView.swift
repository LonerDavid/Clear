//
//  DraggableYellowHeartView.swift
//  Clear
//
//  Created by Haruaki on 2025/6/20.
//
import SwiftUI
import RealityKit
import RealityKitContent

#if os(visionOS)
struct DraggableYellowHeartView: View {
    @State private var position: SIMD3<Float> = [0, 0, 0]
    @State private var isDragging = false
    var body: some View {
        RealityView { content in
            if let entity = try? await Entity(named: "yellowheart", in: realityKitContentBundle) {
                entity.position.z -= 10
                entity.position = position
                entity.scale *= 0.1
                
                content.add(entity)
            }
        } update: { content in
            if let entity = content.entities.first {
                entity.position = position
            }
        }
        .frame(height: 180)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                // Map drag to x/y in 3D space (simple mapping for demo)
                position.x += Float(value.translation.width) * 0.002
                position.y -= Float(value.translation.height) * 0.002
            }
            .onEnded { _ in
                isDragging = false
            }
        )
    }
}
#endif
