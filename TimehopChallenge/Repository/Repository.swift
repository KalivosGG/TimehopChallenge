//
//  SplashbaseRepository.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 30/05/21.
//

import Foundation
import Moya
import RxSwift

protocol Repository {
    
    func getStories() -> Single<[Story]>
    
}

class RemoteRepository: Repository {
    
    final let provider = MoyaProvider<Splashbase>()
    
    func getStories() -> Single<[Story]> {
        provider.rx.request(.getStories).map([Story].self)
    }
    
}
