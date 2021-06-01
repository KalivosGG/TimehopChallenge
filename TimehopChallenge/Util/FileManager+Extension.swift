//
//  FileManager+Extension.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 30/05/21.
//

import Foundation

extension FileManager {
    
    static let cacheDirectory: URL = {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }()
    
    static func cacheFilePath(_ fileName: String) -> String {
        return FileManager.cacheDirectory.appendingPathComponent(fileName).path
    }
    
}
