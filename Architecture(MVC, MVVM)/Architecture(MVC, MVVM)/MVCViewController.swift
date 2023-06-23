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
        
        navigationItem.title = "MVC"
        view.backgroundColor = .systemBackground
    }
}
