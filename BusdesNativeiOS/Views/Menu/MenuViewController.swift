import SwiftUI
import UIKit

protocol MenuViewControllerProtocol: AnyObject {
    func next(url: String)
}

class MenuViewController: UIViewController {
    private var viewModel: MenuViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MenuViewModel(controller: self)
        let contentView = MenuView(viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)
        navigationItem.title = "設定"
        self.tabBarController?.tabBar.isHidden = true
    }
}

extension MenuViewController: MenuViewControllerProtocol {
    func next(url: String) {
        navigationController?.pushViewController(WebViewController(url: url), animated: true)
    }
}
