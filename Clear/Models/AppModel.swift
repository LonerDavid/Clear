//
//  AppModel.swift
//  Clear
//
//  Created by Haruaki on 2025/6/19.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    let forestImmersiveSpaceID = "ForestImmersiveSpace"
    var currentImmersiveSpaceID: String? = nil
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var isMainWindowOpen: Bool = true
}
