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
        return items
    }
}
