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
    private let base: String
    private let query: RequestQuery
    private let method: HTTPMethod
    private let header: [HeaderComponents]? // 모든 case에서 header가 반드시 필요한 것은 아니다.
    
    init(
        base: String,
        query: RequestQuery,
        method: HTTPMethod,
        header: [HeaderComponents]? = nil
    ) {
        self.base = base
        self.query = query
        self.method = method
        self.header = header
    }
    
    private var baseURL: URL? {
        return URL(string: base)
    }
    
    // MARK: 세분화 작업 필요(추상화 or 함수 분리)
    func getRequest() -> URLRequest? {
        guard var url = baseURL else { return nil }
        var items = [URLQueryItem]()
        
        // parameter 추가 (query 부분 살짝 고민 해보자)
        self.query.parameter.forEach { (parameter, value) in
            items.append(URLQueryItem(name: parameter, value: value))
        }
        
        url.append(queryItems: items)
        
        // request
        var request = URLRequest(url: url)
        
        // method 추가
        request.httpMethod = self.method.rawValue
        
        // header 추가
        self.header?.forEach({ header in
            switch header {
            case .clientID(let id):
                request.addValue(id, forHTTPHeaderField: "X-Naver-Client-Id")
            case .clientSecret(let secret):
                request.addValue(secret, forHTTPHeaderField: "X-Naver-Client-Secret")
            }
        })
        
        return request
    }
}

struct RequestQuery {
    private let movieName: String
    private let genre: Genre?
    private let country: Country?
    
    var parameter: [String: String?] {
        return ["query": movieName, "genre": genre?.rawValue, "country": country?.rawValue]
    }
}

enum HTTPMethod: String {
    case get = "GET"
}

enum HeaderComponents {
    case clientID(_ id: String)
    case clientSecret(_ secret: String)
}

enum Genre: String {
    case drama = "1"
    case fantasy = "2"
    case horror = "4"
    case romance = "5"
}

enum Country: String {
    case korea = "KR"
    case usa = "US"
    case japan = "JP"
}
