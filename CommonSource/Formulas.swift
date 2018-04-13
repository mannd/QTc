//
//  Formulas.swift
//  Formulas
//
//  Created by David Mann on 9/18/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

struct Formulas: QTcFormulaSource, QTpFormulaSource {
    
    static let errorMessage = "Formula not found!"
    
    // These 4 functions are required by the protocols used by this class
    static func qtcCalculator(formula: Formula) -> QTcCalculator {
        guard let calculator = qtcDictionary[formula] else {
            fatalError(errorMessage)
        }
        return calculator
    }
    
    static func qtpCalculator(formula: Formula) -> QTpCalculator {
        guard let calculator = qtpDictionary[formula] else {
            fatalError(errorMessage)
        }
        return calculator
    }
    
    // Power QTc formula function
    // These have form QTc = QT / pow(RR, exp)
    private static func qtcExp(qtInSec: Double, rrInSec: Double, exp: Double) -> Sec {
        return qtInSec / pow(rrInSec, exp)
    }
    
    // Linear QTc formula function
    // These have form QTc = QT + α(1 - RR)
    private static func qtcLinear(qtInSec: Double, rrInSec: Double, alpha: Double) -> Sec {
        return qtInSec + alpha * (1 - rrInSec)
    }
    
    // Some complex formulae easier to present here than as closure
    private static func qtcAdm(qtInSec: Double, rrInSec: Double, sex: Sex, age: Age) -> Sec {
        var alpha: Double
        switch sex {
        case .unspecified:
            alpha = 0.1464
        case .male:
            alpha = 0.1536
        case .female:
            alpha = 0.1259
        }
        return qtcLinear(qtInSec: qtInSec, rrInSec: rrInSec, alpha: alpha)
    }
    
    private static func qtpAsh(rrInSec: Double, sex: Sex, age: Age) throws -> Sec {
        // TODO: This formula has gaps in the paper's abstract, need full text of reference!
        // These gaps are "papered over" here.
        guard let age = age else { throw CalculationError.ageRequired }
        let k = 0.07
        var K: Double = 0
        if sex == .male {
            if age < 45 {
                K = 0.375
            }
            else {
                K = 0.380
            }
        }
        else {  // female
            if age < 15 {
                K = 0.375
            }
            else if age <= 32 {
                K = 0.385
            }
            else {
                K = 0.390
            }
        }
        return K * log10(10 * (rrInSec + k))
    }
    
