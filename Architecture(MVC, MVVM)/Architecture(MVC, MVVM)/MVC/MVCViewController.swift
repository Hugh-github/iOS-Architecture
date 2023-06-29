//
//  MVCViewController.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/16.
//

import UIKit

final class MVCViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: CaseIterable {
        case list
    }
    
    // MARK: View
    private let listView = ItemListView()
    
    // MARK: Model
    private var itemList: [Item] = [] {
        didSet {
            configureSnapshot()
        }
    }
    
    private let jsonManager = JSONManager.shared
    private let networkingManager = NetworkingManager.shared
    
    private lazy var dataSource = DataSource(
        tableView: self.listView.itemListView
    ) { tableView, indexPath, itemIdentifier in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }
        
        let name = itemIdentifier.title
        let price = itemIdentifier.lprice
        
        cell.setContent(text: name, price)
        
        return cell
    }
    
    override func loadView() {
        self.view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.listView.itemListView.delegate = self
        setNavigation()
    }
}

private extension MVCViewController {
    func setNavigation() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "이름을 검색하세요."
        searchController.searchBar.delegate = self
        
        navigationItem.title = "MVC"
        navigationItem.searchController = searchController
    }
    
    func configureSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(itemList, toSection: .list)
        
        self.dataSource.apply(snapshot)
    }
}

extension MVCViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.itemList.remove(at: indexPath.row)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension MVCViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.lowercased() else { return }
        
        let endPoint = EndPoint(
            base: .naverSearch,
            query: .init(itemName: text),
            method: .get,
            header: .init()
        )
        
        Task {
            do {
                let data = try await networkingManager.execute(endPoint: endPoint)
                let itemList: ItemListDTO = try jsonManager.decodeData(data)
                self.itemList = itemList.toDomain()
            } catch {
                
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.itemList.removeAll(keepingCapacity: true)
    }
}
