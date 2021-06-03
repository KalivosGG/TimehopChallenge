//
//  Media.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 31/05/21.
//

import Foundation

enum MediaType {
    case image
    case video
}

struct Media: Hashable {
    let id: Int
    let type: MediaType
    let url: URL?
}
