//
//  Decodable+Extension.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 29/05/21.
//

import Foundation

extension Decodable {
    
    static func fromJSON(_ fileName: String, fileExtension: String = "json") -> Data {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            fatalError("Error to create URL")
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            print(error)
            fatalError("Error to load json")
        }
    }
    
}
