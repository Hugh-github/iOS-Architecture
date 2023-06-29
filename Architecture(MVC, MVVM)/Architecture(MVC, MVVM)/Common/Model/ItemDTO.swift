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

struct Item: Hashable {
    let title: String
    let lprice: String
}

class JSONManager {
    static let shared = JSONManager()
    
    private init() { }
    
    private var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    func decodeData<T: Decodable>(_ data: Data) throws -> T {
        do {
            let model = try self.decoder.decode(T.self, from: data)
            return model
        } catch {
            throw JSONError.parsingError
        }
    }
}

enum JSONError: Error {
    case parsingError
}
