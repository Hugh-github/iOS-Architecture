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
    private var itemList = Observable<[Item]>([])
    
    var errorHandling: ((String) -> ()) = { _ in } // 에러 처리
    
    func execute(action: Action) {
        switch action {
        case .searchItem(let name):
            fetchData(name)
        case .deleteItem(let index):
            delete(index)
        case .cancelSearch:
            remove()
        }
    }
    
    func subscribe(on object: AnyObject, handling: @escaping ([Item]) -> Void) {
        self.itemList.addObserver(on: object, handling)
    }
    
    func unsubscribe(on object: AnyObject) {
        self.itemList.removeObserver(observer: object)
    }
}

private extension ItemViewModel {
    func fetchData(_ name: String) {
        let endPoint = EndPoint(
            base: .naverSearch,
            query: .init(itemName: name),
            method: .get,
            header: .init()
        )
        
        Task {
            do {
                let data = try await networkManager.execute(endPoint: endPoint)
                let itemList: ItemListDTO = try jsonManager.decodeData(data)
                self.itemList.value = itemList.toDomain()
            } catch let error {
                guard let error = error as? NetworkingError else { return }
                errorHandling(error.description)
            }
        }
    }
    
    func delete(_ index: Int) {
        self.itemList.value.remove(at: index)
    }
    
    func remove() {
        self.itemList.value.removeAll()
    }
}


