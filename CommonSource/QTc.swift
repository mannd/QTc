//
//  QTc.swift
//  QTc
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017, 2018 EP Studios. All rights reserved.
//

// TODO: Change target version back down to 10.10 for QTc and EP Calipers for Mac
import Foundation

// Nomenclature from Rabkin and Cheng, 2015: https://www.wjgnet.com/1949-8462/full/v7/i6/315.htm#B17
/// enum listing QTc and QTp formulas
public enum Formula {
    // QTc formulas
    case qtcBzt  // Bazett
    case qtcFrd  // Fridericia
    case qtcFrm  // Framingham
    case qtcHdg  // Hodges
    case qtcRtha // Rautaharju (2014) QTcMod
    case qtcRthb // Rautaharju (2014) QTcLogLin
    case qtcMyd  // Mayeda
    case qtcArr  // Arrowood
    case qtcKwt  // Kawataki
    case qtcDmt  // Dimitrienko
    case qtcYos  // Yoshinaga
    case qtcBdl  // Boudoulas (note Rabkin has qtcBRL -- typo?)
    case qtcAdm  // Adams
    case qtcTest // for testing only
    
    // QTp formulas
    case qtpBzt  // Bazett
    case qtpFrd  // Fridericia
    case qtpArr  // Arrowood
    case qtpBdl  // Boudoulas
    case qtpAsh  // Ashman
    case qtpHdg  // Hodges
    
    public func formulaType() -> FormulaType {
        let qtcFormulas: Set<Formula> = [.qtcBzt, .qtcFrd, .qtcFrm, .qtcHdg, .qtcRtha, .qtcRthb, .qtcMyd,
                                         .qtcArr, .qtcKwt, .qtcDmt, .qtcYos, .qtcBdl, .qtcAdm]
        let qtpFormulas: Set<Formula> = [.qtpBzt, .qtpFrd, .qtpArr, .qtpBdl, .qtpAsh, .qtpHdg]
        if qtcFormulas.contains(self) {
            return .qtc
        } else if qtpFormulas.contains(self) {
            return .qtp
        } else {
            fatalError("Undefined formula")
        }
    }
}

/// enum indicating if a Formula is a QTc or QTp
public enum FormulaType {
    case qtc
    case qtp
}


// TODO: localize strings, and ensure localization works when used as a Pod
// See https://medium.com/@shenghuawu/localization-cocoapods-5d1e9f34f6e6 and
// http://yannickloriot.com/2014/02/cocoapods-and-the-localized-string-files/

/// Mathematical classification of formula
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

/// These error codes can be thrown by certain formulas when parameters don't apply
public enum CalculationError: Error {
    case heartRateOutOfRange
    case ageOutOfRange
    case ageRequired
    case sexRequired
    case wrongSex
    case qtOutOfRange
    case qtMissing
    case unspecified
    case undefinedFormula
}

public typealias Age = Int?

/// These are just to clarify return types of certain functions.
/// They are only used when the units aren't clear in the function prototypes.
public typealias Msec = Double
public typealias Sec = Double

typealias QTcEquation = (_ qt: Double, _ rr: Double, _ sex: Sex, _ age: Age) throws -> Double
typealias QTpEquation = (_ rr: Double, Sex, Age) throws -> Double

/// For backward compatibility
public typealias BaseCalculator = Calculator

/// This class is meant to be overriden.  Do not instantiate a Calculator, just its subclasses.
public class Calculator {
    public var formula: Formula
    public let longName: String
    public let shortName: String
    public let reference: String
    public let equation: String
    public let classification: FormulaClassification
    // potentially add notes to certain formulas
    public let notes: String
    public var numberOfSubjects: Int?
    public var publicationDate: String? { get {
        if let date = date {
            return formatter.string(from: date)
        }
        return nil
        }}
    private let date: Date?
    private let formatter = DateFormatter()
    
    init(longName: String, shortName: String, reference: String, equation: String,
         classification: FormulaClassification, notes: String,
         publicationDate: String?, numberOfSubjects: Int?) {
        
        self.formula = .qtcBzt  // arbitrary initiation, always overriden,
                                // but can avoid formula as optional
        self.longName = longName
        self.shortName = shortName
        self.reference = reference
        self.equation = equation
        self.classification = classification
        self.notes = notes
        formatter.dateFormat = "yyyy"
        if let publicationDate = publicationDate {
            date = formatter.date(from: publicationDate)
        }
        else {
            date = nil
        }
        self.numberOfSubjects = numberOfSubjects
    }
    
    /// base class func, meant to be overriden
    public func calculate(qtMeasurement: QtMeasurement) throws -> Double {
        assertionFailure("Base class Calculator.calculate() must be overriden.")
        return 0
    }
}

