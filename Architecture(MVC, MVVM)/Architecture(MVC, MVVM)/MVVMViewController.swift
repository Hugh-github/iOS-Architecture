//
//  MVVMViewController.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/16.
//

import UIKit

class MVVMViewController: UIViewController {
    
    private let listView = MovieSearchView()
    
    override func loadView() {
        self.view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "MVVM"
        view.backgroundColor = .systemBackground
    }
}
