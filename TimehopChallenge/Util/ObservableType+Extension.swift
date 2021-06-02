//
//  ObservableType+Extension.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 01/06/21.
//

import Foundation
import RxSwift

extension ObservableType {
    
    func filterErrors() -> Observable<Element> {
        return materialize().compactMap { $0.element }
    }
    
}
