//
//  NetworkingManager.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/20.
//

import Foundation

/*
 NetworkingManage : 서버에서 데이터를 받아노는 객체
 */

// Get, Post, Put, Delete
class NetworkingManager {
    static let shared = NetworkingManager()
    
    private init() { }
    
    private var urlSession: URLSession {
        return URLSession.shared
    }
    
    // 서버에 데이터 요청
    func excute(endPoint: EndPoint) async throws -> Data {
        guard let request = endPoint.getRequest() else { throw NetworkingError.badRequest }
        let (data, _) = try await urlSession.data(for: request)
        
        print(data)
        return data
    }
}

enum NetworkingError: Error {
    case badRequest
}
