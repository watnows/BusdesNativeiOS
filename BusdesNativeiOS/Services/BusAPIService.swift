import Foundation

protocol BusAPIServiceProtocol {
    func fetchNextBus(from: String, to: String) async throws -> ApproachInfo
    func fetchTimeTable(from: String, to: String) async throws -> TimeTable
}

class BusAPIService: BusAPIServiceProtocol {
    private let baseURLString = Constants.API.baseURL
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

    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            return try decoder.decode(T.self, from: data)
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
             throw NetworkError.networkError(urlError)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
