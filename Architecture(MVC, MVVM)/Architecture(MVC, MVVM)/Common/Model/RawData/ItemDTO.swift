//
//  ItemDTO.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/20.
//

import Foundation

struct ItemListDTO: Decodable {
    let items: [ItemDTO]
    
    func toDomain() -> [Item] {
        return self.items.map { item in
            Item(title: item.title, lprice: item.lprice)
        }
    }
}

struct ItemDTO: Decodable {
    let title: String
    let image: String
    let lprice: String // 최저가 정보, 정보가 없으면 ""
    let hprice: String // 최고가 정보, 정보가 없으면 ""
}
