//
//  ItemViewModel.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/30.
//

import Foundation

final class ItemViewModel {
    // Event
    enum Action {
        case searchItem(String)
        case deleteItem(Int)
        case cancelSearch
    }
    
    // Network Code Or Parsing Code
    let networkManager = NetworkingManager.shared
    let jsonManager = JSONManager.shared
    
    
    // Model
    private var itemList: [Item] = [] {
        didSet {
            self.dataBinding(self.itemList)
        }
    }
    
    var dataBinding: (([Item]) -> ()) = { _ in }
    
    func execute(action: Action) {
        switch action {
        case .searchItem(let name):
            do {
                try fetchData(name)
            } catch {
                // 에러에 따른 현재 상태를 표현
            }
        case .deleteItem(let index):
            delete(index)
        case .cancelSearch:
            remove()
        }
    }
}

private extension ItemViewModel {
    func fetchData(_ name: String) throws {
        let endPoint = EndPoint(
            base: .naverSearch,
            query: .init(itemName: name),
            method: .get,
            header: .init()
        )
        
        Task {
            let data = try await networkManager.execute(endPoint: endPoint)
            let itemList: ItemListDTO = try jsonManager.decodeData(data)
            self.itemList = itemList.toDomain()
        }
    }
    
    func delete(_ index: Int) {
        self.itemList.remove(at: index)
    }
    
    func remove() {
        self.itemList.removeAll()
    }
}


