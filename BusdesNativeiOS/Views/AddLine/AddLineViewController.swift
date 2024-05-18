import SnapKit
import SwiftUI
import UIKit

class AddLineViewController: UIViewController {
    let searchBar = UISearchBar()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(R.nib.addLineTableViewCell)
        return tableView
    }()
    var searchQuery: String = ""
    var busStops = BusStopModel.dataList
    var filteredData = [BusStopModel]()
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
        filteredData = busStops
        setUpUI()
    }
}

extension AddLineViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = busStops
        } else {
            filteredData = busStops.filter {
                $0.name.contains(searchText) || $0.kana.contains(searchText)
            }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
}
extension AddLineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AddLineTableViewCell.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(SetGoalViewController(), animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AddLineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.addLineTableViewCell, for: indexPath)
        guard let cell = cell else { fatalError("Invalid TableViewCell") }
        let kana = filteredData[indexPath.row].kana
        let name = filteredData[indexPath.row].name
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        navigationItem.title = "My路線の追加"
        navigationController?.navigationBar.backgroundColor = .systemBackground
        tabBarController?.tabBar.backgroundColor = .systemBackground
    }
}
