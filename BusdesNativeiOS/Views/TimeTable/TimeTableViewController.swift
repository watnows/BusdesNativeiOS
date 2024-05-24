import SwiftUI
import UIKit

protocol TimeTableViewControllerProtocol: AnyObject {
    func fetchTimeTable(fr: String, to: String) async throws -> TimeList
    var timeTable: TimeList { get set }
}

class TimeTableViewController: UIViewController {
    var timeTable: TimeList
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(timeTable: TimeList) {
        self.timeTable = timeTable
        super.init(nibName: nil, bundle: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        Task {
            timeTable = try await fetchTimeTable(fr: "立命館大学", to: "南草津駅")
            print("##")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let contentView = TimeTableView(controller: self)
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

    func fetchTimeTable(fr: String, to: String) async throws -> TimeList{
        var urlComponents = URLComponents(string: "https://busdesrits.com/bus/timetable")!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        urlComponents.queryItems = [
            URLQueryItem(name: "fr", value: fr),
            URLQueryItem(name: "to", value: to)
        ]
        let request = URLRequest(url: urlComponents.url!)
        let (data, response) = try await URLSession.shared.data(for: request)
        var decodeData = try? decoder.decode(TimeTable.self, from: data)
        return decodeData?.weekdays ?? TimeList.demo
    }
}
