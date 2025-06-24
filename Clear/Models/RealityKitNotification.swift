//
//  RealityKitNotification.swift
//  Clear
//
//  Created by Haruaki on 2025/6/24.
//


//
//  RealityKitNotification.swift
//  RCP_HW
//
//  Created by Loner David on 2025/2/2.
//

import RealityKit
import Foundation

struct RealityKitNotification {
    let id: String
    let entity: Entity
    let scene: RealityKit.Scene
    
    init?(_ notification: Notification) {
        guard
            let content = notification.userInfo,
            let id = content["RealityKit.NotificationTrigger.Identifier"] as? String,
            let entity = content["RealityKit.NotificationTrigger.SourceEntity"] as? Entity,
            let scene = content["RealityKit.NotificationTrigger.Scene"] as? RealityKit.Scene
        else {
            return nil
        }
        self.id = id
        self.entity = entity
        self.scene = scene
    }
}
