import CoreData
import SwiftUI
import UIKit

protocol SetGoalViewControllerProtocol: AnyObject{
    func goHome()
    func setRoute(to: String)
    var from: String { get set }
}

class SetGoalViewController: UIViewController {
    var from = ""

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

    func setRoute(to: String) {
        if from == to {
            let alert = UIAlertController(title: "設定エラー",
                                          message: "乗り場と降り場が同じようです",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            //保存機能書きたい！！
            navigationController?.popToRootViewController(animated: true)
        }
        print(from,to)
    }
}
