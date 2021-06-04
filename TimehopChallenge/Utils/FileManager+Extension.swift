//
//  FileManager+Extension.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 30/05/21.
//

import Foundation

extension FileManager {
    
    static let cacheDirectory: URL? = {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }()
    
    static func cacheFileUrl(_ fileName: String) -> URL? {
        return cacheDirectory?.appendingPathComponent(fileName)
    }
    
    static func isCacheStorageAvailable(data: Data) -> Bool {
        guard let cacheDirectoryPath = cacheDirectory?.path else {
            return false
        }
        
        let fileURL = URL(fileURLWithPath: cacheDirectoryPath)
        guard let values = try? fileURL
                .resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
              let freeSpace = values.volumeAvailableCapacityForImportantUsage else {
            return false
        }
        return freeSpace > data.count
    }
    
}
