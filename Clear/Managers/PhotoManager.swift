import SwiftUI
import Photos
import HealthKit
import UserNotifications

// MARK: - 安全的 PhotoManager
class PhotoManager: ObservableObject {
    @Published var userPhotos: [CGImage] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoadingPhotos = false
    @Published var hasPermission = false
    @Published var errorMessage: String?
    @Published var debugInfo: String = ""
    @Published var loadedPhotoCount: Int = 0

    init() {
        checkCurrentAuthorizationStatus()
    }

    private func checkCurrentAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        hasPermission = authorizationStatus == .authorized || authorizationStatus == .limited
        debugInfo = "權限狀態: \(authorizationStatus.rawValue)"
        print("📷 當前相簿權限狀態: \(authorizationStatus)")
    }

    func requestPhotoLibraryPermission() {
        print("📱 開始請求相簿權限...")
        debugInfo = "正在請求權限..."

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.authorizationStatus == .authorized || self.authorizationStatus == .limited {
                print("✅ 已有權限，直接載入照片")
                self.loadUserPhotos()
                return
            }

            if self.authorizationStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                    DispatchQueue.main.async {
                        self?.handleAuthorizationResult(status)
                    }
                }
            } else {
                self.handleAuthorizationResult(self.authorizationStatus)
            }
        }
    }

    private func handleAuthorizationResult(_ status: PHAuthorizationStatus) {
        authorizationStatus = status
        debugInfo = "權限結果: \(status.description)"

        switch status {
        case .authorized:
            hasPermission = true
            debugInfo = "✅ 獲得完整權限"
            loadUserPhotos()

        case .limited:
            hasPermission = true
            debugInfo = "⚠️ 獲得有限權限"
            loadUserPhotos()

        case .denied:
            hasPermission = false
            debugInfo = "❌ 權限被拒絕"
            errorMessage = "請到設置中開啟相簿權限"

        case .restricted:
            hasPermission = false
            debugInfo = "🚫 權限受限制"
            errorMessage = "相簿權限被系統限制"

        case .notDetermined:
            hasPermission = false
            debugInfo = "❓ 權限未確定"

        @unknown default:
            hasPermission = false
            debugInfo = "⚠️ 未知權限狀態"
        }

        print("📷 權限處理結果: \(debugInfo)")
    }

    func loadUserPhotos() {
        guard hasPermission else {
            print("❌ 沒有權限，無法載入照片")
            debugInfo = "沒有權限"
            return
        }

        guard !isLoadingPhotos else {
            print("⏳ 正在載入中")
            return
        }

        print("🚀 開始載入照片...")
        isLoadingPhotos = true
        debugInfo = "載入中..."
        errorMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.performSafePhotoLoad()
        }
    }

    private func performSafePhotoLoad() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 10

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        print("📷 找到 \(assets.count) 張照片")

        DispatchQueue.main.async { [weak self] in
            self?.debugInfo = "找到 \(assets.count) 張照片"
        }

        guard assets.count > 0 else {
            DispatchQueue.main.async { [weak self] in
                self?.debugInfo = "相簿中沒有照片"
                self?.errorMessage = "相簿中沒有找到照片"
                self?.isLoadingPhotos = false
            }
            return
        }

        loadPhotosAsync(from: assets)
    }

    private func loadPhotosAsync(from assets: PHFetchResult<PHAsset>) {
        var loadedPhotos: [CGImage] = []
        let dispatchGroup = DispatchGroup()
        let imageManager = PHImageManager.default()

        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .opportunistic
        requestOptions.resizeMode = .fast
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = false

        let maxPhotos = min(5, assets.count)

        for i in 0..<maxPhotos {
            dispatchGroup.enter()
            let asset = assets.object(at: i)

            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 200, height: 200),
                contentMode: .aspectFill,
                options: requestOptions
            ) { [weak self] image, info in
                defer { dispatchGroup.leave() }

                if let error = info?[PHImageErrorKey] as? Error {
                    print("載入照片 \(i) 錯誤: \(error.localizedDescription)")
                    return
                }

                if let isCancelled = info?[PHImageCancelledKey] as? Bool, isCancelled {
                    print("照片 \(i) 載入被取消")
                    return
                }

                if let image = image, let cgImage = image.cgImage {
                    loadedPhotos.append(cgImage)
                    print("✅ 成功載入照片 \(loadedPhotos.count)")

                    DispatchQueue.main.async {
                        self?.debugInfo = "已載入 \(loadedPhotos.count) 張"
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.userPhotos = loadedPhotos
            self?.loadedPhotoCount = loadedPhotos.count
            self?.isLoadingPhotos = false
            self?.debugInfo = "完成！載入 \(loadedPhotos.count) 張照片"

            print("🎉 照片載入完成，總共 \(loadedPhotos.count) 張")

            if loadedPhotos.isEmpty {
                self?.errorMessage = "無法載入任何照片"
            }
        }
    }

    func retryLoadPhotos() {
        errorMessage = nil
        debugInfo = "重試中..."
        loadUserPhotos()
    }
}
