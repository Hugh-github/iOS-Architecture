//
//  MovieSearchView.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/17.
//

import UIKit

class ItemSearchView: UIView {
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "영화 이름을 검색하세요."
        searchBar.searchBarStyle = .prominent
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }()
    
    let itemListView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .red
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ItemSearchView {
    func setLayout() {
        addSubview(searchBar)
        addSubview(itemListView)
        
        NSLayoutConstraint.activate([
            self.searchBar.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            self.searchBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9)
        ])
        
        NSLayoutConstraint.activate([
            self.itemListView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 5),
            self.itemListView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            self.itemListView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            self.itemListView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
