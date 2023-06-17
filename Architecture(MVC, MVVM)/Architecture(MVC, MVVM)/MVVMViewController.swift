//
//  MVVMViewController.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/16.
//

import UIKit

class MVVMViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "MVVM"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "MVVM"
        view.backgroundColor = .systemBackground
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
    }
}
