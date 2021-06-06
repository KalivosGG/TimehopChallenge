//
//  FileHelperMock.swift
//  TimehopChallengeTests
//
//  Created by Victor H. Rezende Takai on 06/06/21.
//

import Foundation

@testable import TimehopChallenge

class SuccessFileHelperMock: FileHelper {

    func findFile(directory: FileManager.SearchPathDirectory, name: String) -> URL? {
        return URL(string: name)
    }

    func createFile(directory: FileManager.SearchPathDirectory, name: String, data: Data) -> URL? {
        return URL(string: name)
    }

    func isStorageAvailable(directory: FileManager.SearchPathDirectory, data: Data) -> Bool {
        return true
    }

}

class FileNotFoundFileHelperMock: FileHelper {
    
    func findFile(directory: FileManager.SearchPathDirectory, name: String) -> URL? {
        return nil
    }
    
    func createFile(directory: FileManager.SearchPathDirectory, name: String, data: Data) -> URL? {
        return URL(string: name)
    }
    
    func isStorageAvailable(directory: FileManager.SearchPathDirectory, data: Data) -> Bool {
        return true
    }
    
}

class OnlyFirstFileHelperMock: FileHelper {
    
    func findFile(directory: FileManager.SearchPathDirectory, name: String) -> URL? {
        return nil
    }
    
    func createFile(directory: FileManager.SearchPathDirectory, name: String, data: Data) -> URL? {
        let md5 = getStoriesMock().first?.largeUrl?.absoluteString.md5
        if name == md5 {
            return URL(string: name)
        } else {
            return nil
        }
    }
    
    func isStorageAvailable(directory: FileManager.SearchPathDirectory, data: Data) -> Bool {
        return true
    }
    
}
