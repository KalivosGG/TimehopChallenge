//
//  MainViewModelSpec.swift
//  TimehopChallengeTests
//
//  Created by Victor H. Rezende Takai on 05/06/21.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import Swinject
import OrderedCollections

@testable import TimehopChallenge

class MainViewModelSpec: QuickSpec {
    
    override func spec() {
        var sut: MainViewModel!
        
        let container = Container()
        container.register(Repository.self) { r in
            RemoteRepository(targetRepository: r.resolve(TargetRepository.self)!,
                             awsTargetRepository: r.resolve(AWSTargetRepository.self)!)
        }
        container.register(ImageCache.self) { _ in
            ImageCacheMock()
        }
        container.register(MainViewModel.self) { r in
            MainViewModel(repository: r.resolve(Repository.self)!,
                          imageCache: r.resolve(ImageCache.self)!,
                          fileHelper: r.resolve(FileHelper.self)!)
        }
        
        let testScheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()
    
        describe("getStories is invoked") {

            afterEach {
                sut = nil
            }

            context("fetching and downloading succeeds") {
                container.register(FileHelper.self) { _ in
                    FileNotFoundFileHelperMock()
                }
                container.register(TargetRepository.self) { _ in
                    SuccessStoriesRepositoryMock()
                }
                container.register(AWSTargetRepository.self) { _ in
                    SuccessMediaRepositoryMock()
                }

                sut = container.resolve(MainViewModel.self)

                let storiesExpectation = expectation(description: #function)

                let mediaObserver = testScheduler.createObserver(Media?.self)
                let mediaSetObserver = testScheduler.createObserver(OrderedSet<Media>.self)

                sut.isFetching
                    .skip(2)
                    .asObservable()
                    .subscribe(onNext: { isFetching in
                        storiesExpectation.fulfill()
                    })
                    .disposed(by: disposeBag)

                sut.media
                    .subscribe(mediaObserver)
                    .disposed(by: disposeBag)

                sut.mediaSet
                    .subscribe(mediaSetObserver)
                    .disposed(by: disposeBag)

                testScheduler.scheduleAt(0) {
                    sut.getStories()
                }

                testScheduler.start()

                waitForExpectations(timeout: 1) { error in
                    guard error == nil else {
                        it("fails") {
                            fail()
                        }
                        return
                    }

                    it("media emits twice") {
                        let results = mediaObserver.events.compactMap { $0.value.element }
                        expect(results.count).to(equal(2))
                        expect(results[0]).to(beNil())
                        expect(results[1]).to(equal(getStoriesMock().first?.toMedia))
                    }

                    it("mediaSet emits n+1 times") {
                        let results = mediaSetObserver.events.compactMap { $0.value.element }
                        expect(results.count).to(equal(3))
                        expect(results.first).to(equal([]))
                        expect(results[1].count).to(equal(1))
                        expect(results[2].first(where: { $0.id == 8802 })).toNot(beNil())
                    }
                }
            }
            
            context("fetching succeeds but file creation fails for last story") {
                container.register(FileHelper.self) { _ in
                    OnlyFirstFileHelperMock()
                }
                container.register(TargetRepository.self) { _ in
                    SuccessStoriesRepositoryMock()
                }
                container.register(AWSTargetRepository.self) { _ in
                    SuccessMediaRepositoryMock()
                }

                sut = container.resolve(MainViewModel.self)

                let storiesExpectation = expectation(description: #function)

                let mediaObserver = testScheduler.createObserver(Media?.self)
                let mediaSetObserver = testScheduler.createObserver(OrderedSet<Media>.self)

                sut.isFetching
                    .skip(2)
                    .asObservable()
                    .subscribe(onNext: { isFetching in
                        storiesExpectation.fulfill()
                    })
                    .disposed(by: disposeBag)

                sut.media
                    .skip(1)
                    .subscribe(mediaObserver)
                    .disposed(by: disposeBag)

                sut.mediaSet
                    .subscribe(mediaSetObserver)
                    .disposed(by: disposeBag)

                testScheduler.scheduleAt(0) {
                    sut.getStories()
                }

                testScheduler.start()

                waitForExpectations(timeout: 1) { error in
                    guard error == nil else {
                        it("fails") {
                            fail()
                        }
                        return
                    }

                    it("media emits once") {
                        let results = mediaObserver.events.compactMap { $0.value.element }
                        expect(results.count).to(equal(1))
                        expect(results[0]).toNot(beNil())
                    }

                    it("mediaSet contains only succeeded elements") {
                        let results = mediaSetObserver.events.compactMap { $0.value.element }
                        expect(results.count).to(equal(2))
                        expect(results.last?[0]).to(equal(getStoriesMock().first?.toMedia))
                    }
                }
            }

            context("fetching succeeds but download fails for first story") {
                container.register(FileHelper.self) { _ in
                    FileNotFoundFileHelperMock()
                }
                container.register(TargetRepository.self) { _ in
                    SuccessStoriesRepositoryMock()
                }
                container.register(AWSTargetRepository.self) { _ in
                    OnlyLastMediaRepositoryMock()
                }

                sut = container.resolve(MainViewModel.self)

                let storiesExpectation = expectation(description: #function)

                let mediaObserver = testScheduler.createObserver(Media?.self)
                let mediaSetObserver = testScheduler.createObserver(OrderedSet<Media>.self)

                sut.isFetching
                    .skip(2)
                    .asObservable()
                    .subscribe(onNext: { isFetching in
                        storiesExpectation.fulfill()
                    })
                    .disposed(by: disposeBag)

                sut.media
                    .skip(1)
                    .subscribe(mediaObserver)
                    .disposed(by: disposeBag)

                sut.mediaSet
                    .subscribe(mediaSetObserver)
                    .disposed(by: disposeBag)

                testScheduler.scheduleAt(0) {
                    sut.getStories()
                }

                testScheduler.start()

                waitForExpectations(timeout: 1) { error in
                    guard error == nil else {
                        it("fails") {
                            fail()
                        }
                        return
                    }

                    it("media emits once") {
                        let results = mediaObserver.events.compactMap { $0.value.element }
                        expect(results.count).to(equal(1))
                        expect(results[0]).toNot(beNil())
                    }

                    it("mediaSet contains only succeeded elements") {
                        let results = mediaSetObserver.events.compactMap { $0.value.element }
                        expect(results.count).to(equal(2))
                        expect(results.last?[0]).to(equal(getStoriesMock().last?.toMedia))
                    }
                }

            }
            
            context("Fetching fails") {
                container.register(FileHelper.self) { _ in
                    FileNotFoundFileHelperMock()
                }
                container.register(TargetRepository.self) { _ in
                    ErrorStoriesRepositoryMock()
                }
                container.register(AWSTargetRepository.self) { _ in
                    SuccessMediaRepositoryMock()
                }
                
                sut = container.resolve(MainViewModel.self)
                
                let storiesExpectation = expectation(description: #function)

                let mediaObserver = testScheduler.createObserver(Media?.self)
                let mediaSetObserver = testScheduler.createObserver(OrderedSet<Media>.self)

                sut.isFetching
                    .skip(2)
                    .asObservable()
                    .subscribe(onNext: { isFetching in
                        storiesExpectation.fulfill()
                    })
                    .disposed(by: disposeBag)

                sut.media
                    .skip(1)
                    .subscribe(mediaObserver)
                    .disposed(by: disposeBag)
                
                sut.mediaSet
                    .subscribe(mediaSetObserver)
                    .disposed(by: disposeBag)
                
                testScheduler.scheduleAt(0) {
                    sut.getStories()
                }
                
                testScheduler.start()
                
                waitForExpectations(timeout: 1) { error in
                    guard error == nil else {
                        it("fails") {
                            fail()
                        }
                        return
                    }

                    it("media never emits") {
                        let results = mediaObserver.events
                        expect(results.count).to(equal(0))
                    }

                    it("mediaSet emits only default value once") {
                        let results = mediaSetObserver.events.compactMap { $0.value.element }
                        expect(results.count).to(equal(1))
                        expect(results.first).to(equal([]))
                    }
                }
                
            }
            
        }
    
    }
    
}
