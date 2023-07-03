//
//  EndPoint.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/06/19.
//

/*
 EndPoint : URL을 만들기 위한 Components의 모음입니다.
 */

import Foundation

struct EndPoint {
    private let base: BaseURL
    private let query: RequestQuery
    private let method: HTTPMethod
    private let header: EssentailHeader
    
    init(
        base: BaseURL,
        query: RequestQuery,
        method: HTTPMethod,
        header: EssentailHeader
    ) {
        self.base = base
        self.query = query
        self.method = method
        self.header = header
    }
    
    private var baseURL: URL? {
        return URL(string: base.rawValue)
    }
    
    func getRequest() -> URLRequest? {
        guard var url = baseURL else { return nil }
        var items = [URLQueryItem]()
        
        // parameter 추가
        self.query.parameter.forEach { (parameter, value) in
            items.append(URLQueryItem(name: parameter, value: value))
        }
        
        url.append(queryItems: items)
        
        // request
        var request = URLRequest(url: url)
        
        // method 추가
        request.httpMethod = self.method.rawValue
        
        // header 추가
        request.addValue(self.header.clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(self.header.clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        return request
    }
}

enum BaseURL: String {
    case naverSearch = "https://openapi.naver.com/v1/search/shop.json"
}

struct RequestQuery {
    private let itemName: String
    private let sort: Sort?
    
    init(
        itemName: String,
        sort: Sort? = nil
    ) {
        self.itemName = itemName
        self.sort = sort
    }
    
    
    var parameter: [String: String] {
        return createParameterDict()
    }
    
    private func createParameterDict() -> [String: String] {
        var parameter = ["query": itemName]
        
        if let description = sort?.rawValue {
            parameter.updateValue(description, forKey: "sort")
        }
        
        return parameter
    }
}

enum Sort: String {
    case sim
    case date
    case asc
    case dsc
}

enum HTTPMethod: String {
    case get = "GET"
}

struct EssentailHeader {
    let clientID = "1RYp_vWiUKUPApHEhCCI"
//    let clientSecret = "ugjer6esDS"
    
    let clientSecret = "ugjer6esDQ"
}
