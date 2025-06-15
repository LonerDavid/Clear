// MARK: - PhotoManager.swift (新增文件)
import SwiftUI
import Photos
import HealthKit  // ← 新增這行
import UserNotifications  // ← 新增這行

// MARK: - 更新權限提示組件
struct PermissionPromptView: View {
    @ObservedObject var photoManager: PhotoManager
    let onDismiss: () -> Void
    @State private var showAnimation = false
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .scaleEffect(showAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: showAnimation)
            }
            
            VStack(spacing: 15) {
                Text("分享您的美好回憶")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("讓 Clear 存取您的相簿，\n在療癒空間中重現真實的美好時刻")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 12) {
                Button("允許存取相簿") {
                    photoManager.requestPhotoLibraryPermission()
                }
                .buttonStyle(ClearButtonStyle())
                
                Button("暫時跳過") {
                    onDismiss()
                }
                .buttonStyle(ClearButtonStyle(isPrimary: false))
            }
        }
        .padding(30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
        .onAppear {
            showAnimation = true
        }
    }
}
