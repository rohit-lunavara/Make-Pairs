//
//  Constants.swift
//  Challenge10
//
//  Created by Rohit Lunavara on 6/25/20.
//  Copyright © 2020 Rohit Lunavara. All rights reserved.
//

import Foundation
import UIKit

struct K {
    static let gameName = "Make-Pairs"
    static let hiddenName = "Flip!"
    static let shownColor = UIColor(red: 0.42, green: 0.69, blue: 0.30, alpha: 1.00)
    static let hiddenColor = UIColor(red: 0.92, green: 0.30, blue: 0.29, alpha: 1.00)
    
    struct Keys {
        static let currentWords = "CurrentWords"
        static let activeWords = "ActiveWords"
        static let foundWords = "FoundWords"
        static let flips = "Flips"
    }
    
    struct Bounds {
        static let tagLowerBound = 1
        static let tagUpperBound = 16
        static let wordsToWin = 16
    }
    
    struct Animation {
        static let flipTransitionTime = 0.25
        static let restartGameTime = 0.70
        static let answerDelay = 0.35
    }
}
