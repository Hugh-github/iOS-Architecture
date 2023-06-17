//
//  MVCViewController.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/16.
//

import UIKit

class MVCViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "MVC"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "MVC"
        view.backgroundColor = .systemBackground
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            self.titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
    }
}
