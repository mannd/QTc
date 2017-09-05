//
//  QTc.swift
//  QTc
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

/// TODO: is @objc tag needed if inheritance from NSObject?
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
    
    // QTc formulae
    
    // Bazett (QTcBZT)
    static func qtcBzt(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec / sqrt(rrInSec)
    }
    
    static func qtcBzt(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcBzt(qtInSec:msecToSec(qtInMsec), rrInSec:msecToSec(rrInMsec)))
    }
    
    static func qtcBzt(qtInSec: Double, rate: Double) -> Double {
        return qtcBzt(qtInSec:qtInSec, rrInSec: bpmToSec(rate))
    }
    
    static func qtcBzt(qtInMsec: Double, rate: Double) -> Double {
        return qtcBzt(qtInMsec: qtInMsec, rrInMsec: bpmToMsec(rate))
    }
}

