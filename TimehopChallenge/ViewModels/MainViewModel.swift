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
    
    var localizedDescription: String {
        switch self {
        case .fileCreationFailed:
            return NSLocalizedString("Could not create file at path", comment: "File creation failed")
        case .invalidUrl:
            return NSLocalizedString("Could not find a valid story url", comment: "Invalid story url")
        case .notEnoughSpace:
            return NSLocalizedString("Not enough disk space to create file", comment: "Not enough space")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "Unknown")
        }
    }
}

class MainViewModel {
    
    private let repository: Repository
    private let imageCache: ImageCache
    private let fileHelper: FileHelper
    private let disposeBag = DisposeBag()
    private(set) var mediaSet = BehaviorRelay<OrderedSet<Media>>(value: [])
    private(set) var media = BehaviorRelay<Media?>(value: nil)
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    
    private let queue = DispatchQueue(label: "mediaSet", attributes: .concurrent)
    
    init(repository: Repository, imageCache: ImageCache, fileHelper: FileHelper) {
        self.repository = repository
        self.imageCache = imageCache
        self.fileHelper = fileHelper
    }
    
    var isFetching: Driver<Bool> {
        _isFetching.asDriver()
    }
    
    func getNextStory() {
        let mediaSet = self.mediaSet.value
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
        let mediaSet = self.mediaSet.value
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
        _isFetching.accept(true)
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
                
                var mediaSet = strongSelf.mediaSet.value
                mediaSet.append(media)
                strongSelf.mediaSet.accept(mediaSet)
                
                if strongSelf.media.value == nil {
                    strongSelf.media.accept(media)
                }
            }, onError: { [weak self] error in
                self?._isFetching.accept(false)
            },
            onCompleted: { [weak self] in
                self?._isFetching.accept(false)
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
    
    private func downloadMedia(story: Story) -> Single<Media> {
        guard let largeUrlString = story.largeUrl?.absoluteString else {
            return Single<Media>.error(StoryError.invalidUrl)
        }
        
        if let url = fileHelper.findFile(directory: .cachesDirectory,
                                             name: largeUrlString.md5) {
            let ext = url.pathExtension
            let mimeType = MimeType.all.first(where: { $0.ext == ext })
            return Single<Media>.create { [weak self] single in
                single(.success(Media(id: story.id,
                                      type: self?.getMediaType(mimeType: mimeType) ?? .undefined,
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
        return Single<Media>.create { [weak self] single in
            guard let strongSelf = self,
                  strongSelf.fileHelper.isStorageAvailable(directory: .cachesDirectory,
                                                           data: data) else {
                single(.error(StoryError.notEnoughSpace))
                return Disposables.create()
            }
            
            var fileName = md5
            let mimeType = Swime.mimeType(data: data)
            
            if let ext = mimeType?.ext,
               let fileNameWithExt = md5.stringByAppendingPathExtension(ext: ext) {
                fileName = fileNameWithExt
            }
            
            if let fileUrl = strongSelf.fileHelper.createFile(directory: .cachesDirectory,
                                                              name: fileName,
                                                              data: data) {
                single(.success(Media(id: id,
                                      type: strongSelf.getMediaType(mimeType: mimeType),
                                      url: fileUrl)))
            } else {
                single(.error(StoryError.fileCreationFailed))
            }
            
            return Disposables.create()
        }
    }
    
    private func getMediaType(mimeType: MimeType?) -> MediaType {
        var type: MediaType!
        switch mimeType?.type {
        case .mp4, .avi, .wav, .mov:
            type = .video
        case .jpg, .png, .bmp, .gif:
            type = .image
        default:
            type = .undefined
        }
        return type
    }
    
}
