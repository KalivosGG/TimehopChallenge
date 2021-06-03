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
import Swime

enum StoryError: Error {
    case invalidUrl
    case fileCreationFailed
    case notEnoughSpace
    case unknown
}

class MainViewModel {
    
    private let repository: Repository
    private let disposeBag = DisposeBag()
    private(set) var media = BehaviorRelay<Media?>(value: nil)
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func getStories() {
        repository.getStories()
            .retry(3)
            .map { $0.images }
            //.debug()
            
            //Map observable of array to array of observables
            .asObservable()
            .flatMap { Observable.from($0) }
            
            //Download and save data (media)
            .flatMap { [weak self] story -> Observable<Media> in
                guard let strongSelf = self else {
                    return Observable<Media>.error(StoryError.unknown)
                }
                return strongSelf
                    .downloadMedia(story: story)
                    .asObservable()
                    .filterErrors()
            }
            
            .subscribe(onNext: { media in
                self.media.accept(media)
            })
            .disposed(by: disposeBag)
    }
    
    private func getLocalFileUrl(md5: String) -> URL? {
        guard let fileUrl = FileManager.cacheDirectory,
              let contents = try? FileManager.default.contentsOfDirectory(atPath: fileUrl.path),
              let fileName = contents.first(where: { $0.contains(md5) }) else {
            return nil
        }
        return FileManager.cacheFileUrl(fileName)
    }
    
    private func downloadMedia(story: Story) -> Single<Media> {
        guard let largeUrlString = story.largeUrl?.absoluteString else {
            return Single<Media>.error(StoryError.invalidUrl)
        }
        
        if let url = getLocalFileUrl(md5: largeUrlString.md5) {
            let ext = url.pathExtension
            return Single<Media>.create { single in
                single(.success(Media(id: story.id,
                                      type: ext == "mp4" ? .video : .image,
                                      url: url)))
                return Disposables.create()
            }
        } else {
            return repository
                .getMedia(largeUrlString: largeUrlString)
                .retry(3)
                .flatMap { [weak self] in
                    guard let strongSelf = self else {
                        return Single<Media>.error(StoryError.unknown)
                    }
                    return strongSelf
                        .saveMedia(id: story.id,
                                   md5: largeUrlString.md5,
                                   data: $0)
                }
        }
    }
    
    private func saveMedia(id: Int, md5: String, data: Data) -> Single<Media> {
        return Single<Media>.create { single in
            guard FileManager.isCacheStorageAvailable(data: data) else {
                single(.error(StoryError.notEnoughSpace))
                return Disposables.create()
            }
            
            guard let mimeType = Swime.mimeType(data: data),
                  let fileName = md5.stringByAppendingPathExtension(ext: mimeType.ext),
                  let fileUrl = FileManager.cacheFileUrl(fileName),
                  FileManager
                    .default
                    .createFile(atPath: fileUrl.path,
                                contents: data,
                                attributes: nil) else {
                single(.error(StoryError.fileCreationFailed))
                return Disposables.create()
            }
            
            single(.success(Media(id: id,
                                  type: mimeType.type == .mp4 ? .video : .image,
                                  url: fileUrl)))
            
            return Disposables.create()
        }
    }
    
}
