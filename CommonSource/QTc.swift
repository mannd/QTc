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
    case qtcArr
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

// MARK: QTc classes

private struct qtcFunction {
    let longName: String
    let shortName: String
    let reference: String
    let baseFunction: (Double, Double) -> Double
    
    init(shortName: String, longName: String, reference: String, baseFunction: @escaping (Double, Double) -> Double) {
        self.shortName = shortName
        self.longName = longName
        self.reference = reference
        self.baseFunction = baseFunction
    }
    
    func calculate(qt: Double, rr: Double) -> Double {
        return baseFunction(qt, rr)
    }
    
    func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcConvert(baseFunction, qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
}

public class qtcBzt: NSObject, QTcCalculator {
    public let longName = "Bazett"
    public let shortName = "QTcBZT"
    public let formula = Formula.qtcBzt
    public let reference = "Bazett HC. An analysis of the time relations of electrocardiograms. Heart 1920; 7:353-367."
    
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
    public let reference = "Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Sch Med Univ Imp. 1934;17:53-55."
    
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

public class qtcArr: NSObject, QTcCalculator {
    public let longName = "Arrowood"
    public let shortName = "QTcArr"
    public let formula = Formula.qtcArr
    public let reference = "Arrowood JA, Kline J, Simpson PM, Quigg RJ, Pippin JJ, Nixon JV, Mohanty PK.  Modulation of the QT interval: effects of graded exercise and reflex cardiovascular stimulation.  J Appl Physiol. 1993;75:2217-2223"
    
    public func calculate(qtInSec: Double, rate: Double) -> Double {
        return QTc.qtcArr(qtInSec: qtInSec, rate: rate)
    }
    
    public func calculate(qtInMsec: Double, rate: Double) -> Double {
        return QTc.qtcArr(qtInMsec: qtInMsec, rate: rate)
    }
    
    public func calculate(qtInSec: Double, rrInSec: Double) -> Double {
        return QTc.qtcArr(qtInSec: qtInSec, rrInSec: rrInSec)
    }
    
    public func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcArr(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
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
        case .qtcArr:
            return qtcArr()
        }
    }
}

// MARK: QTc class

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
    // These have form QTc = QT / pow(RR, exp)
    private static func qtcExp(qtInSec: Double, rrInSec: Double, exp: Double) -> Double {
        return qtInSec / pow(rrInSec, exp)
    }
    
    // Linear QTc formula function
    // These have form QTc = QT + α(1 - RR)
    private static func qtcLinear(qtInSec: Double, rrInSec: Double, alpha: Double) -> Double {
        return qtInSec + alpha * (1 - rrInSec)
    }
    
