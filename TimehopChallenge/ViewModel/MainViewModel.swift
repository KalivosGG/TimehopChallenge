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
    private(set) var media = BehaviorRelay<[Media]>(value: [])
    
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
            .flatMap { self.downloadMedia(story: $0) }
            .retry(3)
            
            //Save data to cache folder
            .flatMap { self.saveMedia(media: $0) }
            
            .subscribe(onNext: { media in
                print(media)
            }, onError: { error in
                print(error.localizedDescription)
            }, onCompleted: {
                print("completed")
                do {
                    let files = try FileManager
                        .default
                        .contentsOfDirectory(atPath: FileManager.cacheDirectory.path)
                    dump(files)
                } catch {
                    print(error)
                }
            }, onDisposed: {
                print("disposed")
            })
            .disposed(by: disposeBag)
    }
    
    private func didDownloadMedia(fileName: String) -> Bool {
        let filePath = FileManager.cacheFilePath(fileName)
        return !FileManager.default.fileExists(atPath: filePath)
    }
    
    private func downloadMedia(story: Story) -> Single<Media> {
        guard let urlString = story.url?.absoluteString else {
            return Single<Media>.error(StoryError.invalidUrl)
        }
        
        if !didDownloadMedia(fileName: urlString.md5) {
            return Single<Media>.create { single in
                single(.success(Media(id: urlString.md5, data: nil)))
                return Disposables.create()
            }
        }
        
        return repository.getMedia(urlString: urlString)
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
                // Return success if file was already downloaded/created
                single(.success(media.id))
            }
            
            return Disposables.create()
        }
    }
    
}
