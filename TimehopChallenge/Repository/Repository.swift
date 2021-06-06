//
//  SplashbaseRepository.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 30/05/21.
//

import Foundation
import Moya
import RxSwift

protocol TargetRepository {
    func getStories() -> Single<SplashbaseResponse>
}

protocol AWSTargetRepository {
    func getMedia(largeUrlString: String) -> Single<Data>
}

class StoriesRepository: TargetRepository {
    
    let splashTarget = MoyaProvider<SplashbaseTarget>()
    
    func getStories() -> Single<SplashbaseResponse> {
        splashTarget.rx
            .request(.getStories)
            .map(SplashbaseResponse.self)
    }
    
}

class MediaRepository: AWSTargetRepository {
    
    let splashAWSTarget = MoyaProvider<SplashbaseAWSTarget>()
    
    func getMedia(largeUrlString: String) -> Single<Data> {
        return Single<Data>.create { [weak self] single in
            let disposable = self?.splashAWSTarget
                .request(.getMedia(urlString: largeUrlString)) { result in
                switch result {
                case .success(let response):
                    single(.success(response.data))
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

protocol Repository: TargetRepository, AWSTargetRepository {
    init(targetRepository: TargetRepository,
         awsTargetRepository: AWSTargetRepository)
}

class RemoteRepository: Repository {
    
    let targetRepository: TargetRepository
    let awsTargetRepository: AWSTargetRepository
    
    required init(targetRepository: TargetRepository,
         awsTargetRepository: AWSTargetRepository) {
        self.targetRepository = targetRepository
        self.awsTargetRepository = awsTargetRepository
    }
    
    func getStories() -> Single<SplashbaseResponse> {
        return targetRepository.getStories()
    }
    
    func getMedia(largeUrlString: String) -> Single<Data> {
        return awsTargetRepository.getMedia(largeUrlString: largeUrlString)
    }
    
}