    // This is the data source for the formulas.  Potentially this could be a database, but there
    // aren't that many formulas, so for now the formulas are inlined here.
    static let qtcDictionary: [Formula : QTcCalculator] =
        [.qtcBzt:
            QTcCalculator(formula: .qtcBzt,
                          longName: "Bazett",
                          shortName: "QTcBZT",
                          reference: "original: Bazett HC. An analysis of the time-relations of electrocardiograms. Heart 1920;7:353–370.\nreprint: Bazett H. C. An analysis of the time‐relations of electrocardiograms. Annals of Noninvasive Electrocardiology. 2006;2(2):177-194. doi:10.1111/j.1542-474X.1997.tb00325.x",
                          equation: "QT/RR^0.5",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.5)},
                          classification: .power,
                          notes: "Oldest, most commonly used formula, but inaccurate at extremes of heart rate.  Healthy subjects: 20 men, age 14 - 40 (including one with age labeled \"Boy\"), 19 women, age 20 - 53.  Majority of subjects in their 20s.",
                          publicationDate: "1920",
                          numberOfSubjects: 39),
         .qtcFrd:
            QTcCalculator(formula: .qtcFrd,
                          longName: "Fridericia",
                          shortName: "QTcFRM",
                          reference: "Fridericia LS. Die Systolendauer im Elektrokardiogramm bei normalen Menschen und bei Herzkranken. Acta Medica Scandinavica. 1920;53(1):469-486. doi:10.1111/j.0954-6820.1920.tb18266.x",
                          equation: "QT/RR^(1/3)",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 1 / 3.0)},
                          classification: .power,
                          notes: "50 normal subjects, 28 men, 22 women, ages 2 to 81, most (35) age 20 to 40.  HR range 51-135.",
                          publicationDate: "1920",
                          numberOfSubjects: 50),
         .qtcMyd:
            QTcCalculator(formula: .qtcMyd,
                          longName: "Mayeda",
                          shortName: "QTcMYD",
                          reference: "Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Sch Med Univ Imp. 1934;17:53-55.",
                          equation: "QT/RR^0.604",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.604)},
                          classification: .power,
                          publicationDate: "1934"),
         .qtcFrm:
            QTcCalculator(formula: .qtcFrm,
                          longName: "Framingham",
                          shortName: "QTcFRM",
                          reference: "Sagie A, Larson MG, Goldberg RJ, Bengtson JR, Levy D. An improved method for adjusting the QT interval for heart rate (the Framingham Heart Study). American Journal of Cardiology. 1992;70(7):797-801. doi:10.1016/0002-9149(92)90562-D",
                          equation: "QT + 0.154*(1-RR)",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcLinear(qtInSec: qtInSec, rrInSec: rrInSec, alpha: 0.154)},
                          classification: .linear,
                          notes: "5,018 subjects, 2,239 men and 2,779 women, from Framingham Heart Study.  Mean age 44 years (28-62). CAD, subjects on AADs or tricyclics or with extremes of HR excluded.",
                          publicationDate: "1992",
                          numberOfSubjects: 5018),
         .qtcHdg:
            QTcCalculator(formula: .qtcHdg,
                          longName: "Hodges",
                          shortName: "QTcHDG",
                          reference: "Hodges M, Salerno D, Erlien D. Bazett’s QT correction reviewed: Evidence that a linear QT correction for heart rate is better. J Am Coll Cardiol. 1983;1:1983.",
                          equation: "QT + 1.75*(HR-60)",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec + 0.00175 * (QTc.secToBpm(rrInSec) - 60)},
                          classification: .rational,
                          notes: "607 normal subjects, 303 men, 304 women, ages from 20s to 80s.",
                          publicationDate: "1983",
                          numberOfSubjects: 607),
         .qtcRtha:
            QTcCalculator(formula: .qtcRtha,
                          longName: "Rautaharju QTcMod",
                          shortName: "QTcRTHa",
                          reference: "Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. International Journal of Cardiology. 2014;174(3):535-540. doi:10.1016/j.ijcard.2014.04.133",
                          equation: "QT * (120 + HR) /180",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec * (120.0 + QTc.secToBpm(rrInSec)) / 180.0},
                          classification: .rational,
                          notes: "Healthy subjects: 57,595, aged 5-89 years, 54% women.\nAbnormal QTc: age < 40: 430 ms for men, 440 ms for women; age 40-69: 440 ms for men, 450 ms for women, age ≥ 70: 455 ms for men, 460 ms for women.",
                          publicationDate: "2014"),
         // TODO: Add tests for .qtcRthb
         .qtcRthb:
            QTcCalculator(formula: .qtcRthb,
                          longName: "Rautaharju QTcLogLin",
                          shortName: "QTcRTHb",
                          // TODO: extract common strings like references
                          reference: "Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. International Journal of Cardiology. 2014;174(3):535-540. doi:10.1016/j.ijcard.2014.04.133",
                          equation: "QTc = QT + 387 * (1 - RR^0.37) for men\nQTc = QT + 409 * (1 - RR^0.39) for women",
                          baseEquation: {qtInSec, rrInSec, sex, age in
                            let C: Double
                            let k: Double
                            switch(sex) {
                            case .male:
                                C = 387.0
                                k = 0.37
                            case .female:
                                C = 409.0
                                k = 0.39
                            case .unspecified:
                                throw CalculationError.sexRequired
                            }
                            return QTc.msecToSec(QTc.secToMsec(qtInSec) + C * (1 - pow(rrInSec, k)))},
                          classification: .power,
                          notes: "Healthy subjects: 57,595, aged 5-89 years, 54% women.\nAbnormal QTc: age < 40: 430 ms for men, 440 ms for women; age 40-69: 440 ms for men, 450 ms for women, age ≥ 70: 455 ms for men, 460 ms for women.",
                          publicationDate: "2014"),
         .qtcArr:
            QTcCalculator(formula: .qtcArr,
                          longName: "Arrowood",
                          shortName: "QTcARR",
                          reference: "Arrowood JA, Kline J, Simpson PM, Quigg RJ, Pippin JJ, Nixon JV, Mohrnty PK.  Modulation of the QT interval: effects of graded exercise and reflex cardiovascular stimulation.  J Appl Physiol. 1993;75:2217-2223.",
                          equation: "QT + 0.304 - 0.492*e^(-0.008*HR)",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec + 0.304 - 0.492 * exp(-0.008 * QTc.secToBpm(rrInSec))},
                          classification: .other,
                          publicationDate: "1993"),
         .qtcKwt:
            QTcCalculator(formula: .qtcKwt,
                          longName: "Kawataki",
                          shortName: "QTcKWT",
                          reference: "Kawataki M, Kashima T, Toda H, Tanaka H. Relation between QT interval and heart rate. applications and limitations of Bazett’s formula. J Electrocardiol. 1984;17:371-375.",
                          equation: "QT/RR^0.25",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.25)},
                          classification: .power,
                          publicationDate: "1984"),
         .qtcDmt:
            QTcCalculator(formula: .qtcDmt,
                          longName: "Dimitrienko",
                          shortName: "QTcDMT",
                          reference: "Dmitrienke AA, Sides GD, Winters KJ, et al. Electrocardiogram Reference Ranges Derived from a Standardized Clinical Trial Population. Drug Information Journal. 2005;39(4):395-405. doi:10.1177/009286150503900408",
                          equation: "QT/RR^0.413",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.413)},
                          classification: .power,
                          notes: "Healthy subjects: 13,039, aged 4-99 years, 51% women.",
                          publicationDate: "2005",
                          numberOfSubjects: 13039),
         .qtcYos:
            QTcCalculator(formula: .qtcYos,
                          longName: "Yoshinaga",
                          shortName: "QTcYOS",
                          reference: "Yoshinaga M, Tomari T, Aihoshi S, et al.  Exponential correction of QT interval to minimize the effect of the heart rate in children.  Jpn Circ J.  1993;57:102-108.",
                          equation: "QT/RR^0.31",
                          baseEquation: {qtInSec, rrInSec, sex, age in
                            guard let age = age else { throw CalculationError.ageRequired }
                            guard age <= 18 else { throw CalculationError.ageOutOfRange }
                            return qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.31)},
                          classification: .power,
                          notes: "Children",
                          publicationDate: "1993"),
         .qtcAdm:
            QTcCalculator(formula: .qtcAdm,
                          longName: "Adams",
                          shortName: "QTcADM",
                          reference: "Adams W. The normal duration of the electrocardiographic ventricular complex. J Clin Invest. 1936;15:335-342.",
                          equation: "QT + 0.1464(1-RR) (all subjects)\nQT + 0.1536(1-RR) (males)\nQT + 0.1259(1-RR) (females)",
                          baseEquation: qtcAdm,
                          classification: .linear,
                          notes: "Gender-based formula",
                          publicationDate: "1936"),
         // Add new equations above
         .qtcTest:
            QTcCalculator(formula: .qtcTest,
                          longName: "Test",
                          shortName: "QTcTEST",
                          reference: "TBD",
                          equation: "uses sex",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec + rrInSec},
                          classification: .power,
                          notes: "Children",
                          publicationDate: "1800")
    ]
    
    // We avoid duplicate fields in the QTp formulas by reusing some of the QTc equivalent fields
    static let qtpDictionary: [Formula: QTpCalculator] =
        [.qtpBzt:
            QTpCalculator(formula: .qtpBzt,
                          longName: QTc.qtcCalculator(formula: .qtcBzt).longName,
                          shortName: "QTpBZT",
                          reference: QTc.qtcCalculator(formula: .qtcBzt).reference,
                          equation: "K * RR^0.5, where K = 0.37 for men and 0.40 for women",
                          baseEquation: { rrInSec,sex,age  in
                            let k: Double
                            switch(sex) {
                            case .male:
                                k = 0.37
                            case .female:
                                k = 0.4
                            case .unspecified:
                                throw CalculationError.sexRequired
                            }
                            return k * pow(rrInSec, 0.5) },
                          classification: QTc.qtcCalculator(formula: .qtcBzt).classification,
                          notes: QTc.qtcCalculator(formula: .qtcBzt).notes,
                          publicationDate: QTc.qtcCalculator(formula: .qtcBzt).publicationDate,
                          numberOfSubjects: QTc.qtcCalculator(formula: .qtcBzt).numberOfSubjects),
         .qtpArr:
            QTpCalculator(formula: .qtpArr,
                          longName: QTc.qtcCalculator(formula: .qtcArr).longName,
                          shortName: "QTpARR",
                          reference: QTc.qtcCalculator(formula: .qtcArr).reference,
                          equation: "0.12 + 0.492e^(-0.008*HR)",
                          baseEquation: {rrInSec,sex,age  in 0.12 + 0.492 * exp(-0.008 * QTc.secToBpm(rrInSec))},
                          classification: QTc.qtcCalculator(formula: .qtcArr).classification,
                          publicationDate: QTc.qtcCalculator(formula: .qtcArr).publicationDate),
         .qtpBdl:
            QTpCalculator(formula: .qtpBdl,
                          longName: "Boudoulas",
                          shortName: "QTpBDL",
                          reference: "Boudoulas H, Geleris P, Lewis RP, Rittgers SE.  Linear relationship between electrical systole, mechanical systole, and heart rate.  Chest 1981;80:613-617.",
                          equation: "Males: QT = 0.521 - 2.0*HR; Females: QT = 0.511 - 1.8*HR'",
                          baseEquation: {rrInSec, sex, age  in sex == .male ? QTc.msecToSec(521.0 - 2.0 * QTc.secToBpm(rrInSec)) : QTc.msecToSec(511.0 - 1.8 * QTc.secToBpm(rrInSec))},
                          classification: .rational,
                          publicationDate: "1981"),
         .qtpAsh:
            QTpCalculator(formula: .qtpAsh,
                          longName: "Ashman", shortName: "QTpASH", reference: "Ashman r.  The normal duration of the Q-T interval.  Am Heart J 1942;23:522-534.", equation: "QT = K log[10(RR + k)], K and k sex and age dependent'", baseEquation: qtpAsh,
                          classification: .logarithmic,
                          publicationDate: "1942"),
         .qtpHdg:
            QTpCalculator(formula: .qtpHdg,
                          longName: QTc.qtcCalculator(formula: .qtcHdg).longName,
                          shortName: "QTpHDG",
                          reference: QTc.qtcCalculator(formula: .qtcHdg).reference,
                          equation: "QT = 496 - (1.75 * HR)",
                          baseEquation: {rrInSec,sex,age in 0.496 - (0.00175 * QTc.secToBpm(rrInSec))},
                          classification: QTc.qtcCalculator(formula: .qtcHdg).classification,
                          publicationDate: QTc.qtcCalculator(formula: .qtcHdg).publicationDate,
                          numberOfSubjects: QTc.qtcCalculator(formula: .qtcHdg).numberOfSubjects),
         .qtpFrd:
           QTpCalculator(formula: .qtpFrd,
                         longName: QTc.qtcCalculator(formula: .qtcFrd).longName,
                         shortName: "QTpFRD",
                         reference: QTc.qtcCalculator(formula: .qtcFrd).reference,
                         equation: "QT = 0.763077204245941 * RR^(1/3)",
                         baseEquation: {rrInSec, sex, age in (8.22 / 100) * pow(100 * rrInSec, 1/3)},
                         classification: .power,
                         notes: "test",
                         publicationDate: "1920",
                         numberOfSubjects: QTc.qtcCalculator(formula: .qtcFrd).numberOfSubjects)
    ]
}
