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
    // more coming
}

public enum QTpFormula {
    case qtpArr
}

public enum FormulaClassification {
    case linear
    case rational
    case power
    case logarithmic
    case exponential
    case other
}

// If Swift had "protected" access we would use it here.  We do want the properties of this class
// to be accessible via QTcCalculator, but we don't want BaseCalculator to be instantialized by users.
public class BaseCalculator {
    public let longName: String
    public let shortName: String
    public let reference: String
    public let equation: String
    public let classification: FormulaClassification
    // true is adult or general equations, few pediatric ones will set this false
    public let forAdults: Bool
    // potentially add notes to certain formulas
    public let notes: String
    
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

typealias qtcEquation = (Double, Double) -> Double
typealias qtpEquation = (Double) -> Double

public class QTcCalculator: BaseCalculator {
    let formula: QTcFormula
    let baseEquation: qtcEquation
    
    init(formula: QTcFormula, longName: String, shortName: String,
         reference: String, equation: String, baseEquation: @escaping qtcEquation,
         classification: FormulaClassification, forAdults: Bool = true, notes: String = "") {
        self.formula = formula
        self.baseEquation = baseEquation
        super.init(longName: longName, shortName: shortName,
                   reference: reference, equation: equation,
                   classification: classification, forAdults: forAdults, notes: notes)
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

public class QTpCalculator: BaseCalculator {
    let formula: QTpFormula
    let baseEquation: qtpEquation
    
    init(formula: QTpFormula, longName: String, shortName: String,
                  reference: String, equation: String, baseEquation: @escaping qtpEquation,
                  classification: FormulaClassification, forAdults: Bool = true, notes: String = "") {
        self.formula = formula
        self.baseEquation = baseEquation
        super.init(longName: longName, shortName: shortName,
                   reference: reference, equation: equation,
                   classification: classification, forAdults: forAdults, notes: notes)
    }
    
    func calculate(rrInSec: Double) -> Double {
        return baseEquation(rrInSec)
    }
    
    func calculate(rrInMsec: Double) -> Double {
        return QTc.qtpConvert(baseEquation, rrInMsec: rrInMsec)
    }
    
    func calculate(rate: Double) -> Double {
        return QTc.qtpConvert(baseEquation, rate: rate)
    }
}

protocol QTcFormulaSource {
    static func qtcCalculator(formula: QTcFormula) -> QTcCalculator
}

protocol QTpFormulaSource {
    static func qtpCalculator(formula: QTpFormula) -> QTpCalculator
}

/// TODO: is @objc tag needed if inheritance from NSObject?
public class QTc: NSObject {
  
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
    
    
    // add seams here for unit testing
    static func qtcCalculator<T: QTcFormulaSource>(formulaSource: T.Type, formula: QTcFormula) -> QTcCalculator {
        return T.qtcCalculator(formula: formula)
    }
    
    static func qtpCalculator<T: QTpFormulaSource>(formulaSource: T.Type, formula: QTpFormula) -> QTpCalculator {
        return T.qtpCalculator(formula: formula)
    }
    
    
    // Factory method that returns the calculator you ask for.
    public static func qtcCalculator(formula: QTcFormula) -> QTcCalculator {
        return qtcCalculator(formulaSource: Formulas.self, formula: formula)
    }
    
    // QTp factory
    public static func qtpCalculator(formula: QTpFormula) -> QTpCalculator {
        return qtpCalculator(formulaSource: Formulas.self, formula: formula)
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
    public static func qtpConvert(_ qtpFunction: (Double) -> Double, rrInMsec: Double) -> Double {
        return secToMsec(qtpFunction(msecToSec(rrInMsec)))
    }
    
    // returns QTp in seconds!
    public static func qtpConvert(_ qtpFunction: (Double) -> Double, rate: Double) -> Double {
        return qtpFunction(bpmToSec(rate))
    }

}

