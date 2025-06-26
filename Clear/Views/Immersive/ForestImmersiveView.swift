#if os(visionOS)
import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct ForestImmersiveView: View {
    @EnvironmentObject var photoManager: PhotoManager

    @State private var forestContentEntity: Entity = Entity()
    @State private var photoPEEntity1: Entity = Entity()
    @State private var photoPEEntity2: Entity = Entity()
    @State private var photoPEEntity3: Entity = Entity()

    @State private var isPhotoPEDisapeared1: Bool = false
    @State private var isPhotoPEDisapeared2: Bool = false
    @State private var isPhotoPEDisapeared3: Bool = false

    @State private var player: AVAudioPlayer?

    var allPEDisappeared: Bool {
        isPhotoPEDisapeared1 && isPhotoPEDisapeared2 && isPhotoPEDisapeared3
    }

    var body: some View {
        ZStack {
            RealityView { content in
                guard let forestEntity = try? await Entity(named: "TempForestScene", in: realityKitContentBundle) else {
                    print("❌ 找不到 Immersive Space")
                    return
                }

                guard let pe1 = forestEntity.findEntity(named: "PhotoParticleEmitter1"),
                      let pe2 = forestEntity.findEntity(named: "PhotoParticleEmitter2"),
                      let pe3 = forestEntity.findEntity(named: "PhotoParticleEmitter3") else {
                    print("❌ 找不到 Particle Emitter")
                    return
                }

                addTapSupport(to: pe1, name: "PE1")
                addTapSupport(to: pe2, name: "PE2")
                addTapSupport(to: pe3, name: "PE3")

                self.forestContentEntity = forestEntity
                self.photoPEEntity1 = pe1
                self.photoPEEntity2 = pe2
                self.photoPEEntity3 = pe3

                content.add(forestEntity)
            }
            .onAppear {
                photoManager.requestPhotoLibraryPermission()
            }
            .gesture(TapGesture()
                .targetedToEntity(photoPEEntity1)
                .onEnded { _ in
                    print("✅ Tapped PE1")
                    if photoPEEntity1.applyTapForBehaviors() {
                        isPhotoPEDisapeared1 = true
                        addPhotoToEntity(targetEntity: photoPEEntity1)
                    }
                })
            .gesture(TapGesture()
                .targetedToEntity(photoPEEntity2)
                .onEnded { _ in
                    print("✅ Tapped PE2")
                    if photoPEEntity2.applyTapForBehaviors() {
                        isPhotoPEDisapeared2 = true
                        addPhotoToEntity(targetEntity: photoPEEntity2)
                    }
                })
            .gesture(TapGesture()
                .targetedToEntity(photoPEEntity3)
                .onEnded { _ in
                    print("✅ Tapped PE3")
                    if photoPEEntity3.applyTapForBehaviors() {
                        isPhotoPEDisapeared3 = true
                        addPhotoToEntity(targetEntity: photoPEEntity3)
                    }
                })

            if allPEDisappeared {
                if !photoManager.hasPermission {
                    ProgressView("請授權相簿權限...")
                } else if photoManager.isLoadingPhotos {
                    ProgressView("載入回憶照片中...")
                } else if photoManager.userPhotos.isEmpty {
                    ProgressView("載入回憶照片中...")
                        .onAppear {
                            photoManager.loadUserPhotos()
                        }
                }
            }
        }
    }

    private func addTapSupport(to entity: Entity, name: String) {
        if entity.components[CollisionComponent.self] == nil {
            entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.5)]))
            print("✅ 已加 CollisionComponent 給 \(name)")
        }
        if entity.components[InputTargetComponent.self] == nil {
            entity.components.set(InputTargetComponent())
            print("✅ 已加 InputTargetComponent 給 \(name)")
        }
    }

    private func addPhotoToEntity(targetEntity: Entity) {
        guard let photo = photoManager.userPhotos.randomElement() else {
            print("❌ 沒有可用照片")
            return
        }

        Task {
            do {
                let texture = try await TextureResource(
                    image: photo,
                    options: TextureResource.CreateOptions(
                        semantic: .color,
                        mipmapsMode: .none
                    )
                )
                var material = UnlitMaterial()
                material.color = .init(texture: .init(texture))

                let planeSize: Float = 1.2
                let planeMesh = MeshResource.generatePlane(width: planeSize, height: planeSize, cornerRadius: 0.1)
                let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])

                planeEntity.position = targetEntity.position

                if let camera = forestContentEntity.scene?.findEntity(named: "ARCamera") {
                    let cameraPosition = camera.position(relativeTo: nil)
                    planeEntity.look(at: cameraPosition, from: planeEntity.position, upVector: [0, 1, 0], relativeTo: nil)
                } else {
                    planeEntity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
                }

                planeEntity.scale = [0.01, 0.01, 0.01]

                forestContentEntity.addChild(planeEntity)

                planeEntity.move(to: Transform(scale: [1, 1, 1], rotation: planeEntity.orientation, translation: planeEntity.position), relativeTo: planeEntity.parent, duration: 0.8, timingFunction: .easeInOut)

                playSound()
                addFloatingAnimation(to: planeEntity)

                print("✅ 照片已加入 RealityKit 場景")
            } catch {
                print("❌ TextureResource 生成失敗：\(error.localizedDescription)")
            }
        }
    }

    private func addFloatingAnimation(to entity: Entity) {
        let originalPosition = entity.position
        let floatUp = Transform(translation: originalPosition + SIMD3<Float>(0, 0.02, 0))
        let floatDown = Transform(translation: originalPosition)

        entity.move(to: floatUp, relativeTo: entity.parent, duration: 1.5, timingFunction: .easeInOut)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            entity.move(to: floatDown, relativeTo: entity.parent, duration: 1.5, timingFunction: .easeInOut)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.addFloatingAnimation(to: entity)
            }
        }
    }

    private func playSound() {
        guard let soundURL = Bundle.main.url(forResource: "photo_pop", withExtension: "mp3") else {
            print("❌ 找不到音效檔案")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.play()
        } catch {
            print("❌ 音效播放失敗：\(error.localizedDescription)")
        }
    }
}

#Preview(immersionStyle: .full) {
    ForestImmersiveView()
        .environmentObject(PhotoManager())
        .environment(AppModel())
}
#endif


import SwiftUI

struct PhotoDisplayView: View {
    var photos: [CGImage]

    var body: some View {
        VStack {
            Text("回憶照片")
                .font(.largeTitle)
                .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(photos.indices, id: \.self) { index in
                        Image(decorative: photos[index], scale: 1)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                    }
                }
                .padding()
            }
        }
        .background(Color.white.opacity(0.8).cornerRadius(20))
        .padding()
    }
}
