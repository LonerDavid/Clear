
// MARK: - 修正的 ChatGPT 錯誤處理
import Foundation

enum ChatGPTError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidAPIKey
    case httpError(Int)
    case parsingError
    case networkError
    case rateLimitExceeded
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "API URL 無效"
        case .invalidResponse:
            return "API 回應格式錯誤"
        case .invalidAPIKey:
            return "API Key 無效或已過期，請檢查你的 OpenAI API Key"
        case .httpError(let code):
            switch code {
            case 401:
                return "API Key 無效 (401)"
            case 429:
                return "API 使用量超過限制 (429)"
            case 500...599:
                return "OpenAI 服務器錯誤 (\(code))"
            default:
                return "HTTP 錯誤: \(code)"
            }
        case .parsingError:
            return "回應解析失敗"
        case .networkError:
            return "網路連線問題，請檢查網路設定"
        case .rateLimitExceeded:
            return "API 使用量超過限制，請稍後再試"
        case .noAPIKey:
            return "未設置 API Key"
        }
    }
}
