// MARK: - Main App File
import SwiftUI
import Photos
import PhotosUI

@main
struct ClearApp: App {
    @StateObject private var healthManager = HealthManager()
    @State private var appModel = AppModel()
    var body: some Scene {
        WindowGroup(id: MyWindowID.mainWindow) {
            ContentView()
                .environmentObject(healthManager)
                .environment(appModel)
                .onGeometryChange(for: CGSize.self, of: \.size) { newValue in
                    print("視窗寬： \(newValue.width) 高：\(newValue.height)")
                }
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 480)
        #if os(visionOS)
        
        WindowGroup(id: MyWindowID.chatView) {
            CompactChatView(chatManager: SimpleChatGPTManager.shared) {
                // Close window action - this will be handled by the window system
            }
            
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
            ForestImmersiveView()
                .environment(appModel)
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
}

enum MyWindowID {
    static let mainWindow = "mainWindow"
    static let chatView = "chatView"
}
