import SnapKit
import SwiftUI
import UIKit

class AddLineViewController: UIViewController {
    let searchBar = UISearchBar()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(R.reuseIdentifier.addLineTableViewCell)
        return tableView
    }()
    var searchQuery: String = ""
    var busStops = BusStopModel.dataList
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setUpUI()
    }
}

extension AddLineViewController: UISearchBarDelegate {

}
extension AddLineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AddLineTableViewCell.height
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(SetGoalViewController(), animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AddLineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BusStopModel.dataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.addLineTableViewCell, for: indexPath)
        guard let cell = cell else { fatalError("Invalid TableViewCell") }
        let kana = busStops[indexPath.row].kana
        let name = busStops[indexPath.row].name
        cell.configureCell(.init(busStopName: name, busStopKana: kana))
        return cell
    }
}

extension AddLineViewController {
    private func setUpUI() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.width.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        navigationItem.title = "My路線の追加"
    }
}
