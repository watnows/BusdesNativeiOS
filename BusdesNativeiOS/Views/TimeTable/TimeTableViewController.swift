import SwiftUI
import UIKit

protocol TimeTableViewControllerProtocol: AnyObject {
}

class TimeTableViewController: UIViewController {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = TimeTableVIew(controller: self)
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(goMenu))
    }
}

extension TimeTableViewController: TimeTableViewControllerProtocol {
    @objc func goMenu() {
        self.navigationController?.pushViewController(MenuViewController(), animated: true)
    }
}
