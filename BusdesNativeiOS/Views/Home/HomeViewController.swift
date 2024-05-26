import SwiftUI
import UIKit

protocol HomeViewControllerProtocol: AnyObject {
    func goMenu()
    func goAddLine()
    func fetchNextBus(fr: String, to: String, completion: @escaping (Result<ApproachInfo, any Error>) -> Void)
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

    func fetchNextBus(fr: String, to: String, completion: @escaping (Result<ApproachInfo, any Error>) -> Void)  {
        let urlString = "https://busdesrits.com/bus/time/v3?fr=\(fr)&to=\(to)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let approachInfo = try decoder.decode(ApproachInfo.self, from: data)
                completion(.success(approachInfo))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
