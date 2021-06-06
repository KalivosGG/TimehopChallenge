//
//  Container.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 30/05/21.
//

import Foundation
import Swinject

extension Container {
    
    static let shared: Container = {
        let container = Container()
        
        container.register(ImageCache.self) { _ in
            ImageCacheService()
        }.inObjectScope(.container)
        
        container.register(FileHelper.self) { _ in
            FileHelperService()
        }.inObjectScope(.container)
        
        container.register(TargetRepository.self) { _ in
            StoriesRepository()
        }
        
        container.register(AWSTargetRepository.self) { _ in
            MediaRepository()
        }
        
        container.register(Repository.self) { r in
            RemoteRepository(targetRepository: r.resolve(TargetRepository.self)!,
                             awsTargetRepository: r.resolve(AWSTargetRepository.self)!)
        }
        
        container.register(MainViewModel.self) { r in
            MainViewModel(repository: r.resolve(Repository.self)!,
                          imageCache: r.resolve(ImageCache.self)!,
                          fileHelper: r.resolve(FileHelper.self)!)
        }
        
        container.register(MainViewController.self) { r in
            MainViewController(viewModel: r.resolve(MainViewModel.self)!,
                               imageCache: r.resolve(ImageCache.self)!)
        }
        
        return container
    }()
    
}
