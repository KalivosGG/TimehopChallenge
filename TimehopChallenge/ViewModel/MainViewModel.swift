//
//  MainViewModel.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 30/05/21.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

enum StoryError: Error {
    case invalidUrl
    case fileCreationFailed
}

class MainViewModel {
    
    private let repository: Repository
    private let disposeBag = DisposeBag()
    private(set) var id = BehaviorRelay<String>(value: "")
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func getStories() {
        repository.getStories()
            .retry(3)
            .map { $0.images }
            
            //Map observable of array to array of observables
            .asObservable()
            .flatMap { Observable.from($0) }
            
            //Download data (media)
            .flatMap { self.downloadMedia(story: $0).asObservable().filterErrors() }
            
            //Save data to cache folder
            .flatMap { self.saveMedia(media: $0).asObservable().filterErrors() }
            
            .subscribe(onNext: { id in
                self.id.accept(id)
            })
            .disposed(by: disposeBag)
    }
    
    private func didDownloadMedia(fileName: String) -> Bool {
        let filePath = FileManager.cacheFilePath(fileName)
        return !FileManager.default.fileExists(atPath: filePath)
    }
    
    private func downloadMedia(story: Story) -> Single<Media> {
        guard let largeUrlString = story.largeUrl?.absoluteString else {
            return Single<Media>.error(StoryError.invalidUrl)
        }
        
        if !didDownloadMedia(fileName: largeUrlString.md5) {
            return Single<Media>.create { single in
                single(.success(Media(id: largeUrlString.md5, data: nil)))
                return Disposables.create()
            }
        }
        
        return repository.getMedia(largeUrlString: largeUrlString).retry(3)
    }
    
    private func saveMedia(media: Media) -> Single<String> {
        return Single<String>.create { single in
            if let data = media.data {
                let filePath = FileManager.cacheFilePath(media.id)
                
                let didCreateFile = FileManager.default
                    .createFile(atPath: filePath,
                                contents: data,
                                attributes: nil)
                if (didCreateFile) {
                    single(.success(media.id))
                } else {
                    single(.error(StoryError.fileCreationFailed))
                }
            } else {
                // Return success if file already exists
                single(.success(media.id))
            }
            
            return Disposables.create()
        }
    }
    
}
