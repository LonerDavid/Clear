//
//  MemoryPhotosView.swift
//  Clear
//
//  Created by Haruaki on 2025/6/19.
//

import SwiftUI

struct MemoryPhotosView: View {
    let photos: [String]
    let screenSize: CGSize
    @State private var showPhotos = false
    
    var body: some View {
        ZStack {
            ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                MemoryPhotoCardView(photo: photo, index: index, screenSize: screenSize)
                    .opacity(showPhotos ? 1 : 0)
                    .scaleEffect(showPhotos ? 1 : 0.3)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.6)
                        .delay(Double(index) * 0.2),
                        value: showPhotos
                    )
            }
        }
        .onAppear {
            withAnimation {
                showPhotos = true
            }
        }
    }
}

//#Preview {
//    MemoryPhotosView()
//}
