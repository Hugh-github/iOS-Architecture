//
//  MVCViewController.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/16.
//

import UIKit

class MVCViewController: UIViewController {
    
    private let listView = ItemSearchView()
    
    override func loadView() {
        self.view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setNavigation()
    }
}

private extension MVCViewController {
    func setNavigation() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "이름을 검색하세요."
        
        navigationItem.title = "MVC"
        navigationItem.searchController = searchController
    }
}
