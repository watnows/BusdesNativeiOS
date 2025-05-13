import Combine
import Foundation

@MainActor
class TimeTableViewModel: ObservableObject {
    @Published var timeTableFromRits: TimeList?
    @Published var timeTableToRits: TimeList?
    @Published var errorMessage: NetworkError?
    @Published var isLoading: Bool = false

    func fetchTimeTable() async {
        isLoading = true
        errorMessage = nil

        do {
            async let fromRitsData = fetchTimeTableData(fr: "立命館大学", to: "南草津駅")
            async let toRitsData = fetchTimeTableData(fr: "南草津駅", to: "立命館大学")

            let results = try await (fromRits: fromRitsData, toRits: toRitsData)

            self.timeTableFromRits = results.fromRits.weekdays
            self.timeTableToRits = results.toRits.weekdays
            // self.timeTableFromRits = results.fromRits // 全曜日データを使う場合
            // self.timeTableToRits = results.toRits

        } catch let error as NetworkError {
            self.errorMessage = error
        } catch {
            self.errorMessage = .networkError(error)
        }

        isLoading = false
    }

    private func fetchTimeTableData(fr: String, to: String) async throws -> TimeTable {
        guard let url = Constants.API.timeTableURL(from: fr, to: to) else {
                throw NetworkError.invalidURL
            }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw NetworkError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw NetworkError.invalidResponse(statusCode: statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let timeTable = try decoder.decode(TimeTable.self, from: data)
            return timeTable
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
