//
//  StubAPIService.swift
//  StubViewModelTest
//
//  Created by dhoney96 on 2023/07/06.
//

import Foundation

class StubItemAPIService: APIService {
    private let items: [Item]
    var networkManager: NetworkManager
    
    init(
        items: [Item],
        networkManager: NetworkManager = NetworkManager.shared
    ) {
        self.items = items
        self.networkManager = networkManager
    }
    
    func getItemList(query: RequestQuery) async throws -> [Item]? {
        return [
            Item(title: "아이폰 11", lprice: "1500"),
            Item(title: "아이폰 12", lprice: "1600"),
            Item(title: "아이폰 13", lprice: "1700"),
            Item(title: "아이폰 14", lprice: "1800"),
            Item(title: "아이폰 15", lprice: "1900")
        ]
    }
}
