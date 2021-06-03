//
//  AVPlayer+Extension.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 03/06/21.
//

import Foundation
import AVFoundation

extension AVPlayer {
    
    var isPlaying: Bool {
        get {
            return (self.rate != 0 && self.error == nil)
        }
    }
    
}
