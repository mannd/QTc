//
//  QTc.swift
//  QTc
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

public enum Formula {
    case qtcBzt
    case qtcFrd
    case qtcFrm
    case qtcHdg
    case qtcRtha
}

public protocol QTcCalculator {
    var longName: String {get}
    var shortName: String {get}
    var formula: Formula {get}
    // Original reference for the formula
    // var reference: String {get}
    
    func calculate(qtInMsec: Double, rrInMsec: Double) -> Double
    func calculate(qtInSec: Double, rrInSec: Double) -> Double
    func calculate(qtInMsec: Double, rate: Double) -> Double
    func calculate(qtInSec: Double, rate: Double) -> Double
}

public class qtcBzt: NSObject, QTcCalculator {
    public var longName = "Bazett"
    public let shortName = "QTcBZT"
    public let formula = Formula.qtcBzt
    
    public func calculate(qtInSec: Double, rate: Double) -> Double {
        return QTc.qtcBzt(qtInSec: qtInSec, rate: rate)
    }
    
    public func calculate(qtInMsec: Double, rate: Double) -> Double {
        return QTc.qtcBzt(qtInMsec: qtInMsec, rate: rate)
    }
    
    public func calculate(qtInSec: Double, rrInSec: Double) -> Double {
        return QTc.qtcBzt(qtInSec: qtInSec, rrInSec: rrInSec)
    }
    
    public func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcBzt(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
}

public class qtcFrd: NSObject, QTcCalculator {
    public var longName = "Fridericia"
    public let shortName = "QTcFRD"
    public let formula = Formula.qtcFrd
    
    public func calculate(qtInSec: Double, rate: Double) -> Double {
        return QTc.qtcFrd(qtInSec: qtInSec, rate: rate)
    }
    
    public func calculate(qtInMsec: Double, rate: Double) -> Double {
        return QTc.qtcFrd(qtInMsec: qtInMsec, rate: rate)
    }
    
    public func calculate(qtInSec: Double, rrInSec: Double) -> Double {
        return QTc.qtcFrd(qtInSec: qtInSec, rrInSec: rrInSec)
    }
    
    public func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcFrd(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
}

public class qtcFrm: NSObject, QTcCalculator {
    public var longName = "Framingham (Sagie)"
    public let shortName = "QTcFRM"
    public let formula = Formula.qtcFrm
    
    public func calculate(qtInSec: Double, rate: Double) -> Double {
        return QTc.qtcFrm(qtInSec: qtInSec, rate: rate)
    }
    
    public func calculate(qtInMsec: Double, rate: Double) -> Double {
        return QTc.qtcFrm(qtInMsec: qtInMsec, rate: rate)
    }
    
    public func calculate(qtInSec: Double, rrInSec: Double) -> Double {
        return QTc.qtcFrm(qtInSec: qtInSec, rrInSec: rrInSec)
    }
    
    public func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcFrm(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
}

public class qtcHdg: NSObject, QTcCalculator {
    public var longName = "Hodges"
    public let shortName = "QTcHDG"
    public let formula = Formula.qtcHdg
    
    public func calculate(qtInSec: Double, rate: Double) -> Double {
        return QTc.qtcHdg(qtInSec: qtInSec, rate: rate)
    }
    
    public func calculate(qtInMsec: Double, rate: Double) -> Double {
        return QTc.qtcHdg(qtInMsec: qtInMsec, rate: rate)
    }
    
    public func calculate(qtInSec: Double, rrInSec: Double) -> Double {
        return QTc.qtcHdg(qtInSec: qtInSec, rrInSec: rrInSec)
    }
    
    public func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcHdg(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
}

public class qtcRtha: NSObject, QTcCalculator {
    public var longName = "Rautaharju (2014)a"
    public let shortName = "QTcRTHa"
    public let formula = Formula.qtcRtha
    
    public func calculate(qtInSec: Double, rate: Double) -> Double {
        return QTc.qtcRtha(qtInSec: qtInSec, rate: rate)
    }
    
    public func calculate(qtInMsec: Double, rate: Double) -> Double {
        return QTc.qtcRtha(qtInMsec: qtInMsec, rate: rate)
    }
    
    public func calculate(qtInSec: Double, rrInSec: Double) -> Double {
        return QTc.qtcRtha(qtInSec: qtInSec, rrInSec: rrInSec)
    }
    
    public func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcRtha(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
}



// TODO: other qtc classes here

// Factory class
public class QTcCalculatorFactory: NSObject {
    public func getCalculator(formula: Formula) -> QTcCalculator {
        switch formula {
        case .qtcBzt:
            return qtcBzt()
        case .qtcFrd:
            return qtcFrd()
        case .qtcFrm:
            return qtcFrm()
        case .qtcHdg:
            return qtcHdg()
        case .qtcRtha:
            return qtcRtha()
        }
    }
}

/// TODO: is @objc tag needed if inheritance from NSObject?
@objc public class QTc: NSObject {
    
    // static conversion functions
    public static func secToMsec(_ sec: Double) -> Double {
        return sec * 1000
    }
    
