//
//  QTc.swift
//  QTc
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

// Nomenclature from Rabkin and Cheng, 2015: https://www.wjgnet.com/1949-8462/full/v7/i6/315.htm#B17
public enum Formula {
    case qtcBzt
    case qtcFrd
    case qtcFrm
    case qtcHdg
    case qtcRtha
    case qtcMyd
}

public protocol QTcCalculator {
    var longName: String { get }
    var shortName: String { get }
    var formula: Formula { get }
    // Original reference for the formula
    var reference: String { get }
    
    func calculate(qtInMsec: Double, rrInMsec: Double) -> Double
    func calculate(qtInSec: Double, rrInSec: Double) -> Double
    func calculate(qtInMsec: Double, rate: Double) -> Double
    func calculate(qtInSec: Double, rate: Double) -> Double
}

public class qtcBzt: NSObject, QTcCalculator {
    public let longName = "Bazett"
    public let shortName = "QTcBZT"
    public let formula = Formula.qtcBzt
    public let reference =  "Bazett HC. An analysis of the time relations of electrocardiograms. Heart 1920; 7:353-367."
    
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
    public let longName = "Fridericia"
    public let shortName = "QTcFRD"
    public let formula = Formula.qtcFrd
    public let reference = "Fridericia L. Die sytolendauer in elektrokardiogramm bei normalen menschen und bei herzkranken. Acta Med Scand. 1920;53:469-486."
    
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
    public let longName = "Framingham (Sagie)"
    public let shortName = "QTcFRM"
    public let formula = Formula.qtcFrm
    public let reference = "Sagie A, Larson MG, Goldberg RJ, Bengtson JR, Levy D. An improved method for adjusting the QT interval for heart rate (the Framingham Heart Study). Am J Cardiol. 1992;70:797-801."
    
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
    public let longName = "Hodges"
    public let shortName = "QTcHDG"
    public let formula = Formula.qtcHdg
    public let reference = "Hodges M, Salerno D, Erlien D. Bazett’s QT correction reviewed: Evidence that a linear QT correction for heart rate is better. J Am Coll Cardiol. 1983;1:1983."
    
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
    public let longName = "Rautaharju (2014)a"
    public let shortName = "QTcRTHa"
    public let formula = Formula.qtcRtha
    public let reference = "Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. Int J Cardiol. 2014;174:535-540."
    
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

public class qtcMyd: NSObject, QTcCalculator {
    public let longName = "Mayeda"
    public let shortName = "QTcMYD"
    public let formula = Formula.qtcMyd
    public let reference = "Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Sch Med Univ Imp. 1934;17:53-55"
    
    public func calculate(qtInSec: Double, rate: Double) -> Double {
        return QTc.qtcMyd(qtInSec: qtInSec, rate: rate)
    }
    
    public func calculate(qtInMsec: Double, rate: Double) -> Double {
        return QTc.qtcMyd(qtInMsec: qtInMsec, rate: rate)
    }
    
    public func calculate(qtInSec: Double, rrInSec: Double) -> Double {
        return QTc.qtcMyd(qtInSec: qtInSec, rrInSec: rrInSec)
    }
    
    public func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcMyd(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
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
        case .qtcMyd:
            return qtcMyd()
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
    
    // Power QTc formula function
    private static func qtcExp(qtInSec: Double, rrInSec: Double, exp: Double) -> Double {
        return qtInSec / pow(rrInSec, exp)
    }
    
    // Convert from one set of units to another
    // Note that qtcFunction must have parameters of secs, e.g. qtcBzt(qtInSec:rrInSec)
    private static func qtcConvert(_ qtcFunction: (Double, Double) -> Double,
                                    qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcFunction(msecToSec(qtInMsec), msecToSec(rrInMsec)))
    }
    
    private static func qtcConvert(_ qtcFunction: (Double, Double) -> Double,
                                     qtInSec: Double, rate: Double) -> Double {
        return qtcFunction(qtInSec, bpmToSec(rate))
    }
    
    private static func qtcConvert(_ qtcFunction: (Double, Double) -> Double,
                                              qtInMsec: Double, rate: Double) -> Double {
        return secToMsec(qtcFunction(msecToSec(qtInMsec), bpmToSec(rate)))
    }

    // QTc formulae
    // Base formula always has signature qtcXYZ(qtInSec:rrInSec:), even if original
    // formula in reference has alternative form (e.g. qtcXYZ(qtInSec:rate:).  This allows
    // use of the qtcConvert formulas above to derive all other forms for each formula, i.e.
    //     qtcXYZ(qtInMsec:rrInMsec)
    //     qtcXYZ(qtInSec:rate)
    //     qtcXYZ(qtInMsec:rate)
    
    // Power functions
    // Bazett (QTcBZT)
    
    // Base formula
    public static func qtcBzt(qtInSec: Double, rrInSec: Double) -> Double {
        return qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.5)
    }
    
