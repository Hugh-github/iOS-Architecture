//
//  ItemAPIService.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/07/06.
//

import Foundation

protocol APIService {
    var networkManager: NetworkManager { get }
    
    func getItemList(query: RequestQuery) async throws -> [Item]?
}

class ItemAPIService: APIService {
    var networkManager: NetworkManager
    private let jsonManager = JSONManager.shared
    
    init(
        networkManager: NetworkManager = NetworkManager.shared
    ) {
        self.networkManager = networkManager
    }
    
    func getItemList(query: RequestQuery) async throws -> [Item]? {
        let endPoint = EndPoint(
            base: .naverSearch,
            query: query,
            method: .get,
            header: .init()
        )
        
        let data = try await networkManager.execute(endPoint: endPoint)
        let modelDTO: ItemListDTO = try jsonManager.decodeData(data)
            
        return modelDTO.toDomain()
    }
}
