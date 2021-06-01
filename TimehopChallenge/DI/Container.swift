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
        
        container.register(RemoteRepository.self) { _ -> RemoteRepository in
            return RemoteRepository()
        }
        
        container.register(MainViewModel.self) { r in
            return MainViewModel(repository: r.resolve(RemoteRepository.self)!)
        }
        
        container.register(MainViewController.self) { r in
            return MainViewController(viewModel: r.resolve(MainViewModel.self)!)
        }
        
        return container
    }()
    
}
