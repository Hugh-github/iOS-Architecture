//
//  MockNetworkingTests.swift
//  MockNetworkingTests
//
//  Created by dhoney96 on 2023/06/21.
//

import XCTest

final class MockNetworkingTests: XCTestCase {
    var networkManger: NetworkManager? = nil
    var mockURLSession: MockURLSession? = nil
    var apiService: ItemAPIService? = nil
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        self.mockURLSession = MockURLSession(
            statusCode: 200
        )
        
        self.networkManger = NetworkManager(
            urlSession: mockURLSession!
        )
        
        self.apiService = ItemAPIService(
            networkManager: networkManger!
        )
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        self.mockURLSession = nil
        self.networkManger = nil
        self.apiService = nil
    }
    
    func test_응답이_성공일때_Data가_같은지_확인() async throws {
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        let query = RequestQuery(itemName: "아이폰")
        
        let result = [
            Item(title: "아이폰 11", lprice: "1500"),
            Item(title: "아이폰 12", lprice: "1600"),
            Item(title: "아이폰 13", lprice: "1700"),
            Item(title: "아이폰 14", lprice: "1800"),
            Item(title: "아이폰 15", lprice: "1900")
        ]
        
        let data = try await apiService?.getItemList(query: query)
        expectation.fulfill()
                
        XCTAssertEqual(result, data)
    }
    
    func test_서버에서_응답으로_300번을_보내면_정상적으로_처리하는지_확인() async throws {
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        let query = RequestQuery(itemName: "아이폰")
        
        self.mockURLSession?.statusCode = 300
        self.networkManger = NetworkManager(urlSession: mockURLSession!)
        self.apiService = ItemAPIService(networkManager: networkManger!)
        
        do {
            let _ = try await apiService?.getItemList(query: query)
            expectation.fulfill()
        } catch (let error) {
            XCTAssertEqual(error as! NetworkingError, NetworkingError.clientError)
        }
    }
}
