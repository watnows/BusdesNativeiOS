import Foundation

/// バスAPI通信を担当するサービスのプロトコル
protocol BusAPIServiceProtocol {
    /// 次のバス接近情報を取得
    /// - Parameters:
    ///   - from: 出発地バス停名
    ///   - to: 目的地バス停名
    /// - Returns: バス接近情報
    /// - Throws: `NetworkError` API通信エラー
    func fetchNextBus(from: String, to: String) async throws -> ApproachInfo

    /// バス時刻表を取得
    /// - Parameters:
    ///   - from: 出発地バス停名
    ///   - to: 目的地バス停名
    /// - Returns: バス時刻表
    /// - Throws: `NetworkError` API通信エラー
    func fetchTimeTable(from: String, to: String) async throws -> TimeTable
}

/// バスAPI通信サービスの実装
/// 外部APIと通信し、バス接近情報と時刻表を取得する
/// キャッシング機能により、不要なAPI呼び出しを削減してパフォーマンスを向上
@MainActor
class BusAPIService: BusAPIServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let cacheService = APICacheService.shared

    /// イニシャライザ
    /// - Parameters:
    ///   - session: URLSession（テスト用にカスタマイズ可能）
    ///   - decoder: JSONDecoder（snake_case自動変換設定済み）
    init(session: URLSession = URLSession(configuration:  .default), decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchNextBus(from: String, to: String) async throws -> ApproachInfo {
        // キャッシュ確認
        if let cachedData = cacheService.getApproachInfo(from: from, to: to) {
            return cachedData
        }

        // APIから取得
        guard let url = Constants.API.nextBusURL(from: from, to: to) else {
            throw NetworkError.invalidURL
        }
        let data: ApproachInfo = try await performRequest(url: url)

        // キャッシュに保存
        cacheService.setApproachInfo(data, from: from, to: to)

        return data
    }

    func fetchTimeTable(from: String, to: String) async throws -> TimeTable {
        // キャッシュ確認
        if let cachedData = cacheService.getTimeTable(from: from, to: to) {
            return cachedData
        }

        // APIから取得
        guard let url = Constants.API.timeTableURL(from: from, to: to) else {
             throw NetworkError.invalidURL
         }
        let data: TimeTable = try await performRequest(url: url)

        // キャッシュに保存
        cacheService.setTimeTable(data, from: from, to: to)

        return data
    }

    /// HTTPリクエストを実行し、レスポンスをデコード
    /// - Parameter url: リクエストURL
    /// - Returns: デコードされたレスポンスオブジェクト
    /// - Throws: `NetworkError` 通信・レスポンス・デコードエラー
    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                 throw NetworkError.invalidResponse(statusCode: 0)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
            }

            guard !data.isEmpty else {
                 throw NetworkError.noData
            }

            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {

             throw NetworkError.decodingError(decodingError)
        } catch let urlError as URLError {
             throw NetworkError.networkError(urlError)
        } catch let networkError as NetworkError {
             throw networkError
        } catch {
             throw NetworkError.unknownError(error)
        }
    }
}
