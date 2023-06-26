//
//  MovieSearchView.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/17.
//

import UIKit

class ItemSearchView: UIView {
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
        addSubview(itemListView)
        
        NSLayoutConstraint.activate([
            self.itemListView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            self.itemListView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            self.itemListView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            self.itemListView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
