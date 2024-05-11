import SwiftUI
import UIKit

class AddLineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = AddLineView()
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)
    }
}
