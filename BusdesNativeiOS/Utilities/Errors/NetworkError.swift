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
}
