import Foundation
import Observation

/// 時刻表画面のViewModel
/// @Observableパターンで状態管理を簡素化
@MainActor
@Observable
final class TimeTableViewModel {

    // MARK: - State

    /// 画面の状態を1つの構造体で管理
    struct State {
        var timeTableFromRits: TimeList?
        var timeTableToRits: TimeList?
        var errorMessage: NetworkError?
        var isLoading: Bool = false
    }

    var state = State()

    // MARK: - Public Methods

    /// 時刻表データを取得
    func fetchTimeTable() async {
        state.isLoading = true
        state.errorMessage = nil

        do {
            async let fromRitsData = fetchTimeTableData(fr: "立命館大学", to: "南草津駅")
            async let toRitsData = fetchTimeTableData(fr: "南草津駅", to: "立命館大学")

            let results = try await (fromRits: fromRitsData, toRits: toRitsData)

            state.timeTableFromRits = results.fromRits.weekdays
            state.timeTableToRits = results.toRits.weekdays
            // state.timeTableFromRits = results.fromRits // 全曜日データを使う場合
            // state.timeTableToRits = results.toRits

        } catch let error as NetworkError {
            state.errorMessage = error
        } catch {
            state.errorMessage = .networkError(error)
        }

        state.isLoading = false
    }

    // MARK: - Private Methods

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
