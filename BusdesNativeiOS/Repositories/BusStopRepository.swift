import Foundation

/// バス停データを管理するシンプルなリポジトリ
/// ローカルJSONファイルからバス停一覧を読み込む
///
/// ## Swift 6並行処理対応
/// `@preconcurrency`により、nonisolatedコンテキストからsharedへのアクセスを許可
@preconcurrency @MainActor
final class BusStopRepository {

    // シングルトンインスタンス（オプション: アプリ全体で1つのインスタンスを共有）
    static let shared = BusStopRepository()

    // 外部からのインスタンス化も可能（テスト用）
    init() {}

    /// バス停一覧を取得
    /// - Returns: バス停の配列
    /// - Throws: ファイル読み込みまたはデコードエラー
    func getBusStops() throws -> [BusStop] {
        // bus_stops.jsonファイルを読み込み
        guard let url = Bundle.main.url(forResource: "bus_stops", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw RepositoryError.fileNotFound("bus_stops.json")
        }

        do {
            return try JSONDecoder().decode([BusStop].self, from: data)
        } catch {
            throw RepositoryError.decodingFailed(error)
        }
    }

    // MARK: - Error Handling

    enum RepositoryError: Error, LocalizedError {
        case fileNotFound(String)
        case decodingFailed(Error)

        var errorDescription: String? {
            switch self {
            case .fileNotFound(let fileName):
                return "ファイル '\(fileName)' が見つかりませんでした"
            case .decodingFailed(let error):
                return "データの読み込みに失敗しました: \(error.localizedDescription)"
            }
        }
    }
}
