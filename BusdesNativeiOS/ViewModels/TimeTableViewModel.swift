import Combine
import Foundation

class TimeTableViewModel: ObservableObject {
    @Published var timeTableFromRits: TimeList?
    @Published var timeTableToRits: TimeList?
    @Published var errorMessage: String?

    private var controller: TimeTableViewControllerProtocol

    init(controller: TimeTableViewControllerProtocol) {
        self.controller = controller
    }

    func fetchTimeTable() {
        errorMessage = nil

        controller.fetchTimeTable(fr: "立命館大学", to: "南草津駅") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let timeTable):
                    self?.timeTableFromRits = timeTable.weekdays
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        controller.fetchTimeTable(fr: "南草津駅", to: "立命館大学") { [weak self] result in
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
}
