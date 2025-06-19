// MARK: - Main App File
import SwiftUI
import Photos
import PhotosUI

@main
struct ClearApp: App {
    @StateObject private var healthManager = HealthManager()
    @State private var appModel = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
                .environment(appModel)
                .onGeometryChange(for: CGSize.self, of: \.size) { newValue in
                    print("視窗寬： \(newValue.width) 高：\(newValue.height)")
                }
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 450)
        
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
    }
}
