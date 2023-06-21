//
//  ItemDTO.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/20.
//

import Foundation

struct ItemListDTO: Decodable {
    let items: [ItemDTO]
}

struct ItemDTO: Decodable {
    let title: String
    let image: String
    let lprice: String // 최저가 정보, 정보가 없으면 ""
    let hprice: String // 최고가 정보, 정보가 없으면 ""
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
