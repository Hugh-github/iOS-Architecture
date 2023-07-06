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
    
    // Model
    private(set) var itemList = Observable<[Item]>([])
    
    // Network Code Or Parsing Code
    private let apiService: APIService
    
    init(
        apiService: APIService = ItemAPIService()
    ) {
        self.apiService = apiService
    }

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
        Task {
            do {
                guard let list = try await apiService.getItemList(query: .init(itemName: name)) else { return }
                self.itemList.value = list
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


