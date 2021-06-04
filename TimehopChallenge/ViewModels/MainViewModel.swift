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
import OrderedCollections

enum StoryError: Error {
    case invalidUrl
    case fileCreationFailed
    case notEnoughSpace
    case unknown
}

class MainViewModel {
    
    private let repository: Repository
    private let imageCache: ImageCacheType
    private let disposeBag = DisposeBag()
    private var mediaSet = OrderedSet<Media>()
    private(set) var media = BehaviorRelay<Media?>(value: nil)
    
    private let queue = DispatchQueue(label: "mediaSet", attributes: .concurrent)
    
    init(repository: Repository, imageCache: ImageCacheType) {
        self.repository = repository
        self.imageCache = imageCache
    }
    
    func getNextStory() {
        guard let currentMedia = media.value,
              let currentIndex = mediaSet.firstIndex(of: currentMedia),
              currentIndex + 1 < mediaSet.count else {
            return
        }
        let nextIndex = mediaSet.index(after: currentIndex)
        let nextMedia = mediaSet[nextIndex]
        media.accept(nextMedia)
    }
    
    func getPreviousStory() {
        guard let currentMedia = media.value,
              let currentIndex = mediaSet.firstIndex(of: currentMedia),
              currentIndex - 1 >= 0 else {
            return
        }
        let previousIndex = mediaSet.index(before: currentIndex)
        let previousMedia: Media? = mediaSet[previousIndex]
        media.accept(previousMedia)
    }
    
    func getStories() {
        repository.getStories()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
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
            
            .subscribe(onNext: { [weak self] media in
                guard let strongSelf = self else { return }
               
                strongSelf.cacheMedia(media: media)
                
                strongSelf.queue.async(flags: .barrier) {
                    strongSelf.mediaSet.append(media)
                }
                
                if strongSelf.media.value == nil {
                    strongSelf.media.accept(media)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func cacheMedia(media: Media) {
        let key = media.url.path
        if media.type == .image {
            if imageCache.getImage(key: key) == nil,
               let data = FileManager.default.contents(atPath: key),
               let image = UIImage(data: data) {
                imageCache.saveImage(image: image, key: key)
            }
        }
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
