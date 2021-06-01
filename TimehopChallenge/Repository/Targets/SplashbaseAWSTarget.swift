//
//  SplashbaseAWSTarget.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 30/05/21.
//

import Foundation
import Moya
import RxSwift

enum SplashbaseAWSTarget {
    case getMedia(urlString: String)
}

extension SplashbaseAWSTarget: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getMedia(let urlString):
            return URL(string: urlString)!
        }
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var validationType: ValidationType {
        return ValidationType.successCodes
    }
    
    var sampleData: Data {
        return Data()
    }
    
}
