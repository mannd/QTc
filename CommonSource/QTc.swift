//
//  QTc.swift
//  QTc
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

// Nomenclature from Rabkin and Cheng, 2015: https://www.wjgnet.com/1949-8462/full/v7/i6/315.htm#B17
public enum QTcFormula {
    case qtcBzt  // Bazett
    case qtcFrd  // Fridericia
    case qtcFrm  // Framingham
    case qtcHdg  // Hodges
    case qtcRtha // Rautaharju (2014)a
    case qtcMyd  // Mayeda
    case qtcArr  // Arrowood
    case qtcKwt  // Kawataki
    case qtcDmt  // Dimitrienko
    case qtcYos  // Yoshinaga
    case qtcBdl  // Boudoulas (note Rabkin has qtcBRL -- typo?)
    // more coming
    case qtcTest // for testing only
}

public enum QTpFormula {
    case qtpArr  // Arrowood
    case qtpBdl  // Boudoulas
    case qtpAsh  // Ashman
}

public enum FormulaClassification {
    case linear
    case rational
    case power
    case logarithmic
    case exponential
    case other
}

public enum Sex {
    case male
    case female
    case unspecified
}

typealias Age = Int
// TODO: may want to expand scope or put in QTc class,
// as formulas may need to test for unspecified age to generate error result.
fileprivate let unspecified = -1  // default value for unspecified age

// These are just to clarify return types of certain functions.
// They only used when the units aren't clear in the function prototypes.
typealias Msec = Double
typealias Sec = Double

typealias QTcEquation = (_ qt: Double, _ rr: Double, _ sex: Sex, _ age: Age) -> Double
typealias QTpEquation = (_ rr: Double, Sex, Age) -> Double

// This would be an abstract class if Swift had them.
public class BaseCalculator {
   // public static let unspecified = -1  // use when Age is unspecified
    
    public let longName: String
    public let shortName: String
    public let reference: String
    public let equation: String
    public let classification: FormulaClassification
    // true is adult or general equations, few pediatric ones will set this false
    public let forAdults: Bool
    // potentially add notes to certain formulas
    public let notes: String
    public var classificationName: String { get {
        switch classification {
        case .exponential:
            return "exponential"
        case .linear:
            return "linear"
        case .logarithmic:
            return "logarithmic"
        case .other:
            return "other"
        case .power:
            return "power"
        case .rational:
            return "rational"
        }
    }}
    
    init(longName: String, shortName: String, reference: String, equation: String,
         classification: FormulaClassification, forAdults: Bool, notes: String) {
        self.longName = longName
        self.shortName = shortName
        self.reference = reference
        self.equation = equation
        self.classification = classification
        self.forAdults = forAdults
        self.notes = notes
    }
}

public class QTcCalculator: BaseCalculator {
    let formula: QTcFormula
    let baseEquation: QTcEquation
    
    init(formula: QTcFormula, longName: String, shortName: String,
         reference: String, equation: String, baseEquation: @escaping QTcEquation,
         classification: FormulaClassification, forAdults: Bool = true, notes: String = "") {
        self.formula = formula
        self.baseEquation = baseEquation
        super.init(longName: longName, shortName: shortName,
                   reference: reference, equation: equation,
                   classification: classification, forAdults: forAdults, notes: notes)
    }
    
    func calculate(qtInSec: Double, rrInSec: Double, sex: Sex = .unspecified, age: Age = unspecified) -> Sec {
        return baseEquation(qtInSec, rrInSec, sex, age)
    }
    
    func calculate(qtInMsec: Double, rrInMsec: Double, sex: Sex = .unspecified, age: Age = unspecified) -> Msec {
        return QTc.qtcConvert(baseEquation, qtInMsec: qtInMsec, rrInMsec: rrInMsec, sex: sex, age: age)
    }
    
    func calculate(qtInSec: Double, rate: Double, sex: Sex = .unspecified, age: Age = unspecified) -> Sec {
        return QTc.qtcConvert(baseEquation, qtInSec: qtInSec, rate: rate, sex: sex, age: age)
    }
    
    func calculate(qtInMsec: Double, rate: Double, sex: Sex = .unspecified, age: Age = unspecified) -> Msec {
        return QTc.qtcConvert(baseEquation, qtInMsec: qtInMsec, rate: rate, sex: sex, age: age)
    }
}

