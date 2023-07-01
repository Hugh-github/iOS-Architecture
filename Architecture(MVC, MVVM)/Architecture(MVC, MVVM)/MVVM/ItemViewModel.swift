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
    private let networkManager = NetworkingManager.shared
    private let jsonManager = JSONManager.shared
    
    
    // Model
    private var itemList: [Item] = [] {
        didSet {
            self.dataBinding(self.itemList)
        }
    }
    
    var dataBinding: (([Item]) -> ()) = { _ in } // View를 업데이트 하는 데이터 바인딩
    var errorHandling: ((String) -> ()) = { _ in } // 에러 처리
    
    // 좋은 방법인지는 잘 모르겠다.
    func execute(action: Action) {
        switch action {
        case .searchItem(let name):
            do {
                try fetchData(name)
            } catch (let error) {
                guard let error = error as? NetworkingError else { return }
                errorHandling(error.description)
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


