import Combine
import Foundation

class HomeViewModel: ObservableObject {
    @Published var bus: ApproachInfo
    @Published var errorMessage: String?
    @Published var myRouteList: [MyRoute]

    init(bus: ApproachInfo, myRouteList: [MyRoute], errorMessage: String? = nil) {
        self.bus = bus
        self.myRouteList = myRouteList
        self.errorMessage = errorMessage
    }
    func parseTime(time: String, requiredTime: Int) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        if let date = dateFormatter.date(from: time) {
            let calendar = Calendar.current
            if let newDate = calendar.date(byAdding: .minute, value: requiredTime, to: date) {
                return dateFormatter.string(from: newDate)
            }
        }
        return ""
    }

    func fetchTimeTable(fr: String, to: String) {
        errorMessage = nil

        fetchNextBus(fr: fr, to: to) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let approachInfo):
                    self?.bus = approachInfo
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchNextBus(fr: String, to: String, completion: @escaping (Result<ApproachInfo, any Error>) -> Void) {
        let urlString = "https://busdesrits.com/bus/time/v3?fr=\(fr)&to=\(to)"
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
                let approachInfo = try decoder.decode(ApproachInfo.self, from: data)
                completion(.success(approachInfo))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
