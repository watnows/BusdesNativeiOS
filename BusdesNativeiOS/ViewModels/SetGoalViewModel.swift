import Combine
import SwiftUI

class SetGoalViewModel: ObservableObject {
    var from: String
    var showAlert = false
    
    init(from: String, showAlert: Bool = false) {
        self.from = from
        self.showAlert = showAlert
    }

    func setRoute(to: String) {
        if from == to {
            showAlert.toggle()
        } else {
            //保存機能書きたい！！
            
        }
        print(from,to)
    }
}
