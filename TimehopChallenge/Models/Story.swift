//
//  SplashbaseTarget.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 29/05/21.
//

import Foundation

struct Story: Decodable {
    let id: Int
    let url: URL?
    let largeUrl: URL?
    let sourceId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case largeUrl = "large_url"
        case sourceId = "source_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.url = URL(string: try container.decode(String.self, forKey: .url))
        self.largeUrl = URL(string: try container.decode(String.self, forKey: .largeUrl))
        self.sourceId = try container.decode(Int?.self, forKey: .sourceId)
    }
    
}
