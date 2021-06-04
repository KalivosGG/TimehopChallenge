//
//  ImageCache.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 04/06/21.
//

import Foundation
import UIKit

protocol ImageCacheType {
    
    func saveImage(image: UIImage, key: String)
    
    func getImage(key: String) -> UIImage?
    
}

final class ImageCache: ImageCacheType {
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    private let lock = NSLock()
    
    func saveImage(image: UIImage, key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        imageCache.setObject(image.decodedImage(), forKey: key as NSString)
    }
    
    func getImage(key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
         
        return imageCache.object(forKey: key as NSString)
    }
    
}