public class QTpCalculator: BaseCalculator {
    let formula: QTpFormula
    let baseEquation: QTpEquation
    
    init(formula: QTpFormula, longName: String, shortName: String,
                  reference: String, equation: String, baseEquation: @escaping QTpEquation,
                  classification: FormulaClassification, forAdults: Bool = true, notes: String = "") {
        self.formula = formula
        self.baseEquation = baseEquation
        super.init(longName: longName, shortName: shortName,
                   reference: reference, equation: equation,
                   classification: classification, forAdults: forAdults, notes: notes)
    }
    
    func calculate(rrInSec: Double, sex: Sex = .unspecified, age: Age = unspecified) -> Sec {
        return baseEquation(rrInSec, sex, age)
    }
    
    func calculate(rrInMsec: Double, sex: Sex = .unspecified, age: Age = unspecified) -> Msec {
        return QTc.qtpConvert(baseEquation, rrInMsec: rrInMsec, sex: sex, age: age)
    }
    
    func calculate(rate: Double, sex: Sex = .unspecified, age: Age = unspecified) -> Sec {
        return QTc.qtpConvert(baseEquation, rate: rate, sex: sex, age: age)
    }
}

// These are protocols that the formula source must adhere to.
protocol QTcFormulaSource {
    static func qtcCalculator(formula: QTcFormula) -> QTcCalculator
}

protocol QTpFormulaSource {
    static func qtpCalculator(formula: QTpFormula) -> QTpCalculator
}

/// TODO: is @objc tag needed if inheritance from NSObject?
// The QTc class is not instantiated, rather it provides static functions:
//     conversion functions such as secToMsec(sec:) and factory
//     methods to generate QTc and QTp calculator classes
public class QTc: NSObject {
//    public static let unspecified = -1   // for unspecified age
  
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
    
    
    // These functions allow mocking the Formula source
    static func qtcCalculator<T: QTcFormulaSource>(formulaSource: T.Type, formula: QTcFormula) -> QTcCalculator {
        return T.qtcCalculator(formula: formula)
    }
    
    static func qtpCalculator<T: QTpFormulaSource>(formulaSource: T.Type, formula: QTpFormula) -> QTpCalculator {
        return T.qtpCalculator(formula: formula)
    }
    
    // The factories: these are called like:
    //
    //     let qtcBztCalculator = QTc.qtcCalculator(formula: .qtcBzt)
    //     let qtc = qtcBztCalculator.calculate(qtInSec: qt, rrInSec: rr)
    //     (etc.)
    //
    
    // QTc Factory
    public static func qtcCalculator(formula: QTcFormula) -> QTcCalculator {
        return qtcCalculator(formulaSource: Formulas.self, formula: formula)
    }
    
    // QTp factory
    public static func qtpCalculator(formula: QTpFormula) -> QTpCalculator {
        return qtpCalculator(formulaSource: Formulas.self, formula: formula)
    }
    
    // Convert from one set of units to another
    // QTc conversion
    fileprivate static func qtcConvert(_ qtcEquation: QTcEquation,
                                       qtInMsec: Double, rrInMsec: Double, sex: Sex, age: Age) -> Msec {
        return secToMsec(qtcEquation(msecToSec(qtInMsec), msecToSec(rrInMsec), sex, age))
    }
    
    fileprivate static func qtcConvert(_ qtcEquation: QTcEquation,
                                       qtInSec: Double, rate: Double, sex: Sex, age: Age) -> Sec {
        return qtcEquation(qtInSec, bpmToSec(rate), sex, age)
    }
    
    fileprivate static func qtcConvert(_ qtcEquation: QTcEquation,
                                       qtInMsec: Double, rate: Double, sex: Sex, age: Age) -> Msec {
        return secToMsec(qtcEquation(msecToSec(qtInMsec), bpmToSec(rate), sex, age))
    }
   
    // QTp conversion
    fileprivate static func qtpConvert(_ qtpEquation: QTpEquation, rrInMsec: Double, sex: Sex, age: Age) -> Msec {
        return secToMsec(qtpEquation(msecToSec(rrInMsec), sex, age))
    }
    
    fileprivate static func qtpConvert(_ qtpEquation: QTpEquation, rate: Double, sex: Sex, age: Age) -> Sec {
        return qtpEquation(bpmToSec(rate), sex, age)
    }
}

