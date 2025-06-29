// MARK: - Main App File
import SwiftUI
import Photos
import PhotosUI

@main
struct ClearApp: App {
    @StateObject private var healthManager = HealthManager()
    @State private var appModel = AppModel()
    @StateObject private var photoManager = PhotoManager()

    #if os(visionOS)
    @State private var immersionStyle: ImmersionStyle = .progressive(0.0...1.0, initialAmount: 0.5)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    #endif

    var body: some Scene {
        WindowGroup(id: MyWindowID.mainWindow) {
            ContentView()
                .environmentObject(healthManager)
                .environment(appModel)
                .onGeometryChange(for: CGSize.self, of: \.size) { newValue in
                    print("視窗寬： \(newValue.width) 高：\(newValue.height)")
                }
                .onAppear {
                    appModel.isMainWindowOpen = true
                    #if os(visionOS)
                    Task {
                        await openImmersiveSpaceIfNeeded()
                    }
                    #endif
                }
                .onDisappear {
                    appModel.isMainWindowOpen = false
                }
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 480)

        #if os(visionOS)

        WindowGroup(id: MyWindowID.chatView) {
            CompactChatView(chatManager: SimpleChatGPTManager.shared) {}
                .environmentObject(healthManager)
                .environment(appModel)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 450, height: 480)
        .defaultWindowPlacement { content, context in
            if let contentWindow = context.windows.first(where: { $0.id == MyWindowID.mainWindow }) {
                WindowPlacement(.trailing(contentWindow))
            } else {
                WindowPlacement()
            }
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)

        ImmersiveSpace(id: appModel.forestImmersiveSpaceID) {
            ImmersiveSpaceView()
                .environment(appModel)
                .environmentObject(photoManager)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        #endif
    }

    #if os(visionOS)
    private func openImmersiveSpaceIfNeeded() async {
        print("Attempting to open immersive space...")
        if appModel.immersiveSpaceState == .closed {
            let result = await openImmersiveSpace(id: appModel.immersiveSpaceID)
            print("First attempt result: \(result)")
        } else {
            print("他還是開的...")
        }
    }
    #endif
}

enum MyWindowID {
    static let mainWindow = "mainWindow"
    static let chatView = "chatView"
}
