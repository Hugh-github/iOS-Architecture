//
//  ItemStore.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/08/10.
//

import Foundation

class ItemStore {
    private var store: [Item] = [] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("ItemStore"), object: nil)
        }
    }
    
    func appendItem(_ item: Item) {
        self.store.append(item)
    }
    
    func getItemList() -> [Item] {
        return self.store
    }
    
    func deleteItem(_ index: Int) {
        self.store.remove(at: index)
    }
    
    func deleteAllItem() {
        self.store.removeAll()
    }
}
