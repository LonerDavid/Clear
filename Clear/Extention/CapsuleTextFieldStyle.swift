//
//  CapsuleTextFieldStyle.swift
//  Clear
//
//  Created by AppleUser on 2025/6/20.
//

import SwiftUI

struct CapsuleTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(7)
                .background(Material.thick)
                .cornerRadius(20)
//                .shadow(color: .gray, radius: 10)
        }
}
