//
//  ItemCell.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/23.
//

import UIKit

class ItemCell: UITableViewCell {
    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        adjustCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Set Cell Content

extension ItemCell {
    func setContent(text name: String, _ price: String, image: UIImage) {
        self.itemImageView.image = image
        self.nameLabel.text = name
        self.priceLabel.text = price
    }
}

// MARK: Adjust Layout

private extension ItemCell {
    func adjustCell() {
        addView()
        setLayout()
    }
    
    func addView() {
        addSubview(self.itemImageView)
        addSubview(self.descriptionStackView)
        
        self.descriptionStackView.addArrangedSubview(self.nameLabel)
        self.descriptionStackView.addArrangedSubview(self.priceLabel)
    }
    
    // 높이는 이미지가 들어가면 imageView 고유 사이즈가 정해지기 때문에 따로 설정하지 않음
    func setLayout() {
        NSLayoutConstraint.activate([
            self.itemImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 5),
            self.itemImageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5),
            self.itemImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4)
        ])
        
        NSLayoutConstraint.activate([
            self.descriptionStackView.leadingAnchor.constraint(equalTo: self.itemImageView.trailingAnchor, constant: 10),
            self.descriptionStackView.centerYAnchor.constraint(equalTo: self.itemImageView.centerYAnchor)
        ])
    }
}
