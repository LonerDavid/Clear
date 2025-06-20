// MARK: - Main App File
import SwiftUI
import Photos
import PhotosUI

// MARK: - App Delegate for Notifications
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 請求通知權限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("通知權限已獲得")
            }
        }
        return true
    }
}
