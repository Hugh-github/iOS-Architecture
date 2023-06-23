//
//  MovieSearchView.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/17.
//

import UIKit

class ItemSearchView: UIView {
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "영화 이름을 검색하세요."
        searchBar.searchBarStyle = .prominent
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }()
    
    private let itemListView: UITableView = {
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

extension MovieSearchView {
    func setSearchBarDelegate(representative: UISearchBarDelegate) {
        self.searchBar.delegate = representative
    }
}

private extension MovieSearchView {
    func setLayout() {
        addSubview(searchBar)
        addSubview(movieListView)
        
        NSLayoutConstraint.activate([
            searchBar.centerXAnchor.constraint(equalTo: centerXAnchor),
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9)
        ])
        
        NSLayoutConstraint.activate([
            movieListView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 5),
            movieListView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            movieListView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            movieListView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
