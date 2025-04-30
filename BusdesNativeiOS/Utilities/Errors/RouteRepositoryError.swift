import Foundation

enum RouteRepositoryError: Error, LocalizedError {
    case contextUnavailable
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case routeNotFound
    case routeDuplicated

    var errorDescription: String? {
        switch self {
        case .contextUnavailable:
            return "データベースコンテキストにアクセスできませんでした。"
        case .fetchFailed(let error):
            return "路線の読み込みに失敗しました: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "路線の保存に失敗しました: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "路線の削除に失敗しました: \(error.localizedDescription)"
        case .routeNotFound:
            return "指定された路線が見つかりませんでした。"
        case .routeDuplicated:
            return "この路線はすでに登録されています。"
        }
    }
}
