import Foundation

/// アプリケーション全体で使用する統一エラー型
/// - Note: NetworkErrorやRepositoryErrorをラップし、一貫したエラーハンドリングを提供
enum AppError: Error, LocalizedError {
    // MARK: - Network Errors
    case networkUnavailable
    case invalidResponse(statusCode: Int)
    case dataNotFound

    // MARK: - Data Errors
    case invalidData
    case decodingFailed(Error)

    // MARK: - Business Logic Errors
    case busStopNotFound
    case routeAlreadyExists
    case sameOriginAndDestination

    // MARK: - General Errors
    case unknown(Error)

    // MARK: - Error Description

    var errorDescription: String? {
        switch self {
        // Network
        case .networkUnavailable:
            return "インターネット接続がありません。接続を確認してください。"
        case .invalidResponse(let statusCode):
            return "サーバーから予期しない応答がありました。(コード: \(statusCode))"
        case .dataNotFound:
            return "サーバーからデータを受信できませんでした。"

        // Data
        case .invalidData:
            return "データの形式が正しくありません。"
        case .decodingFailed:
            return "データの解析に失敗しました。"

        // Business Logic
        case .busStopNotFound:
            return "指定されたバス停が見つかりません。"
        case .routeAlreadyExists:
            return "この路線は既に追加されています。"
        case .sameOriginAndDestination:
            return "乗り場と降り場が同じです。"

        // General
        case .unknown(let error):
            return "予期しないエラーが発生しました: \(error.localizedDescription)"
        }
    }

    // MARK: - Display Message

    /// ユーザーに表示する詳細メッセージ
    var displayMessage: String {
        switch self {
        case .networkUnavailable:
            return "オフラインのようです。\n接続を確認してください。"
        case .invalidResponse, .dataNotFound, .decodingFailed, .invalidData:
            return "データの取得に失敗しました。\n時間をおいて再試行してください。"
        case .busStopNotFound:
            return "バス停が見つかりません。\n別のバス停を選択してください。"
        case .routeAlreadyExists:
            return "この路線は既に登録済みです。"
        case .sameOriginAndDestination:
            return "乗り場と降り場が同じです。\n別の降り場を選択してください。"
        case .unknown:
            return "予期せぬエラーが発生しました。\nアプリを再起動してみてください。"
        }
    }

    // MARK: - Retry Policy

    /// リトライ可能なエラーかどうか
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .invalidResponse, .dataNotFound, .unknown:
            return true
        case .invalidData, .decodingFailed, .busStopNotFound, .routeAlreadyExists, .sameOriginAndDestination:
            return false
        }
    }

    // MARK: - Conversion

    /// NetworkErrorからAppErrorへ変換
    /// - Parameter networkError: NetworkError
    /// - Returns: 対応するAppError
    static func from(networkError: NetworkError) -> AppError {
        switch networkError {
        case .invalidURL:
            return .invalidData
        case .networkError(let error):
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                return .networkUnavailable
            }
            return .unknown(error)
        case .invalidResponse(let statusCode):
            return .invalidResponse(statusCode: statusCode)
        case .noData:
            return .dataNotFound
        case .decodingError(let error):
            return .decodingFailed(error)
        case .encodingError:
            return .invalidData
        case .unknownError(let error):
            return .unknown(error)
        }
    }
}
