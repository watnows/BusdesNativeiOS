import SwiftUI
import UIKit

protocol HomeViewControllerProtocol: AnyObject {
    func goMenu()
    func goAddLine()
}

class HomeViewController: UIViewController {
    private var viewModel: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HomeViewModel(controller: self)
        let contentView = HomeView(viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(goMenu))
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    @objc func goMenu() {
        self.navigationController?.pushViewController(MenuViewController(), animated: true)
    }
    func goAddLine() {
        self.navigationController?.pushViewController(AddLineViewController(), animated: true)
    }
}
