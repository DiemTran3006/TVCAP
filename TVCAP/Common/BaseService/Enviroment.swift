//
//  Enviroment.swift
//  Probit
//
//  Created by Thân Văn Thanh on 21/11/2022.
//

import Foundation

enum Enviroment {
    case staging
    case production
}

extension Enviroment {
    
    var baseURL: String {
        switch self {
        case .staging:
            return "http://14.225.7.221:7979/"
        case .production:
            return "http://14.225.7.221:7979/"
        }
    }
    
    var imgAPIURL: String {
        switch self {
        case .staging:
            return "https://api.imgbb.com/"
        case .production:
            return "https://api.imgbb.com/"
        }
    }
    
    var demoApi: String {
        "https://raw.githubusercontent.com/DiemTran3006/Api/main/json.geojson"
    }
}
