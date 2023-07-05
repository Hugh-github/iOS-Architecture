//
//  MockURLSession.swift
//  MockNetworkingTests
//
//  Created by dhoney96 on 2023/07/05.
//

import Foundation

class MockURLSession: URLSessionProtocol {
    var statusCode: Int
    
    init(
        statusCode: Int
    ) {
        self.statusCode = statusCode
    }
    
    func data(for: URLRequest) async throws -> (Data, URLResponse) {
        guard let url = Bundle.main.url(forResource: "MockItemList", withExtension: "json") else {
            throw NetworkingError.unknownError
        }
        
        let data = try Data(contentsOf: url)
        
        let httpURLResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )! as URLResponse
        
        return (data, httpURLResponse)
    }
}