    public static func qtcBzt(qtInMsec: Double, rrInMsec: Double) -> Double {
        return qtcConvert(qtcBzt(qtInSec:rrInSec:), qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
    public static func qtcBzt(qtInSec: Double, rate: Double) -> Double {
        return qtcConvert(qtcBzt(qtInSec:rrInSec:), qtInSec: qtInSec, rate: rate)

    }
    
    public static func qtcBzt(qtInMsec: Double, rate: Double) -> Double {
        return qtcConvert(qtcBzt(qtInSec:rrInSec:), qtInMsec: qtInMsec, rate: rate)
    }
    
    // Fridericia (QTcFRD)
    // Base formula
    public static func qtcFrd(qtInSec: Double, rrInSec: Double) -> Double {
        return qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 1 / 3.0)
    }
    
    public static func qtcFrd(qtInMsec: Double, rrInMsec: Double) -> Double {
        return qtcConvert(qtcFrd(qtInSec:rrInSec:), qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
    public static func qtcFrd(qtInSec: Double, rate: Double) -> Double {
        return qtcConvert(qtcFrd(qtInSec:rrInSec:), qtInSec: qtInSec, rate: rate)
        
    }
    
    public static func qtcFrd(qtInMsec: Double, rate: Double) -> Double {
        return qtcConvert(qtcFrd(qtInSec:rrInSec:), qtInMsec: qtInMsec, rate: rate)
    }
    
    // Mayeda
    // Base formula
    public static func qtcMyd(qtInSec: Double, rrInSec: Double) -> Double {
        return qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.604)
    }
    
    public static func qtcMyd(qtInMsec: Double, rrInMsec: Double) -> Double {
        return qtcConvert(qtcMyd(qtInSec:rrInSec:), qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
    public static func qtcMyd(qtInSec: Double, rate: Double) -> Double {
        return qtcConvert(qtcMyd(qtInSec:rrInSec:), qtInSec: qtInSec, rate: rate)
        
    }
    
    public static func qtcMyd(qtInMsec: Double, rate: Double) -> Double {
        return qtcConvert(qtcMyd(qtInSec:rrInSec:), qtInMsec: qtInMsec, rate: rate)
    }
    
    // Linear functions
    // Framingham (a.k.a. Sagie) (QTcFRM)
    // Base formula
    public static func qtcFrm(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec + 0.154 * (1.0 - rrInSec)
    }
    
    public static func qtcFrm(qtInMsec: Double, rrInMsec: Double) -> Double {
        return qtcConvert(qtcFrm(qtInSec:rrInSec:), qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
    public static func qtcFrm(qtInSec: Double, rate: Double) -> Double {
        return qtcConvert(qtcFrm(qtInSec:rrInSec:), qtInSec: qtInSec, rate: rate)
        
    }
    
    public static func qtcFrm(qtInMsec: Double, rate: Double) -> Double {
        return qtcConvert(qtcFrm(qtInSec:rrInSec:), qtInMsec: qtInMsec, rate: rate)
    }
    // Rational functions
    // Hodges (QTcHDG)
    // original formula is
    //      return qtInSec + 0.00175 * (rate - 60)
    // converted here to use qtInSec:rrInSec: base
    public static func qtcHdg(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec + 0.00175 * (secToBpm(rrInSec) - 60)
    }
    
    public static func qtcHdg(qtInMsec: Double, rrInMsec: Double) -> Double {
        return qtcConvert(qtcHdg(qtInSec:rrInSec:), qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
    public static func qtcHdg(qtInSec: Double, rate: Double) -> Double {
        return qtcConvert(qtcHdg(qtInSec:rrInSec:), qtInSec: qtInSec, rate: rate)
    }
    
    public static func qtcHdg(qtInMsec: Double, rate: Double) -> Double {
        return qtcConvert(qtcHdg(qtInSec:rrInSec:), qtInMsec: qtInMsec, rate: rate)
    }
    
    // Rautaharju (2014) (QTcRTHa)
    // Original formula is qtInSec:rate: base
    //      return qtInSec * (120.0 + rate) / 180.0
    public static func qtcRtha(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec * (120.0 + secToBpm(rrInSec)) / 180.0
    }
    
    public static func qtcRtha(qtInMsec: Double, rrInMsec: Double) -> Double  {
        return qtcConvert(qtcRtha(qtInSec:rrInSec:), qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
    public static func qtcRtha(qtInSec: Double, rate: Double) -> Double {
        return qtcConvert(qtcRtha(qtInSec:rrInSec:), qtInSec: qtInSec, rate: rate)
    }
    
    public static func qtcRtha(qtInMsec: Double, rate: Double) -> Double {
        return qtcConvert(qtcRtha(qtInSec:rrInSec:), qtInMsec: qtInMsec, rate: rate)
    }
   
    // TODO: probably eliminate this, since having a QTcCalculatorFactory is better.
    // Enumerated funcs
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
        case .qtcMyd:
            return qtcMyd(qtInSec: qtInSec, rrInSec: rrInSec)
        }
    }
    
    
}

