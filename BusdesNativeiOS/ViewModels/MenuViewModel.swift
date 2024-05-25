import Combine
import Foundation

class MenuViewModel: ObservableObject {
    private weak var controller: MenuViewControllerProtocol?

    init(controller: MenuViewControllerProtocol) {
        self.controller = controller
    }

    func goWeb(url: String) {
        controller?.next(url: url)
    }
}