    public static func msecToSec(_ msec: Double) -> Double {
        return msec / 1000
    }
    
    public static func bpmToSec(_ bpm: Double) -> Double {
        return 60 / bpm
    }
    
    public static func secToBpm(_ sec: Double) -> Double {
        return 60 / sec
    }
    
    public static func bpmToMsec(_ bpm: Double) -> Double {
        return 60_000 / bpm
    }
    
    public static func msecToBpm(_ msec: Double) -> Double {
        return 60_000 / msec
    }
    
    // QTc formulae
    
    // Bazett (QTcBZT)
    // base formula
    public static func qtcBzt(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec / sqrt(rrInSec)
    }
    
    public static func qtcBzt(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcBzt(qtInSec: msecToSec(qtInMsec), rrInSec: msecToSec(rrInMsec)))
    }
    
    public static func qtcBzt(qtInSec: Double, rate: Double) -> Double {
        return qtcBzt(qtInSec: qtInSec, rrInSec: bpmToSec(rate))
    }
    
    public static func qtcBzt(qtInMsec: Double, rate: Double) -> Double {
        return qtcBzt(qtInMsec: qtInMsec, rrInMsec: bpmToMsec(rate))
    }
    
    // Fridericia (QTcFRD)
    // base formula
    public static func qtcFrd(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec / pow(rrInSec, 1 / 3.0)
    }
    
    public static func qtcFrd(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcFrd(qtInSec: msecToSec(qtInMsec), rrInSec: msecToSec(rrInMsec)))
    }
    
    public static func qtcFrd(qtInSec: Double, rate: Double) -> Double {
        return qtcFrd(qtInSec: qtInSec, rrInSec: bpmToSec(rate))
    }
    
    public static func qtcFrd(qtInMsec: Double, rate: Double) -> Double {
        return qtcFrd(qtInMsec: qtInMsec, rrInMsec: bpmToMsec(rate))
    }
    
    // Framingham (a.k.a. Sagie) (QTcFRM)
    // base formula
    public static func qtcFrm(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec + 0.154 * (1.0 - rrInSec)
    }
    
    public static func qtcFrm(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcFrm(qtInSec: msecToSec(qtInMsec), rrInSec: msecToSec(rrInMsec)))
    }
    
    public static func qtcFrm(qtInSec: Double, rate: Double) -> Double {
        return qtcFrm(qtInSec: qtInSec, rrInSec: bpmToSec(rate))
    }
    
    public static func qtcFrm(qtInMsec: Double, rate: Double) -> Double {
        return qtcFrm(qtInMsec: qtInMsec, rrInMsec: bpmToMsec(rate))
    }
    
    // Hodges (QTcHDG)
    public static func qtcHdg(qtInSec: Double, rrInSec: Double) -> Double {
        return qtcHdg(qtInSec: qtInSec, rate: secToBpm(rrInSec))
    }
    
    public static func qtcHdg(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcHdg(qtInSec: msecToSec(qtInMsec), rate: msecToBpm(rrInMsec)))
    }
    
    //base formula
    public static func qtcHdg(qtInSec: Double, rate: Double) -> Double {
        return qtInSec + 0.00175 * (rate - 60)
    }
    
    public static func qtcHdg(qtInMsec: Double, rate: Double) -> Double {
        return secToMsec(qtcHdg(qtInSec: msecToSec(qtInMsec), rate: rate))
    }
    
    // Rautaharju (2014) (QTcRTHa)
    public static func qtcRtha(qtInSec: Double, rrInSec: Double) -> Double {
        return qtcRtha(qtInSec: qtInSec, rate: secToBpm(rrInSec))
    }
    
    public static func qtcRtha(qtInMsec: Double, rrInMsec: Double) -> Double  {
        return secToMsec(qtcRtha(qtInSec: msecToSec(qtInMsec), rate: msecToBpm(rrInMsec)))
    }
    
    public static func qtcRtha(qtInSec: Double, rate: Double) -> Double {
        return qtInSec * (120.0 + rate) / 180.0
    }
    
    public static func qtcRtha(qtInMsec: Double, rate: Double) -> Double {
        return secToMsec(qtcRtha(qtInSec: msecToSec(qtInMsec), rate: rate))
    }
    
    // Enummerated funcs
    // Using the Formula enum, select a formula or iterate through them all
    public static func qtc(formula: Formula, qtInSec: Double, rrInSec: Double) -> Double {
        switch formula {
        case .qtcBzt:
            return qtcBzt(qtInSec: qtInSec, rrInSec: rrInSec)
        case .qtcFrd:
            return qtcFrd(qtInSec: qtInSec, rrInSec: rrInSec)
        case .qtcFrm:
            return qtcFrm(qtInSec: qtInSec, rrInSec: rrInSec)
        case .qtcHdg:
            return qtcHdg(qtInSec: qtInSec, rrInSec: rrInSec)
        case .qtcRtha:
            return qtcRtha(qtInSec: qtInSec, rrInSec: rrInSec)
        }
    }
    
    
}

