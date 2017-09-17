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
    case qtcBzt  // Bazett
    case qtcFrd  // Fridericia
    case qtcFrm  // Framingham
    case qtcHdg  // Hodges
    case qtcRtha // Rautaharju (2014)a
    case qtcMyd  // Mayeda
    case qtcArr  // Arrowood
    // more coming
}

// If Swift had "protected" access we would use it here.  We do want the properties of this class
// to be accessible via QTcCalculator, but we don't want BaseCalculator to be instantialized by users.
public class BaseCalculator {
    public let formula: Formula
    public let longName: String
    public let shortName: String
    public let reference: String
    
    init(formula: Formula, longName: String, shortName: String, reference: String) {
        self.formula = formula
        self.longName = longName
        self.shortName = shortName
        self.reference = reference
    }
}

typealias qtcEquation = (Double, Double) -> Double
typealias qtpEquation = (Double) -> Double

public class QTcCalculator: BaseCalculator {
    let baseEquation: qtcEquation
    
    init(formula: Formula, longName: String, shortName: String, reference: String, baseEquation: @escaping qtcEquation) {
        self.baseEquation = baseEquation
        super.init(formula: formula, longName: longName, shortName: shortName, reference: reference)
        
    }
    
    func calculate(qtInSec: Double, rrInSec: Double) -> Double {
        return baseEquation(qtInSec, rrInSec)
    }
    
    func calculate(qtInMsec: Double, rrInMsec: Double) -> Double {
        return QTc.qtcConvert(baseEquation, qtInMsec: qtInMsec, rrInMsec: rrInMsec)
    }
    
    func calculate(qtInSec: Double, rate: Double) -> Double {
        return QTc.qtcConvert(baseEquation, qtInSec: qtInSec, rate: rate)
    }
    
    func calculate(qtInMsec: Double, rate: Double) -> Double {
        return QTc.qtcConvert(baseEquation, qtInMsec: qtInMsec, rate: rate)
    }
}

// TODO:
// class QTpCalculator {}

/// TODO: is @objc tag needed if inheritance from NSObject?
@objc public class QTc: NSObject {
   
    // Factory method that returns the calculator you ask for.
    public static func qtcCalculator(formula: Formula) -> QTcCalculator {
        var calculator: QTcCalculator
        switch formula {
        case .qtcBzt:
            calculator = QTcCalculator(formula: .qtcBzt, longName: "Bazett", shortName: "QTcBZT", reference: "Bazett HC. An analysis of the time relations of electrocardiograms. Heart 1920; 7:353-367.", baseEquation: {qtInSec, rrInSec in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.5)})
        case .qtcFrd:
            calculator = QTcCalculator(formula: .qtcFrd, longName: "Fridericia", shortName: "QTcFRM", reference: "Fridericia L. Die sytolendauer in elektrokardiogramm bei normalen menschen und bei herzkranken. Acta Med Scand. 1920;53:469-486.", baseEquation: {qtInSec, rrInSec in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 1 / 3.0)})
        case .qtcMyd:
            calculator = QTcCalculator(formula: .qtcMyd, longName: "Mayeda", shortName: "QTcMYD", reference: "Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Sch Med Univ Imp. 1934;17:53-55.", baseEquation: {qtInSec, rrInSec in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.604)})
        case .qtcFrm:
        calculator = QTcCalculator(formula: .qtcFrm, longName: "Framingham (Sagie)", shortName: "QTcFRM", reference: "Sagie A, Larson MG, Goldberg RJ, Bengtson JR, Levy D. An improved method for adjusting the QT interval for heart rate (the Framingham Heart Study). Am J Cardiol. 1992;70:797-801.", baseEquation: {qtInSec, rrInSec in qtcLinear(qtInSec: qtInSec, rrInSec: rrInSec, alpha: 0.154)})
        case .qtcHdg:
            calculator = QTcCalculator(formula: .qtcHdg, longName: "Hodges", shortName: "QTcHDG", reference: "Hodges M, Salerno D, Erlien D. Bazett’s QT correction reviewed: Evidence that a linear QT correction for heart rate is better. J Am Coll Cardiol. 1983;1:1983.", baseEquation: {qtInSec, rrInSec in qtInSec + 0.00175 * (secToBpm(rrInSec) - 60)})
        case .qtcRtha:
            calculator = QTcCalculator(formula: .qtcRtha, longName: "Rautaharju (2014)a", shortName: "QTcRTHa", reference: "Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. Int J Cardiol. 2014;174:535-540.", baseEquation: {qtInSec, rrInSec in qtInSec * (120.0 + secToBpm(rrInSec)) / 180.0})
        case .qtcArr:
            calculator = QTcCalculator(formula: .qtcArr, longName: "Arrowood", shortName: "QTcARR", reference: "Arrowood JA, Kline J, Simpson PM, Quigg RJ, Pippin JJ, Nixon JV, Mohrnty PK.  Modulation of the QT interval: effects of graded exercise and reflex cardiovascular stimulation.  J Appl Physiol. 1993;75:2217-2223.", baseEquation: {qtInSec, rrInSec in qtInSec + 0.304 - 0.492 * exp(-0.008 * secToBpm(rrInSec))})
        }
        return calculator
    }
  
    // Static conversion functions
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
    
    public static func qtcConvert(_ qtcFunction: (Double, Double) -> Double,
                                     qtInSec: Double, rate: Double) -> Double {
        return qtcFunction(qtInSec, bpmToSec(rate))
    }
    
    public static func qtcConvert(_ qtcFunction: (Double, Double) -> Double,
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

}

