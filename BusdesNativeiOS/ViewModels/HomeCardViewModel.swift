import Combine
import Foundation

class HomeCardViewModel: ObservableObject {
    @Published var bus: ApproachInfo
    @Published var myRoute: MyRoute
    @Published var errorMessage: String?
    private var controller: HomeViewControllerProtocol

    init(bus: ApproachInfo, myRoute: MyRoute, errorMessage: String? = nil, controller: HomeViewControllerProtocol) {
        self.bus = bus
        self.myRoute = myRoute
        self.errorMessage = errorMessage
        self.controller = controller
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

        controller.fetchNextBus(fr: fr, to: to) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let approachInfo):
                    self?.bus = approachInfo
                    print(approachInfo)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
