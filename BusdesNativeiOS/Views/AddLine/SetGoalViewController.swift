import SwiftUI
import UIKit

class SetGoalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = SetGoalView()
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)
    }

}
