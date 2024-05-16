import SwiftUI
import UIKit

protocol SetGoalViewControllerProtocol: AnyObject{
    func goHome()
}

class SetGoalViewController: UIViewController {

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = SetGoalView(controller: self)
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)
    }
}

extension SetGoalViewController: SetGoalViewControllerProtocol {
    func goHome() {
        navigationController?.popToRootViewController(animated: true)
    }
}
