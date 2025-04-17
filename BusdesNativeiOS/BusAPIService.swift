//
//  BusAPIServiceProtocol.swift
//  BusdesNativeiOS
//
//  Created by 黒川龍之介 on 2025/04/18.
//


// プロトコル定義
protocol BusAPIServiceProtocol {
    func fetchNextBus(from: String, to: String) async throws -> ApproachInfo
    func fetchTimeTable(from: String, to: String) async throws -> TimeTable
}

// 実装クラス
class BusAPIService: BusAPIServiceProtocol {
    private let baseURLString = Constants.API.baseURL // Constantsから取得
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func fetchNextBus(from: String, to: String) async throws -> ApproachInfo {
        guard let url = Constants.API.nextBusURL(from: from, to: to) else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }

    func fetchTimeTable(from: String, to: String) async throws -> TimeTable {
        guard let url = Constants.API.timeTableURL(from: from, to: to) else {
             throw NetworkError.invalidURL
         }
        return try await performRequest(url: url)
    }

    // 共通リクエスト処理
    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            // dataが空の場合のチェックが必要ならここに追加
            return try decoder.decode(T.self, from: data)
        } catch let error as NetworkError {
            throw error // 既にNetworkErrorならそのままスロー
        } catch let urlError as URLError {
             throw NetworkError.networkError(urlError) // URLErrorをラップ
        } catch {
            throw NetworkError.decodingError(error) // デコードエラーなどをラップ
        }
    }
}