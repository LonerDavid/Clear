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
    @State private var testPEEntity: Entity = Entity()
    @State private var photoPEEntity1: Entity = Entity()
    @State private var photoPEEntity2: Entity = Entity()
    @State private var photoPEEntity3: Entity = Entity()
    @State private var photoPEEntity4: Entity = Entity()
    @State private var photoPEEntity5: Entity = Entity()
    @State private var scenePEEntity: Entity = Entity()
    
    @State private var isPhotoPEDisapeared1: Bool = false
    @State private var isPhotoPEDisapeared2: Bool = false
    @State private var isPhotoPEDisapeared3: Bool = false
    @State private var isPhotoPEDisapeared4: Bool = false
    @State private var isPhotoPEDisapeared5: Bool = false
    
    @State private var hasPlayedScenePE = false
    
    private let realityKitNotificationPublisher = NotificationCenter.default
        .publisher(for: .init("RealityKit.PEDisappearNotificationAction"))
        .compactMap(RealityKitNotification.init)
    
    var allPEDisappeared: Bool {
        isPhotoPEDisapeared1 && isPhotoPEDisapeared2 && isPhotoPEDisapeared3 && isPhotoPEDisapeared4 && isPhotoPEDisapeared5
    }
    
    var body: some View {
        Group {
            RealityView { content in
                guard let forestContentEntity = try? await Entity(named: "TempForestScene", in: realityKitContentBundle) else {
                    print("找不到Immersive Space")
                    return
                }
                guard let photoPEEntity1 = forestContentEntity.findEntity(named: "PhotoParticleEmitter1"),
                      let photoPEEntity2 = forestContentEntity.findEntity(named: "PhotoParticleEmitter2"),
                      let photoPEEntity3 = forestContentEntity.findEntity(named: "PhotoParticleEmitter3"),
                      let photoPEEntity4 = forestContentEntity.findEntity(named: "PhotoParticleEmitter4"),
                      let photoPEEntity5 = forestContentEntity.findEntity(named: "PhotoParticleEmitter5"),
                      let scenePEEntity = forestContentEntity.findEntity(named: "SceneParticleEmitter")
                    else {
                    print("找不到Particle Emitter")
                    return
                }
                self.photoPEEntity1 = photoPEEntity1
                self.photoPEEntity2 = photoPEEntity2
                self.photoPEEntity3 = photoPEEntity3
                self.photoPEEntity4 = photoPEEntity4
                self.photoPEEntity5 = photoPEEntity5
                self.scenePEEntity = scenePEEntity
                
                content.add(forestContentEntity)
                
            }
            .gesture(tapGesture)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PEDisappearNotificationAction1")).compactMap(RealityKitNotification.init)) { _ in
                isPhotoPEDisapeared1 = true
                print("PE1 Disappeared? :" + String(isPhotoPEDisapeared1)) //test only
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PEDisappearNotificationAction2")).compactMap(RealityKitNotification.init)) { _ in
                isPhotoPEDisapeared2 = true
                print("PE2 Disappeared? :" + String(isPhotoPEDisapeared2)) //test only
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PEDisappearNotificationAction3")).compactMap(RealityKitNotification.init)) { _ in
                isPhotoPEDisapeared3 = true
                print("PE3 Disappeared? :" + String(isPhotoPEDisapeared3)) //test only
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PEDisappearNotificationAction4")).compactMap(RealityKitNotification.init)) { _ in
                isPhotoPEDisapeared4 = true
                print("PE4 Disappeared? :" + String(isPhotoPEDisapeared4)) //test only
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PEDisappearNotificationAction5")).compactMap(RealityKitNotification.init)) { _ in
                isPhotoPEDisapeared5 = true
                print("PE5 Disappeared? :" + String(isPhotoPEDisapeared5)) //test only
            }
            .onChange(of: allPEDisappeared) { newValue in
                if newValue && !hasPlayedScenePE {
                    hasPlayedScenePE = true
                    scenePEEntity.playAnimation(named: "ScenePE")
                }
            }
        }
    }
    
    var tapGesture: some Gesture {
        TapGesture()
            .targetedToEntity(photoPEEntity1)
            .targetedToEntity(photoPEEntity2)
            .targetedToEntity(photoPEEntity3)
            .targetedToEntity(photoPEEntity4)
            .targetedToEntity(photoPEEntity5)
            .onEnded { _ in
                guard photoPEEntity1.applyTapForBehaviors(),
                      photoPEEntity2.applyTapForBehaviors(),
                      photoPEEntity3.applyTapForBehaviors(),
                      photoPEEntity4.applyTapForBehaviors(),
                      photoPEEntity5.applyTapForBehaviors()
                else {
                    print("Tap Behaviors not found!!!")
                    return
                }
            }
    }
}

#Preview(immersionStyle: .full) {
    ForestImmersiveView()
        .environment(AppModel())
}
#endif
