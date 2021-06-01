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
    
    func getStories() -> Single<SplashbaseResponse>
    
    func getMedia(urlString: String) -> Single<Media>
    
}

class RemoteRepository: Repository {
    
    let splashTarget = MoyaProvider<SplashbaseTarget>()
    let splashAWSTarget = MoyaProvider<SplashbaseAWSTarget>()
        
    func getStories() -> Single<SplashbaseResponse> {
        splashTarget.rx
            .request(.getStories)
            .map(SplashbaseResponse.self)
    }
    
    func getMedia(urlString: String) -> Single<Media> {
        return Single<Media>.create { [weak self] single in
            let disposable = self?.splashAWSTarget
                .request(.getMedia(urlString: urlString)) { result in
                switch result {
                case .success(let response):
                    single(.success(Media(id: urlString.md5,
                                          data: response.data)))
                case .failure(let error):
                    single(.error(error))
                }
            }
            
            return Disposables.create {
                disposable?.cancel()
            }
        }
    }
    
}
