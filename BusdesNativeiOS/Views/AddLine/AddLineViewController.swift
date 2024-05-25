import Combine
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
    private var viewModel: AddLineViewModel!
    private var cancellables = Set<AnyCancellable>()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = AddLineViewModel(busStops: BusStopModel.dataList)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        bindViewModel()
        setUpUI()
    }
}

extension AddLineViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchQuery = searchText
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
        return viewModel.filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.addLineTableViewCell, for: indexPath)
        guard let cell = cell else { fatalError("Invalid TableViewCell") }
        let busStop = viewModel.filteredData[indexPath.row]
        let cellViewModel = AddLineCellViewModel(busStopName: busStop.name, busStopKana: busStop.kana)
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension AddLineViewController {
    private func bindViewModel()  {
        viewModel.$searchQuery
            .sink { [weak self] query in
                self?.viewModel.filterBusStops(with: query)
            }
            .store(in: &cancellables)
        viewModel.$filteredData
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

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
    }
}
