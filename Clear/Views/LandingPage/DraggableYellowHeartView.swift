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
    @GestureState private var clearInitialTransform: EntityTransformState?
    let clearPosition = Entity()
    @State private var initialPosition: SIMD3<Float>? = nil
    @State private var initialOrientation: simd_quatf? = nil
    @State private var currentRotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
    
    var body: some View {
        RealityView { content in
            guard let clearScene = try? await Entity(named: "yellowheart", in: realityKitContentBundle) else {
                print("找不到Clear模型!!!")
                return
            }
//            clearScene.scale *= 0.1
            clearPosition.addChild(clearScene)
            clearPosition.position.z -= 0.15
            content.add(clearPosition)
            // Store initial transform only once
            if initialPosition == nil && initialOrientation == nil {
                initialPosition = clearPosition.position
                initialOrientation = clearPosition.orientation
                currentRotation = clearPosition.orientation
            }
        }
        .frame(maxWidth: 250, maxHeight: 250)
        .gesture(dragToRotateGesture)
    }
    
    var dragToRotateGesture: some Gesture {
        DragGesture()
            .targetedToEntity(clearPosition)
            .onChanged { value in
//                guard let initialOrientation = initialOrientation else { return }
                // Map drag x to y-axis rotation, drag y to x-axis rotation
                let sensitivity: Float = 0.01
                let deltaX = Float(value.translation.width) * sensitivity
                let deltaY = Float(value.translation.height) * sensitivity
                // Compose rotations: Y (up) and X (right)
                let rotationY = simd_quatf(angle: deltaX, axis: [0, 1, 0])
                let rotationX = simd_quatf(angle: deltaY, axis: [1, 0, 0])
                let newRotation = rotationY * rotationX * currentRotation
                clearPosition.orientation = newRotation
            }
            .onEnded { value in
                // Save the new rotation as the current rotation
                let sensitivity: Float = 0.01
                let deltaX = Float(value.translation.width) * sensitivity
                let deltaY = Float(value.translation.height) * sensitivity
                let rotationY = simd_quatf(angle: deltaX, axis: [0, 1, 0])
                let rotationX = simd_quatf(angle: deltaY, axis: [1, 0, 0])
                currentRotation = rotationY * rotationX * currentRotation
                // Reset to initial position and orientation
                // if let initialPosition = initialPosition, let initialOrientation = self.initialOrientation {
                //     clearPosition.position = initialPosition
                //     clearPosition.orientation = initialOrientation
                //     currentRotation = initialOrientation
                // }
            }
    }
}

struct EntityTransformState {
    let orientation: simd_quatf
    let position: SIMD3<Float>
}

#Preview(immersionStyle: .mixed) {
    DraggableYellowHeartView()
        .environment(AppModel())
}
#endif
