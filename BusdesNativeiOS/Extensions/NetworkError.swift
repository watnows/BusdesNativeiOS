// NetworkError.swift
import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL // URLが不正
    case networkError(Error) // 通信自体が失敗 (例: オフライン)
    case invalidResponse(statusCode: Int) // HTTPステータスコードが200番台以外
    case noData // レスポンスボディが空
    case decodingError(Error) // JSONデコードに失敗
    case encodingError // URLエンコードに失敗 (今回はリクエスト時のみ)

    // エラー内容をユーザーに分かりやすく説明するプロパティ (オプション)
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです。"
        case .networkError(let error):
            // ネットワーク接続がない場合のエラーメッセージなどを工夫できる
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                return "インターネット接続がありません。"
            }
            return "ネットワークエラーが発生しました: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "サーバーから予期しない応答がありました。(コード: \(statusCode))"
        case .noData:
            return "サーバーからデータを受信できませんでした。"
        case .decodingError(let error):
            // デバッグ用に詳細なエラーを出すことも可能
             print("Decoding Error Details: \(error)")
            return "データの解析に失敗しました。"
        case .encodingError:
            return "リクエスト情報の作成に失敗しました。"
        }
    }

    // エラーメッセージをViewに表示しやすくするためのプロパティ
    var displayMessage: String {
        // 特定のエラーコード以外は、ユーザーにはシンプルなメッセージを表示するなど工夫できる
        switch self {
        case .networkError(let error):
             if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                 return "オフラインのようです。\n接続を確認してください。"
             }
             return "通信エラーが発生しました。\n時間をおいて再試行してください。"
        case .invalidResponse, .noData, .decodingError:
            return "データの取得に失敗しました。\n時間をおいて再試行してください。"
        default:
            return self.errorDescription ?? "不明なエラーが発生しました。"
        }
    }
}