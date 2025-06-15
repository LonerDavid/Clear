// MARK: - Main App File
import SwiftUI
import Photos
import PhotosUI

@main
struct ClearApp: App {
    @StateObject private var healthManager = HealthManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
        }
    }
}
