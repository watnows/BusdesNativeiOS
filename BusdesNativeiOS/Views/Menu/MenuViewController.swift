import SwiftUI
import UIKit

protocol MenuViewControllerProtocol: AnyObject {
    func next(url: String)
}

class MenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = MenuView(controller: self)
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)
    }
}

extension MenuViewController: MenuViewControllerProtocol {
    func next(url: String) {
        print(url)
        navigationController?.pushViewController(WebViewController(url: url), animated: true)
    }
}
