//
//  ImmersiveTestView.swift
//  Clear
//
//  Created by Haruaki on 2025/6/19.
//

import SwiftUI

struct ImmersiveTestView: View {
    var body: some View {
        VStack {
            #if os(visionOS)
            ToggleImmersiveSpaceButton()
            #endif
        }
    }
}

#Preview {
    ImmersiveTestView()
}
