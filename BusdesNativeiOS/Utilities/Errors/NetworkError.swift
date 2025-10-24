import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです。"
        case .networkError(let error):
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                return "インターネット接続がありません。"
            }
            return "ネットワークエラーが発生しました: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "サーバーから予期しない応答がありました。(コード: \(statusCode))"
        case .noData:
            return "サーバーからデータを受信できませんでした。"
        case .decodingError:
            return "データの解析に失敗しました。"
        case .encodingError:
            return "リクエスト情報の作成に失敗しました。"
        case .unknownError(let error):
            return "不明なエラーが発生しました: \(error.localizedDescription)"
        }
    }

    var displayMessage: String {
        switch self {
        case .networkError(let error):
             if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                 return "オフラインのようです。\n接続を確認してください。"
             }
             return "通信エラーが発生しました。\n時間をおいて再試行してください。"
        case .invalidResponse, .noData, .decodingError:
            return "データの取得に失敗しました。\n時間をおいて再試行してください。"
        case .unknownError:
            return "予期せぬエラーが発生しました。\nアプリを再起動してみてください。"
        default:
            return self.errorDescription ?? "不明なエラーが発生しました。"
        }
    }

    /// このエラーが自動リトライ可能かどうか
    var isRetryable: Bool {
        switch self {
        case .networkError(let error):
            if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut, .cannotFindHost, .cannotConnectToHost, .networkConnectionLost, .dnsLookupFailed:
                    return true
                case .notConnectedToInternet:
                    return false
                default:
                    return true
                }
            }
            return true
        case .invalidResponse(let statusCode):
            // 5xxエラーはサーバー側の一時的な問題の可能性があるためリトライ可能
            return (500...599).contains(statusCode)
        case .invalidURL, .encodingError:
            // クライアント側の設定ミスなのでリトライ不可
            return false
        case .noData, .decodingError, .unknownError:
            // 一時的な問題の可能性があるためリトライ可能
            return true
        }
    }

    /// リトライ待機時間（秒）
    func retryDelay(for attempt: Int) -> TimeInterval {
        // 指数バックオフ: 1秒、2秒、4秒
        return min(pow(2.0, Double(attempt - 1)), 4.0)
    }
}
