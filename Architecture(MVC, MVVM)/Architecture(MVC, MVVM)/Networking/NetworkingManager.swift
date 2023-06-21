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

protocol APIService {
    var urlSession: URLSessionProtocol { get }
    
    func execute(endPoint: EndPoint) async throws -> Data
}

extension URLSession: URLSessionProtocol { }

class MockURLSession: URLSessionProtocol {
    var statusCode: Int
    let endPoint: EndPoint
    let count: Int
    
    init(
        statusCode: Int,
        endPoint: EndPoint,
        count: Int
    ) {
        self.statusCode = statusCode
        self.endPoint = endPoint
        self.count = count
    }
    
    func data(for: URLRequest) async throws -> (Data, URLResponse) {
        let httpURLResponse = HTTPURLResponse(
            url: (endPoint.getRequest()?.url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )! as URLResponse
        
        return (Data(count: count), httpURLResponse)
    }
}

class NetworkingManager: APIService {
    static let shared = NetworkingManager(urlSession: URLSession.shared)
    
    let urlSession: URLSessionProtocol
    
    init(
        urlSession: URLSessionProtocol
    ) {
        self.urlSession = urlSession
    }
    
//    var urlSession: URLSessionProtocol {
//        return URLSession.shared
//    }
    
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
}
