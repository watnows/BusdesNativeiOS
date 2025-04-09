import Combine
import Foundation

class TimeTableViewModel: ObservableObject {
    @Published var timeTableFromRits: TimeList?
    @Published var timeTableToRits: TimeList?
    @Published var errorMessage: String?

    func fetchTimeTable() {
        errorMessage = nil

        fetchTimeTableData(fr: "立命館大学", to: "南草津駅") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let timeTable):
                    self?.timeTableFromRits = timeTable.weekdays
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        fetchTimeTableData(fr: "南草津駅", to: "立命館大学") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let timeTable):
                    self?.timeTableToRits = timeTable.weekdays
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchTimeTableData(fr: String, to: String, completion: @escaping (Result<TimeTable, any Error>) -> Void) {
        let urlString = "https://busdesrits.com/bus/timetable?fr=\(fr)&to=\(to)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let timeTable = try decoder.decode(TimeTable.self, from: data)
                completion(.success(timeTable))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
