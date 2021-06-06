//
//  ImageCacheMock.swift
//  TimehopChallengeTests
//
//  Created by Victor H. Rezende Takai on 05/06/21.
//

import Foundation
import UIKit

@testable import TimehopChallenge

class ImageCacheMock: ImageCache {
    
    func saveImage(image: UIImage, key: String) {}
    
    func getImage(key: String) -> UIImage? {
        return nil
    }
    
}
