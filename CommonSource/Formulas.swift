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
    static func qtcCalculator(formula: QTcFormula) -> QTcCalculator {
        guard let calculator = qtcDictionary[formula] else {
            fatalError(errorMessage)
        }
        return calculator
    }
    
    static func qtpCalculator(formula: QTpFormula) -> QTpCalculator {
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
    private static func qtpAsh(rrInSec: Double, sex: Sex, age: Age) -> Sec {
        // TODO: This formula has gaps in the paper's abstract, need full text of reference!
        // These gaps are "papered over" here.
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
  
    // From http://www.sciencedirect.com/sdfe/pdf/download/eid/1-s2.0-0002870349908534/first-page-pdf
//    One of the simplest is that devised by Bazett, namely, Q-T= k d/R-R, where k is a constant and R-R is the interval between two suc- cessive R waves.3 Bazett pointed out that k is the same in men and children, but longer in women, and described the constant as 0.37 for men and children and 0.40 for women.
    private static func qtpBzt(rrInSec: Double, sex: Sex, age: Age) -> Sec {
        // TODO: fill in with above info
        return 1.0
    }
    
    // This is the data source for the formulas.  Potentially this could be a database, but there
    // aren't that many formulas, so for now the formulas are inlined here.
    static let qtcDictionary: [QTcFormula : QTcCalculator] =
        [.qtcBzt:
            QTcCalculator(formula: .qtcBzt,
                          longName: "Bazett",
                          shortName: "QTcBZT",
                          reference: "Bazett HC. An analysis of the time relations of electrocardiograms. Heart 1920; 7:353-367.",
                          equation: "QT/RR^0.5",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.5)},
                          classification: .power,
                          notes: "Oldest, most common formula, but inaccurate at extremes of heart rate"),
         .qtcFrd:
            QTcCalculator(formula: .qtcFrd,
                          longName: "Fridericia",
                          shortName: "QTcFRM",
                          reference: "Fridericia L. Die sytolendauer in elektrokardiogramm bei normalen menschen und bei herzkranken. Acta Med Scand. 1920;53:469-486.",
                          equation: "QT/RR^0.333",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 1 / 3.0)},
                          classification: .power),
         .qtcMyd:
            QTcCalculator(formula: .qtcMyd,
                          longName: "Mayeda",
                          shortName: "QTcMYD",
                          reference: "Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Sch Med Univ Imp. 1934;17:53-55.",
                          equation: "QT/RR^0.604",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.604)},
                          classification: .power),
         .qtcFrm:
            QTcCalculator(formula: .qtcFrm,
                          longName: "Framingham (Sagie)",
                          shortName: "QTcFRM",
                          reference: "Sagie A, Larson MG, Goldberg RJ, Bengtson JR, Levy D. An improved method for adjusting the QT interval for heart rate (the Framingham Heart Study),. Am J Cardiol. 1992;70:797-801.",
                          equation: "QT + 0.154*(1-RR)",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcLinear(qtInSec: qtInSec, rrInSec: rrInSec, alpha: 0.154)},
                          classification: .linear),
         .qtcHdg:
            QTcCalculator(formula: .qtcHdg,
                          longName: "Hodges",
                          shortName: "QTcHDG",
                          reference: "Hodges M, Salerno D, Erlien D. Bazett’s QT correction reviewed: Evidence that a linear QT correction for heart rate is better. J Am Coll Cardiol. 1983;1:1983.",
                          equation: "QT + 1.75*(HR-60)",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec + 0.00175 * (QTc.secToBpm(rrInSec) - 60)},
                          classification: .rational),
         .qtcRtha:
            QTcCalculator(formula: .qtcRtha,
                          longName: "Rautaharju (2014)a",
                          shortName: "QTcRTHa",
                          reference: "Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. Int J Cardiol. 2014;174:535-540.",
                          equation: "QT * (120 + HR),/180",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec * (120.0 + QTc.secToBpm(rrInSec)) / 180.0},
                          classification: .rational),
         .qtcArr:
            QTcCalculator(formula: .qtcArr,
                          longName: "Arrowood",
                          shortName: "QTcARR",
                          reference: "Arrowood JA, Kline J, Simpson PM, Quigg RJ, Pippin JJ, Nixon JV, Mohrnty PK.  Modulation of the QT interval: effects of graded exercise and reflex cardiovascular stimulation.  J Appl Physiol. 1993;75:2217-2223.",
                          equation: "QT + 0.304 - 0.492*e^(-0.008*HR)",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec + 0.304 - 0.492 * exp(-0.008 * QTc.secToBpm(rrInSec))},
                          classification: .other),
         .qtcKwt:
            QTcCalculator(formula: .qtcKwt,
                          longName: "Kawataki",
                          shortName: "QTcKWT",
                          reference: "Kawataki M, Kashima T, Toda H, Tanaka H. Relation between QT interval and heart rate. applications and limitations of Bazett’s formula. J Electrocardiol. 1984;17:371-375.",
                          equation: "QT/RR^0.25",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.25)},
                          classification: .power),
         .qtcDmt:
            QTcCalculator(formula: .qtcDmt,
                          longName: "Dimitrienko",
                          shortName: "QTcDMT",
                          reference: "Dmitrienko AA, Sides GD, Winters KJ, et al. Electrocardiogram reference ranges derived from a standardized clinical trial population. Drug Inf J. 2005;39:395–405.",
                          equation: "QT/RR^0.413",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.413)},
                          classification: .power),
         .qtcYos:
           QTcCalculator(formula: .qtcYos,
                         longName: "Yoshinaga",
                         shortName: "QTcYOS",
                         reference: "Yoshinaga M, Tomari T, Aihoshi S, et al.  Exponential correction of QT interval to minimize the effect of the heart rate in children.  Jpn Circ J.  1993;57:102-108.",
                         equation: "QT/RR^0.31",
                         baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.31)},
                         classification: .power,
                         forAdults: false,
                         notes: "Children"),
         .qtcTest:
            QTcCalculator(formula: .qtcTest,
                          longName: "Test",
                          shortName: "QTcTEST",
                          reference: "TBD",
                          equation: "uses sex",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec + rrInSec},
                          classification: .power,
                          forAdults: false,
                          notes: "Children")
         ]
    
    static let qtpDictionary: [QTpFormula: QTpCalculator] =
        [.qtpArr:
            QTpCalculator(formula: .qtpArr,
                          longName: "Arrowood",
                          shortName: "QTpARR",
                          reference: "Arrowood JA, Kline J, Simpson PM, Quigg RJ, Pippin JJ, Nixon JV, Mohanty PK. Modulation of the QT interval: effects of graded exercise and reflex cardiovascular stimulation. J Appl Physiol (1985). 1993;75:2217-2223.",
                          equation: "0.12 + 0.492e^(-0.008*HR)",
                          baseEquation: {rrInSec,sex,age  in 0.12 + 0.492 * exp(-0.008 * QTc.secToBpm(rrInSec))},
                          classification: .exponential),
         .qtpBdl:
            QTpCalculator(formula: .qtpBdl,
                                 longName: "Boudoulas",
                                 shortName: "QTpBDL",
                                 reference: "Boudoulas H, Geleris P, Lewis RP, Rittgers SE.  Linear relationship between electrical systole, mechanical systole, and heart rate.  Chest 1981;80:613-617.",
                                 equation: "Males: QT = 0.521 - 2.0*HR; Females: QT = 0.511 - 1.8*HR'",
                                 baseEquation: {rrInSec, sex, age  in sex == .male ? QTc.msecToSec(521.0 - 2.0 * QTc.secToBpm(rrInSec)) : QTc.msecToSec(511.0 - 1.8 * QTc.secToBpm(rrInSec))},
                                 classification: .rational),
         .qtpAsh:
            QTpCalculator(formula: .qtpAsh,
                                 longName: "Ashman", shortName: "QTpASH", reference: "Ashman r.  The normal duration of the Q-T interval.  Am Heart J 1942;23:522-534.", equation: "QT = K log[10(RR + k)], K and k sex and age dependent'", baseEquation: qtpAsh,
                                 classification: .logarithmic)
         ]
}
