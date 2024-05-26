import SwiftUI
import UIKit

protocol TimeTableViewControllerProtocol: AnyObject {
    func fetchTimeTable(fr: String, to: String, completion: @escaping (Result<TimeTable, Error>) -> Void)
    var timeTable: TimeList { get set }
}

class TimeTableViewController: UIViewController {
    var timeTable = TimeList(five: [], six: [], seven: [], eight: [], nine: [], ten: [], eleven: [], twelve: [], thirteen: [], fourteen: [], fifteen: [], sixteen: [], seventeen: [], eighteen: [], nineteen: [], twenty: [], twentyone: [], twentytwo: [], twentythree: [], twentyfour: [])
    var viewModel: TimeTableViewModel!
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchTimeTable()
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = TimeTableViewModel(controller: self)
        let contentView = TimeTableView(viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: contentView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        hostingVC.coverView(parent: view)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(goMenu))
    }
}

extension TimeTableViewController: TimeTableViewControllerProtocol {
    func fetchTimeTable(fr: String, to: String, completion: @escaping (Result<TimeTable, any Error>) -> Void) {
        let urlString = "https://busdesrits.com/bus/timetable?fr=\(fr)&to=\(to)"
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
                let timeTable = try decoder.decode(TimeTable.self, from: data)
                completion(.success(timeTable))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    @objc func goMenu() {
        self.navigationController?.pushViewController(MenuViewController(), animated: true)
    }
}
