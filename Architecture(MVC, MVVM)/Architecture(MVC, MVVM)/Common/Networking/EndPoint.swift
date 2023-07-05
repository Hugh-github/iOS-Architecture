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
