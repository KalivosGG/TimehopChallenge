//
//  FileService.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 06/06/21.
//

import Foundation

protocol FileHelper {
        
    func findFile(directory: FileManager.SearchPathDirectory, name: String) -> URL?
    
    func createFile(directory: FileManager.SearchPathDirectory, name: String, data: Data) -> URL?
    
    func isStorageAvailable(directory: FileManager.SearchPathDirectory, data: Data) -> Bool
    
}

class FileHelperService: FileHelper {
     
    func findFile(directory: FileManager.SearchPathDirectory, name: String) -> URL? {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first,
              let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path),
              let fileName = contents.first(where: { $0.contains(name) }) else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func createFile(directory: FileManager.SearchPathDirectory, name: String, data: Data) -> URL? {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return nil
        }
        let fileUrl = url.appendingPathComponent(name)
        let didCreateFile =  FileManager.default.createFile(atPath: fileUrl.path,
                                                            contents: data,
                                                            attributes: nil)
        
        return didCreateFile ? fileUrl : nil
    }
    
    func isStorageAvailable(directory: FileManager.SearchPathDirectory, data: Data) -> Bool {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first,
              let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
              let freeSpace = values.volumeAvailableCapacityForImportantUsage else {
            return false
        }
        return freeSpace > data.count
    }
    
}