/// class containing all aspects of a QTc calculator
public class QTcCalculator: Calculator {
    let baseEquation: QTcEquation
    
    init(formula: Formula, longName: String, shortName: String,
         reference: String, equation: String, baseEquation: @escaping QTcEquation,
         classification: FormulaClassification, forAdults: Bool = true, notes: String = "",
         publicationDate: String? = nil, numberOfSubjects: Int? = nil) {
        
        self.baseEquation = baseEquation
        super.init(longName: longName, shortName: shortName,
                   reference: reference, equation: equation,
                   classification: classification,
                   notes: notes, publicationDate: publicationDate,
                   numberOfSubjects: numberOfSubjects)
        self.formula = formula
    }
    
    public func calculate(qtInSec: Double, rrInSec: Double, sex: Sex = .unspecified, age: Age = nil) throws -> Sec {
        return try baseEquation(qtInSec, rrInSec, sex, age)
    }
    
    public func calculate(qtInMsec: Double, rrInMsec: Double, sex: Sex = .unspecified, age: Age = nil) throws -> Msec {
        return try QTc.qtcConvert(baseEquation, qtInMsec: qtInMsec, rrInMsec: rrInMsec, sex: sex, age: age)
    }
    
    public func calculate(qtInSec: Double, rate: Double, sex: Sex = .unspecified, age: Age = nil) throws -> Sec {
        return try QTc.qtcConvert(baseEquation, qtInSec: qtInSec, rate: rate, sex: sex, age: age)
    }
    
    public func calculate(qtInMsec: Double, rate: Double, sex: Sex = .unspecified, age: Age = nil) throws -> Msec {
        return try QTc.qtcConvert(baseEquation, qtInMsec: qtInMsec, rate: rate, sex: sex, age: age)
    }
    
    override public func calculate(qtMeasurement: QtMeasurement) throws -> Double {
        return try calculate(qt: qtMeasurement.qt, intervalRate: qtMeasurement.intervalRate,
                             intervalRateType: qtMeasurement.intervalRateType, sex: qtMeasurement.sex,
                             age: qtMeasurement.age, units: qtMeasurement.units)
    }
    
    public func calculate(qt: Double?, intervalRate: Double, intervalRateType: IntervalRateType,
                   sex: Sex, age: Age, units: Units) throws -> Double {
        guard let qt = qt else { throw CalculationError.qtMissing }
        var result: Double
        switch units {
        case .msec:
            if intervalRateType == .interval {
                result = try calculate(qtInMsec: qt, rrInMsec: intervalRate, sex: sex, age: age)
            }
            else {
                result = try calculate(qtInMsec: qt, rate: intervalRate, sex: sex, age: age)
            }
        case .sec:
            if intervalRateType == .interval {
                result = try calculate(qtInSec: qt, rrInSec: intervalRate, sex: sex, age: age)
            }
            else {
                result = try calculate(qtInSec: qt, rate: intervalRate, sex: sex, age: age)
            }
        }
        return result
    }
    
}

/// class containing all aspects of a QTp calculator
public class QTpCalculator: Calculator {
    let baseEquation: QTpEquation
    
    init(formula: Formula, longName: String, shortName: String,
                  reference: String, equation: String, baseEquation: @escaping QTpEquation,
                  classification: FormulaClassification, forAdults: Bool = true, notes: String = "", publicationDate: String?  = nil, numberOfSubjects: Int? = nil) {
        self.baseEquation = baseEquation
        super.init(longName: longName, shortName: shortName,
                   reference: reference, equation: equation,
                   classification: classification,
                   notes: notes, publicationDate: publicationDate,
                   numberOfSubjects: numberOfSubjects)
        self.formula = formula
    }
    
    public func calculate(rrInSec: Double, sex: Sex = .unspecified, age: Age = nil) throws -> Sec {
        return try baseEquation(rrInSec, sex, age)
    }
    
    public func calculate(rrInMsec: Double, sex: Sex = .unspecified, age: Age = nil) throws -> Msec {
        return try QTc.qtpConvert(baseEquation, rrInMsec: rrInMsec, sex: sex, age: age)
    }
    
    public func calculate(rate: Double, sex: Sex = .unspecified, age: Age = nil) throws -> Sec {
        return try QTc.qtpConvert(baseEquation, rate: rate, sex: sex, age: age)
    }
    
    override public func calculate(qtMeasurement: QtMeasurement) throws -> Double {
        return try calculate(intervalRate: qtMeasurement.intervalRate,
                             intervalRateType: qtMeasurement.intervalRateType, sex: qtMeasurement.sex,
                             age: qtMeasurement.age, units: qtMeasurement.units)
    }
    
