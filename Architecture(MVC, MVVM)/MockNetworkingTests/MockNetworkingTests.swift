//
//  MockNetworkingTests.swift
//  MockNetworkingTests
//
//  Created by dhoney96 on 2023/06/21.
//

import XCTest

final class MockNetworkingTests: XCTestCase {
    var networkManger: NetworkingManager? = nil
    var endPoint: EndPoint? = nil
    var mockURLSession: MockURLSession? = nil
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        self.endPoint = EndPoint(
            base: .naverSearch,
            query: .init(itemName: "아이폰"),
            method: .get,
            header: .init()
        )
        
        self.mockURLSession = MockURLSession(
            statusCode: 200,
            endPoint: endPoint!,
            count: 0
        )
        
        self.networkManger = NetworkingManager(
            urlSession: mockURLSession!
        )
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        self.endPoint = nil
        self.mockURLSession = nil
        self.networkManger = nil
    }
    
    func test_응답이_성공일때_Data의_용량이_같은지_확인() async throws {
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        
        let data = try await networkManger?.execute(endPoint: endPoint!)
        expectation.fulfill()
                
        let result = data?.count // 정상적으로 0이 확인
        XCTAssertEqual(result, 0)
    }
    
    func test_서버에서_응답으로_300번을_보내면_정상적으로_처리하는지_확인() async throws {
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        self.mockURLSession?.statusCode = 300
        self.networkManger = NetworkingManager(urlSession: mockURLSession!)
        
        do {
            let _ = try await networkManger?.execute(endPoint: endPoint!)
            expectation.fulfill()
        } catch(let error) { // error는 정상적으로 찍힘
            XCTAssertEqual(error as! NetworkingError, NetworkingError.clientError)
        }
    }
}
