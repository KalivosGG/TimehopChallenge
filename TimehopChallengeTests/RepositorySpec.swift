//
//  RepositorySpec.swift
//  TimehopChallengeTests
//
//  Created by Victor H. Rezende Takai on 05/06/21.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxBlocking
import Swinject

@testable import TimehopChallenge

class RepositorySpec: QuickSpec {
    
    override func spec() {
        let container = Container()

        describe("getStories is invoked") {
                        
            context("fetching succeeds") {
                container.register(TargetRepository.self) { _ in
                    SuccessStoriesRepositoryMock()
                }
                
                let sut = container.resolve(TargetRepository.self)!
                
                let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
                let observable = sut.getStories()
                    .asObservable()
                    .subscribeOn(scheduler)

                it("emits success") {
                    let result = observable.toBlocking().materialize()
                    switch result {
                    case .completed(let elements):
                        expect(elements.first?.images.count).to(equal(2))
                        expect(elements.first?.images).to(equal(getStoriesMock()))
                    case .failed:
                        fail()
                    }
                }
            }
            
            context("fetching fails") {
                container.register(TargetRepository.self) { _ in
                    ErrorStoriesRepositoryMock()
                }
                
                let sut = container.resolve(TargetRepository.self)!
                
                let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
                let observable = sut.getStories()
                    .asObservable()
                    .subscribeOn(scheduler)

                it("emits error") {
                    let result = observable.toBlocking().materialize()
                    switch result {
                    case .completed:
                        fail()
                    case .failed(_, let error):
                        expect(error as? TestError).to(equal(TestError.expected))
                    }
                }
            }
            
        }
        
        describe("getMedia is invoked") {
            
            context("fetching succeeds") {
                container.register(AWSTargetRepository.self) { _ in
                    SuccessMediaRepositoryMock()
                }
                
                let sut = container.resolve(AWSTargetRepository.self)!
                
                let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
                let observable = sut.getMedia(largeUrlString: "")
                    .asObservable()
                    .subscribeOn(scheduler)

                it("emits success") {
                    let result = observable.toBlocking().materialize()
                    switch result {
                    case .completed(let elements):
                        expect(elements.first).to(equal(Data()))
                    case .failed:
                        fail()
                    }
                }
            }
            
            context("fetching fails") {
                container.register(AWSTargetRepository.self) { _ in
                    ErrorMediaRepositoryMock()
                }
                
                let sut = container.resolve(AWSTargetRepository.self)!
                
                let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
                let observable = sut.getMedia(largeUrlString: "")
                    .asObservable()
                    .subscribeOn(scheduler)

                it("emits error") {
                    let result = observable.toBlocking().materialize()
                    switch result {
                    case .completed:
                        fail()
                    case .failed(_, let error):
                        expect(error as? TestError).to(equal(TestError.expected))
                    }
                }
            }
            
        }
        
    }
    
}
