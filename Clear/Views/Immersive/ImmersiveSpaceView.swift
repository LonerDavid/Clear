// ImmersiveSpaceView 修改
import SwiftUI
import Photos

struct ImmersiveSpaceView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var photoManager: PhotoManager
    @State private var cloudOpacity: Double = 0.9
    @State private var dispersedClouds: Set<Int> = []
    @State private var revealedPhotos: [CloudPhoto] = []
    @State private var usedImages: Set<CGImage> = []
    @State private var showClearBackground = false
    @State private var showEmotionReportButton = false

    struct CloudPhoto: Identifiable {
        let id = UUID()
        let image: CGImage
        let emoji: String
        let position: CGPoint
        let isUserPhoto: Bool
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(showClearBackground ? "clear_forest" : "foggy_forest")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .zIndex(0)

                CloudsOverlayView(
                    opacity: cloudOpacity,
                    dispersedClouds: dispersedClouds,
                    onCloudTap: { index in
                        revealMemory(at: index, in: geometry.size)
                    }
                )
                .allowsHitTesting(!showClearBackground)
                .zIndex(1)

                ForEach(revealedPhotos) { photo in
                    UserPhotoMemoryView(image: UIImage(cgImage: photo.image), position: photo.position)
                        .zIndex(2)
                }

                VStack {
                    Spacer()
                    if showEmotionReportButton {
                        Button("查看情緒報告") {
                            withAnimation(.spring(response: 0.6)) {
                                appState.currentView = .emotionReport
                            }
                        }
                        .buttonStyle(ClearButtonStyle())
                        .transition(.opacity)
                        .padding(.bottom, 10)
                    }
                }
                .frame(maxWidth: .infinity)
                .zIndex(3)
            }
            .onAppear {
                if photoManager.hasPermission {
                    photoManager.loadUserPhotos()
                }
            }
        }
    }

    private func revealMemory(at index: Int, in size: CGSize) {
        guard !dispersedClouds.contains(index) else { return }

        withAnimation(.easeOut(duration: 1.0)) {
            dispersedClouds.insert(index)
            cloudOpacity = max(0, cloudOpacity - 0.2)

            let position = CGPoint(
                x: CGFloat.random(in: 100...size.width - 100),
                y: CGFloat.random(in: 150...size.height - 150)
            )

            let availablePhotos = photoManager.userPhotos.filter { !usedImages.contains($0) }

            if let photo = availablePhotos.randomElement() {
                usedImages.insert(photo)
                revealedPhotos.append(CloudPhoto(image: photo, emoji: "", position: position, isUserPhoto: true))
            }

            if dispersedClouds.count >= 5 && !showClearBackground {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        showClearBackground = true
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation(.spring()) {
                        showEmotionReportButton = true
                    }
                }
            }
        }
    }
}

#Preview {
    ImmersiveSpaceView()
        .environmentObject(AppState())
        .environmentObject(PhotoManager())
}
