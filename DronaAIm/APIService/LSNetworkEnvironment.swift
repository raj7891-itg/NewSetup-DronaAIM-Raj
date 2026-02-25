//
//  LSNetworkEnvironment.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/22/24.
//

import Foundation
enum LSNetworkEnvironment {
    case development(api: API)
    case staging(api: API)
    case preProd(api: API)
    case production(api: API)
    
    enum API {
        case lonestar
        case analytics
        case alias
    }
    
    enum Environment {
        case development
        case staging
        case preProd
        case production
    }
    
    var api: API {
        switch self {
        case .development(let api), .staging(let api), .preProd(let api), .production(let api):
            return api
        }
    }
    
    func baseURL(for api: API) -> String {
        switch (api, self) {
        case (.lonestar, .development):
            return "https://dev.api.core.lonestartelematics.online/v1/"
        case (.lonestar, .staging):
            return "https://qa.api.core.lonestartelematics.online/v1/"
        case (.lonestar, .preProd):
            return "https://pre-prod.api.core.dronaaim.ai/v1/"
        case (.lonestar, .production):
            return "https://api.core.dronaaim.ai/v1/"
        case (.analytics, .development):
            return "https://uy4e3jywp9.execute-api.us-east-1.amazonaws.com/"
        case (.analytics, .staging):
            return "https://g403ii3hke.execute-api.us-east-1.amazonaws.com/"
        case (.analytics, .preProd):
            return "https://vow17r597d.execute-api.us-east-1.amazonaws.com/"
        case (.analytics, .production):
            //return "https://api.analytics.dronaaim.ai/"
            return "http://54.80.204.44:3000/"
        case (.alias, .development):
            return "https://dev.alias.lonestartelematics.online/v1/alias"
        case (.alias, .staging):
            return "https://qa.alias.lonestartelematics.online/v1/alias"
        case (.alias, .preProd):
            return "https://pre-prod.alias.lonestartelematics.online/v1/alias"
        case (.alias, .production):
            return "https://alias.dronaaim.ai/v1/alias"
        }
    }
    
}

