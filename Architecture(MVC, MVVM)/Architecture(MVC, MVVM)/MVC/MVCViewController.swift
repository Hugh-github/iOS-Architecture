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
    private let itemStore = ItemStore()
    
    
    // MARK: Network & Parsing Code
    private let apiService = ItemAPIService()
    
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configureSnapshot),
            name: Notification.Name("ItemStore"),
            object: nil
        )
        setNavigation()
    }
}

extension MVCViewController {
    @objc private func configureSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(itemStore.getItemList(), toSection: .list)

        self.dataSource.apply(snapshot)
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
    
    func configureAlert(_ message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: "OK",
            style: .destructive
        )
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: false)
    }
}

extension MVCViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.itemStore.deleteItem(indexPath.row)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension MVCViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.lowercased() else { return }
        
        Task {
            do {
                guard let list = try await apiService.getItemList(query: .init(itemName: text)) else { return }
                
                list.forEach { item in
                    self.itemStore.appendItem(item)
                }
            } catch (let error){
                guard let error = error as? NetworkingError else { return }
                
                configureAlert(error.description)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.itemStore.deleteAllItem()
    }
}
