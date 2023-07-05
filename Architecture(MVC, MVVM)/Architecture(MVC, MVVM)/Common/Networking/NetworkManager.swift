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

protocol URLSessionProtocol {
    func data(for: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }

class NetworkManager {
    static let shared = NetworkManager(urlSession: URLSession.shared)
    
    let urlSession: URLSessionProtocol
    
    init(
        urlSession: URLSessionProtocol
    ) {
        self.urlSession = urlSession
    }
    
    func execute(endPoint: EndPoint) async throws -> Data {
        guard let request = endPoint.getRequest() else { throw NetworkingError.badRequest }
        let (data, response) = try await urlSession.data(for: request)
        try handleResponse(response)
        
        return data
    }
    
    private func handleResponse(_ response: URLResponse) throws {
        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkingError.unknownError
        }
        
        let code = urlResponse.statusCode
        
        switch code {
        case 100...199:
            return
        case 200...299:
            return
        case 300...399:
            throw NetworkingError.clientError
        case 400...499:
            throw NetworkingError.serverError
        default:
            throw NetworkingError.systemError
        }
    }
    
}

enum NetworkingError: Error {
    case badRequest
    case unknownError
    case clientError
    case serverError
    case systemError
    
    var description: String {
        switch self {
        case .badRequest:
            return "잘못된 요청"
        case .unknownError:
            return "알 수 없는 에러"
        case .clientError:
            return "클라이언트 에러"
        case .serverError:
            return "서버 에러"
        case .systemError:
            return "시스템 에러"
        }
    }
}

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
