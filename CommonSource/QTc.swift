//
//  QTc.swift
//  QTc
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

@objc public class QTc : NSObject {
    // static conversion functions
    static func secToMsec(_ sec: Double) -> Double {
        return sec * 1000
    }

    static func msecToSec(_ msec: Double) -> Double {
        return msec / 1000
    }
    
    static func bpmToSec(_ bpm: Double) -> Double {
        return 60 / bpm
    }

    static func secToBpm(_ sec: Double) -> Double {
        return 60 / sec
    }

    static func bpmToMsec(_ bpm: Double) -> Double {
        return 60000 / bpm
    }

    static func msecToBpm(_ msec: Double) -> Double {
        return 60000 / msec
    }
}

