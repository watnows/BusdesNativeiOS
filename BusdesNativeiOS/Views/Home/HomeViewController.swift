import SwiftUI
import UIKit

protocol HomeViewControllerProtocol: AnyObject {
    func goMenu()
}

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = HomeView(controller: self)
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(goMenu))
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    @objc func goMenu() {
        self.navigationController?.pushViewController(MenuViewController(), animated: true)
    }
}
