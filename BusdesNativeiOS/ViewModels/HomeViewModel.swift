import Combine
import Foundation

class HomeViewModel: ObservableObject {
    private weak var controller: HomeViewControllerProtocol?
    
    init(controller: HomeViewControllerProtocol?) {
            self.controller = controller
        }
        
        func goAddLine() {
            controller?.goAddLine()
        }
}
