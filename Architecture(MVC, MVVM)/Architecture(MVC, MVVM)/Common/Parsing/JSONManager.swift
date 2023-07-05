//
//  JSONManager.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/07/05.
//

import Foundation

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
