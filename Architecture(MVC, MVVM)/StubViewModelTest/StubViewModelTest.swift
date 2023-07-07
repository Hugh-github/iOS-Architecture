//
//  StubViewModelTest.swift
//  StubViewModelTest
//
//  Created by dhoney96 on 2023/07/06.
//

import XCTest

final class StubViewModelTest: XCTestCase {
    var viewModel: ItemViewModel! = nil
    var stubAPIService: APIService! = nil
    
    var data = [
        Item(title: "아이폰 11", lprice: "1500"),
        Item(title: "아이폰 12", lprice: "1600"),
        Item(title: "아이폰 13", lprice: "1700"),
        Item(title: "아이폰 14", lprice: "1800"),
        Item(title: "아이폰 15", lprice: "1900")
    ]
    

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        self.stubAPIService = StubItemAPIService(items: data)
        self.viewModel = ItemViewModel(apiService: stubAPIService)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        self.stubAPIService = nil
        self.viewModel = nil
    }

    func test_검색이_완료되면_원하는_결과를_가져오는지_확인() async {
        let expectation = XCTestExpectation(description: "ViewModelTest")
        viewModel.execute(action: .searchItem("아이폰"))
        expectation.fulfill()
        wait(for: [expectation], timeout: 3.0)
        
        print(viewModel.itemList.value)
        
        XCTAssertEqual(viewModel.itemList.value, data)
    }
    
    func test_Swipe를_액션을_통해_특정_index의_데이터_제거하는지_확인() {
        let expectation = XCTestExpectation(description: "ViewModelTest")
        viewModel.execute(action: .searchItem("아이폰"))
        expectation.fulfill()
        wait(for: [expectation], timeout: 3.0)
        
        viewModel.execute(action: .deleteItem(2))
        self.data.remove(at: 2)
        
        XCTAssertEqual(viewModel.itemList.value, data)
    }
    
    func test_취소버튼_눌렸을때_모든_데이터를_제거하는지_확인() {
        let expectation = XCTestExpectation(description: "ViewModelTest")
        viewModel.execute(action: .searchItem("아이폰"))
        expectation.fulfill()
        wait(for: [expectation], timeout: 3.0)
        
        viewModel.execute(action: .cancelSearch)
        
        XCTAssertTrue(viewModel.itemList.value.isEmpty)
    }
}
