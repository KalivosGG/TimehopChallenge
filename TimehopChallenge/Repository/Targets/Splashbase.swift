//
//  SplashbaseTarget.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 29/05/21.
//

import Foundation
import Moya

enum SplashbaseTarget {
    
    case getStories
    
}

extension SplashbaseTarget: TargetType {
    
    var baseURL: URL {
        return URL(string: "http://www.splashbase.co")!
    }
    
    var path: String {
        return "/api/v1/images/latest"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var validationType: ValidationType {
        return ValidationType.successCodes
    }
    
    var sampleData: Data {
        return Story.fromJSON("splashbase_mock.json")
    }
    
}