    // Convert from one set of units to another
    // Note that qtcFunction must have parameters of secs, e.g. qtcBzt(qtInSec:rrInSec)
    public static func qtcConvert(_ qtcFunction: (Double, Double) -> Double,
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
    
    // QTp conversion
    private static func qtpConvert(_ qtpFunction: (Double) -> Double, rrInMsec: Double) -> Double {
        return secToMsec(qtpFunction(msecToSec(rrInMsec)))
    }
    
    // returns QTp in seconds!
    private static func qtpConvert(_ qtpFunction: (Double) -> Double, rate: Double) -> Double {
        return qtpFunction(bpmToSec(rate))
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
        return qtcLinear(qtInSec: qtInSec, rrInSec: rrInSec, alpha: 0.154)
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
    
    // Arrowood
    public static func qtcArr(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec + 0.304 - 0.492 * exp(-0.008 * secToBpm(rrInSec))
    }
    
    public static func qtcArr(qtInMsec: Double, rrInMsec: Double) -> Double  {
        return qtcConvert(qtcArr(qtInSec:rrInSec:), qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
    public static func qtcArr(qtInSec: Double, rate: Double) -> Double {
        return qtcConvert(qtcArr(qtInSec:rrInSec:), qtInSec: qtInSec, rate: rate)
    }
    
    public static func qtcArr(qtInMsec: Double, rate: Double) -> Double {
        return qtcConvert(qtcArr(qtInSec:rrInSec:), qtInMsec: qtInMsec, rate: rate)
    }

    // MARK: QTp functions.  These functions calculate what the QT "should be" at a given rate
    // or interval.
    
    // QTpARR
    public static func qtpArr(rrInSec: Double) -> Double {
        return 0.12 + 0.492 * exp(-0.008 * secToBpm(rrInSec))
    }
    
    public static func qtpArr(rrInMsec: Double) -> Double {
        return qtpConvert(qtpArr(rrInSec:), rrInMsec: rrInMsec)
    }
    
    // TODO: should functions like this return in msec, ie. make msec the default return value?
    // or have qtp funcs named like qtpArrInMsec(), qtpArrInSec()??
    // returns QTp in seconds
    public static func qtpArr(rate: Double) -> Double {
        return qtpConvert(qtpArr(rrInSec:), rate: rate)
    }

    
    // MARK: Enumerated static funcs
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
        case .qtcArr:
            return qtcArr(qtInSec: qtInSec, rrInSec: rrInSec)
        }
    }
    
    public static func qtc(formula: Formula, qtInMsec: Double, rrInMsec: Double) -> Double {
        switch formula {
        case .qtcBzt:
            return qtcBzt(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
        case .qtcFrd:
            return qtcFrd(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
        case .qtcFrm:
            return qtcFrm(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
        case .qtcHdg:
            return qtcHdg(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
        case .qtcRtha:
            return qtcRtha(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
        case .qtcMyd:
            return qtcMyd(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
        case .qtcArr:
            return qtcArr(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
        }
    }

    public static func qtc(formula: Formula, qtInSec: Double, rate: Double) -> Double {
        switch formula {
        case .qtcBzt:
            return qtcBzt(qtInSec: qtInSec, rate: rate)
        case .qtcFrd:
            return qtcFrd(qtInSec: qtInSec, rate: rate)
        case .qtcFrm:
            return qtcFrm(qtInSec: qtInSec, rate: rate)
        case .qtcHdg:
            return qtcHdg(qtInSec: qtInSec, rate: rate)
        case .qtcRtha:
            return qtcRtha(qtInSec: qtInSec, rate: rate)
        case .qtcMyd:
            return qtcMyd(qtInSec: qtInSec, rate: rate)
        case .qtcArr:
            return qtcArr(qtInSec: qtInSec, rate: rate)
        }
    }

    public static func qtc(formula: Formula, qtInMsec: Double, rate: Double) -> Double {
        switch formula {
        case .qtcBzt:
            return qtcBzt(qtInMsec: qtInMsec, rate: rate)
        case .qtcFrd:
            return qtcFrd(qtInMsec: qtInMsec, rate: rate)
        case .qtcFrm:
            return qtcFrm(qtInMsec: qtInMsec, rate: rate)
        case .qtcHdg:
            return qtcHdg(qtInMsec: qtInMsec, rate: rate)
        case .qtcRtha:
            return qtcRtha(qtInMsec: qtInMsec, rate: rate)
        case .qtcMyd:
            return qtcMyd(qtInMsec: qtInMsec, rate: rate)
        case .qtcArr:
            return qtcArr(qtInMsec: qtInMsec, rate: rate)
        }
    }
    
    private static func qtcBztAlt(qtInSec: Double, rrInSec: Double) -> Double {
        return qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.5)    }
    
    public static func qtcAlt(qt: Double, rr: Double) -> Double {
        let qtcBzt = qtcFunction(shortName: "qtcBztAlt", longName: "", reference: "", baseFunction: qtcBztAlt)
        return qtcBzt.calculate(qt: qt, rr: rr)
    }
    
    public static func qtcAlt(qtInMsec: Double, rrInMsec: Double) -> Double {
        let qtcBzt = qtcFunction(shortName: "qtcBztAlt", longName: "", reference: "", baseFunction: qtcBztAlt)
        return qtcBzt.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
  
}

