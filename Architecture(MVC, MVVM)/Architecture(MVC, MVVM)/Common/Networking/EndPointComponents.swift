//
//  EndPointComponents.swift
//  Architecture(MVC, MVVM)
//
//  Created by dhoney96 on 2023/07/05.
//

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
    let clientSecret = "ugjer6esDS"
//    let clientSecret = "ugjer6esDQ"
}
