import Foundation

protocol BusAPIServiceProtocol {
    func fetchNextBus(from: String, to: String) async throws -> ApproachInfo
    func fetchTimeTable(from: String, to: String) async throws -> TimeTable
}

class BusAPIService: BusAPIServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = URLSession(configuration:  .default), decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

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
            print("Response: \(response)")
            print("Data: \(String(data: data, encoding: .utf8) ?? "")")

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