    func calculate(intervalRate: Double, intervalRateType: IntervalRateType,
                   sex: Sex, age: Age, units: Units) throws -> Double {
        var result: Double
        switch units {
        case .msec:
            if intervalRateType == .interval {
                result = try calculate(rrInMsec: intervalRate, sex: sex, age: age)
            }
            else {
                result = try calculate(rate: intervalRate, sex: sex, age: age)
                // be true to the units passed, and return result in msec
                result = QTc.secToMsec(result)
            }
        case .sec:
            if intervalRateType == .interval {
                result = try calculate(rrInSec: intervalRate, sex: sex, age: age)
            }
            else {
                result = try calculate(rate: intervalRate, sex: sex, age: age)
            }
        }
        return result
    }
}

// These are protocols that the formula source must adhere to.
protocol QTcFormulaSource {
    static func qtcCalculator(formula: Formula) -> QTcCalculator
}

protocol QTpFormulaSource {
    static func qtpCalculator(formula: Formula) -> QTpCalculator
}

/// The QTc class provides static functions:
///  conversion functions such as secToMsec(sec:) and factory
///  methods to generate QTc and QTp calculator classes
public class QTc {
    // QTc class is not to be instantiated.
    private init() {}
    
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
    static func qtcCalculator<T: QTcFormulaSource>(formulaSource: T.Type, formula: Formula) -> QTcCalculator {
        return T.qtcCalculator(formula: formula)
    }
    
    static func qtpCalculator<T: QTpFormulaSource>(formulaSource: T.Type, formula: Formula) -> QTpCalculator {
        return T.qtpCalculator(formula: formula)
    }
    
    /// Specific factories: these are called like:
    ///
    ///     let qtcBztCalculator = QTc.qtcCalculator(formula: .qtcBzt)
    ///     let qtc = qtcBztCalculator.calculate(qtInSec: qt, rrInSec: rr)
    ///     (etc.)
    
    /// QTc Factory.  Returns a QTcCalculator.
    public static func qtcCalculator(formula: Formula) -> QTcCalculator {
        return qtcCalculator(formulaSource: Formulas.self, formula: formula)
    }
    
    /// QTp factory.  Returns a QTpCalculator.
    public static func qtpCalculator(formula: Formula) -> QTpCalculator {
        return qtpCalculator(formulaSource: Formulas.self, formula: formula)
    }
    
    
    /// Generic Calculator factory
    public static func calculator(formula: Formula, formulaType: FormulaType) -> Calculator {
        switch formulaType {
        case .qtc:
            return qtcCalculator(formula: formula)
        case .qtp:
            return qtpCalculator(formula: formula)
        }
    }
    
    /// Generic calculator factory, called like this:
    ///
    ///      let calculator = QTc.calculator(formula: .qtcBzt)
    ///      let measruement = QtMeasurement(.....)  // init a QtMeasurement struct
    ///      let result = calculator.calculate(measurement: measurement)
    public static func calculator(formula: Formula) -> Calculator {
        return calculator(formula: formula, formulaType: formula.formulaType())
    }
    
    // Convert from one set of units to another
    // QTc conversion
    fileprivate static func qtcConvert(_ qtcEquation: QTcEquation,
                                       qtInMsec: Double, rrInMsec: Double, sex: Sex, age: Age) throws -> Msec {
        return secToMsec(try qtcEquation(msecToSec(qtInMsec), msecToSec(rrInMsec), sex, age))
    }
    
    fileprivate static func qtcConvert(_ qtcEquation: QTcEquation,
                                       qtInSec: Double, rate: Double, sex: Sex, age: Age) throws -> Sec {
        return try qtcEquation(qtInSec, bpmToSec(rate), sex, age)
    }
    
    fileprivate static func qtcConvert(_ qtcEquation: QTcEquation,
                                       qtInMsec: Double, rate: Double, sex: Sex, age: Age) throws -> Msec {
        return secToMsec(try qtcEquation(msecToSec(qtInMsec), bpmToSec(rate), sex, age))
    }
   
    // QTp conversion
    fileprivate static func qtpConvert(_ qtpEquation: QTpEquation, rrInMsec: Double, sex: Sex, age: Age) throws -> Msec {
        return secToMsec(try qtpEquation(msecToSec(rrInMsec), sex, age))
    }
    
    fileprivate static func qtpConvert(_ qtpEquation: QTpEquation, rate: Double, sex: Sex, age: Age) throws -> Sec {
        return try qtpEquation(bpmToSec(rate), sex, age)
    }
}

