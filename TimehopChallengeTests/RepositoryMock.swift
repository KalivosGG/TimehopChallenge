//
//  RepositoryMock.swift
//  TimehopChallengeTests
//
//  Created by Victor H. Rezende Takai on 05/06/21.
//

import Foundation
import RxSwift

@testable import TimehopChallenge

enum TestError: Error {
    case expected
}

extension Story {
    
    var toMedia: Media {
        return Media(id: self.id,
                     type: .undefined,
                     url: URL(string: self.largeUrl!.absoluteString.md5)!)
    }
    
}

func getStoriesMock() -> [Story] {
    return [
        Story(id: 788,
              url: URL(string: "https://url.com/788/img.jpg"),
              largeUrl: URL(string: "https://largeurl.com/788/img.jpg"),
              sourceId: nil),
        Story(id: 8802,
              url: URL(string: "https://largeurl.com/8802/img.jpg"),
              largeUrl: URL(string: "https://largeurl.com/8802/video.mp4"),
              sourceId: nil)
    ]
}

class SuccessStoriesRepositoryMock: TargetRepository {
    func getStories() -> Single<SplashbaseResponse> {
        return Single.create { single in
            single(.success(SplashbaseResponse(images: getStoriesMock())))
            return Disposables.create()
        }
    }
}

class ErrorStoriesRepositoryMock: TargetRepository {
    func getStories() -> Single<SplashbaseResponse> {
        return Single.create { single in
            single(.error(TestError.expected))
            return Disposables.create()
        }
    }
}

class SuccessMediaRepositoryMock: AWSTargetRepository {
    func getMedia(largeUrlString: String) -> Single<Data> {
        return Single.create { single in
            single(.success(Data()))
            return Disposables.create()
        }
    }
}

class ErrorMediaRepositoryMock: AWSTargetRepository {
    func getMedia(largeUrlString: String) -> Single<Data> {
        return Single.create { single in
            single(.error(TestError.expected))
            return Disposables.create()
        }
    }
}

class OnlyLastMediaRepositoryMock: AWSTargetRepository {
    func getMedia(largeUrlString: String) -> Single<Data> {
        let lastStoryUrl = getStoriesMock().last?.largeUrl?.absoluteString
        if (largeUrlString == lastStoryUrl) {
            return Single.create { single in
                single(.success(Data()))
                return Disposables.create()
            }
        } else {
            return Single.create { single in
                single(.error(TestError.expected))
                return Disposables.create()
            }
        }
    }
}
