//
//  Formulas.swift
//  Formulas
//
//  Created by David Mann on 9/18/17.
//  Copyright © 2017, 2018 EP Studios. All rights reserved.
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

    private static func qtpLinear(rrInSec: Double, alpha: Double, k: Double) -> Sec {
        return k + alpha * rrInSec
    }
    
    // Some complex formulae easier to present here than as closure
    private static func qtcAdm(qtInSec: Double, rrInSec: Double, sex: Sex, age: Age) -> Sec {
        let alpha: Double
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
    
    private static func qtpAdm(rrInSec: Double, sex: Sex, age: Age) -> Sec {
        let alpha: Double
        let k: Double
        switch sex {
        case .unspecified:
            alpha = 0.1464
            k = 0.2572
        case .male:
            alpha = 0.1536
            k = 0.2462
        case .female:
            alpha = 0.1259
            k = 0.2789
        }
        return qtpLinear(rrInSec: rrInSec, alpha: alpha, k: k)
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
    static let qtcDictionary: [Formula: QTcCalculator] =
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
                          shortName: "QTcFRD",
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
                          reference: "Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Scholae Med Univ Imp Kioto. 1934;17:53-55.",
                          equation: "QT/RR^0.604",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.604)},
                          classification: .power,
                          notes: "200 normal subjects and patients without heart disease (135 M, 65 F; age 18-64; HR 54.5-115.8).",
                          publicationDate: "1934",
                          numberOfSubjects: 200),
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
                          longName: "Rautaharju-a",
                          shortName: "QTcRTHa",
                          reference: "Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. International Journal of Cardiology. 2014;174(3):535-540. doi:10.1016/j.ijcard.2014.04.133",
                          equation: "QT * (120 + HR) / 180",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec * (120.0 + QTc.secToBpm(rrInSec)) / 180.0},
                          classification: .rational,
                          notes: "Healthy subjects: 57,595, aged 5-89 years, 54% women.\nAbnormal QTc: age < 40: 430 ms for men, 440 ms for women; age 40-69: 440 ms for men, 450 ms for women, age ≥ 70: 455 ms for men, 460 ms for women.",
                          publicationDate: "2014"),
         .qtcRthb:
            QTcCalculator(formula: .qtcRthb,
                          longName: "Rautaharju-b",
                          shortName: "QTcRTHb",
                          // TODO: extract common strings like references
                          reference: "Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. International Journal of Cardiology. 2014;174(3):535-540. doi:10.1016/j.ijcard.2014.04.133",
                          equation: "QT + 387 * (1 - RR^0.37) for men\nQT + 409 * (1 - RR^0.39) for women\nRR in sec, QT and result in msec",
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
                          reference: "Arrowood JA, Kline J, Simpson PM, Quigg RJ, Pippin JJ, Nixon JV, Mohanty PK.  Modulation of the QT interval: effects of graded exercise and reflex cardiovascular stimulation.  J Appl Physiol. 1993;75:2217-2223.",
                          equation: "QT + 0.304 - 0.492*e^(-0.008*HR)",
                          baseEquation: {qtInSec, rrInSec, sex, age in qtInSec + 0.304 - 0.492 * exp(-0.008 * QTc.secToBpm(rrInSec))},
                          classification: .exponential,
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
                          reference: "Adams W. The normal duration of the electrocardiographic ventricular complex. J Clin Invest. 1936;15(4):335-342.  doi:10.1172%2FJCI100784",
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
                          equation: "K * RR^0.5 | where K = 0.37 for men and 0.40 for women",
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
                          // TODO: Should B0 constant be 0.116 or 0.12? Recreate QTcARR based on this.
                          baseEquation: {rrInSec,sex,age  in 0.116 + 0.492 * exp(-0.008 * QTc.secToBpm(rrInSec))},
                          classification: QTc.qtcCalculator(formula: .qtcArr).classification,
                          publicationDate: QTc.qtcCalculator(formula: .qtcArr).publicationDate),
         .qtpBdl:
            QTpCalculator(formula: .qtpBdl,
                          longName: "Boudoulas",
                          shortName: "QTpBDL",
                          reference: "Boudoulas H, Geleris P, Lewis RP, Rittgers SE.  Linear relationship between electrical systole, mechanical systole, and heart rate.  Chest 1981;80:613-617.",
                          equation: "Males: 0.521 - 2.0*HR\nFemales: 0.511 - 1.8*HR",
                          baseEquation: {rrInSec, sex, age  in sex == .male ? QTc.msecToSec(521.0 - 2.0 * QTc.secToBpm(rrInSec)) : QTc.msecToSec(511.0 - 1.8 * QTc.secToBpm(rrInSec))},
                          classification: .rational,
                          publicationDate: "1981"),
         .qtpAsh:
            QTpCalculator(formula: .qtpAsh,
                          longName: "Ashman", shortName: "QTpASH", reference: "Ashman r.  The normal duration of the Q-T interval.  Am Heart J 1942;23:522-534.", equation: "K log[10(RR + k)] | K and k sex and age dependent", baseEquation: qtpAsh,
                          classification: .logarithmic,
                          publicationDate: "1942"),
         .qtpHdg:
            QTpCalculator(formula: .qtpHdg,
                          longName: QTc.qtcCalculator(formula: .qtcHdg).longName,
                          shortName: "QTpHDG",
                          reference: QTc.qtcCalculator(formula: .qtcHdg).reference,
                          equation: "496 - (1.75 * HR) | result in msec",
                          baseEquation: {rrInSec,sex,age in 0.496 - (0.00175 * QTc.secToBpm(rrInSec))},
                          classification: QTc.qtcCalculator(formula: .qtcHdg).classification,
                          publicationDate: QTc.qtcCalculator(formula: .qtcHdg).publicationDate,
                          numberOfSubjects: QTc.qtcCalculator(formula: .qtcHdg).numberOfSubjects),
         .qtpFrd:
           QTpCalculator(formula: .qtpFrd,
                         longName: QTc.qtcCalculator(formula: .qtcFrd).longName,
                         shortName: "QTpFRD",
                         reference: QTc.qtcCalculator(formula: .qtcFrd).reference,
                         equation: "0.3815 * RR^(1/3) | units in 0.01 sec",
                         baseEquation: {rrInSec, sex, age in 0.0822 * pow(100.0 * rrInSec, 1/3)},
                         classification: QTc.qtcCalculator(formula: .qtcFrd).classification,
                         notes: QTc.qtcCalculator(formula: .qtcFrd).notes,
                         publicationDate: QTc.qtcCalculator(formula: .qtcFrd).publicationDate,
                         numberOfSubjects: QTc.qtcCalculator(formula: .qtcFrd).numberOfSubjects),
         .qtpMyd:
            QTpCalculator(formula: .qtpMyd,
                          longName: QTc.qtcCalculator(formula: .qtcMyd).longName,
                          shortName: "QTpMYD",
                          reference: QTc.qtcCalculator(formula: .qtcMyd).reference,
                          // equation modified from Simonson doi:10.1016/0002-8703(62)90059-5
                          equation: "0.02574 * (100 * RR)^0.604",
                          baseEquation: {rrInSec, sex, age in 0.02574 * pow(100.0 * rrInSec, 0.604)},
                          classification: QTc.qtcCalculator(formula: .qtcMyd).classification,
                          notes: "200 normal subjects and patients without heart disease (135 M, 65 F; age 18-64; HR 54.5-115.8).",
                          publicationDate: QTc.qtcCalculator(formula: .qtcMyd).publicationDate,
                          numberOfSubjects: 200),
         .qtpKrj:
           QTpCalculator(formula: .qtpKrj,
                         longName: "Karjalainen",
                         shortName: "QTpKRJ",
                         reference: "Karjalainen J, Viitasalo M, Mänttäri M, Manninen V. Relation between QT intervals and heart rates from 40 to 120 beats/min in rest electrocardiograms of men and a simple method to adjust QT interval values. Journal of the American College of Cardiology. 1994;23(7):1547-1553. doi:10.1016/0735-1097(94)90654-8",
                         equation: "HR < 60: 0.116*RR + 277\nHR 60 to 99: 0.156*RR + 236\nHR > 99: 0.384*RR + 99\nRR and QT in msec",
                         baseEquation: {rrInSec, sex, age in

                             if rrInSec > 1.0 {
                                 return QTc.msecToSec(116.0 * rrInSec + 277.0)
                             }
                             else if rrInSec <= 0.6 {
                                 return QTc.msecToSec(384.0 * rrInSec + 99.0)
                             }
                             else {
                                 return QTc.msecToSec(156.0 * rrInSec + 236.0)
                             }
                         },
                         classification: .linear,
                         notes: "324 healthy young (age 18-28) men.  No women in study group.",
                         publicationDate: "1994",
                         numberOfSubjects: 324),
         .qtpSch:
            QTpCalculator(formula: .qtpSch,
                          longName: "Schlamowitz",
                          shortName: "QTpSCH",
                          reference: "Schlamowitz I. An analysis of the time relationships within the cardiac cycle in electrocardiograms of normal men.  American Heart Journal.  1946;31(3):329-342.  doi:10.1016/0002-8703%2846%2990314-6",
                          equation: "0.205*RR + 0.167",
                          baseEquation: {rrInSec, sex, age in 0.205 * rrInSec + 0.167},
                          classification: .linear,
                          notes: "650 healthy male soldiers, age 18-44.  No women.",
                          publicationDate: "1946",
                          numberOfSubjects: 650),
         .qtpAdm:
           QTpCalculator(formula: .qtpAdm,
                         longName: QTc.calculator(formula: .qtcAdm).longName,
                         shortName: "QTpADM",
                         reference: QTc.calculator(formula: .qtcAdm).reference,
                         equation: "0.2462 + 0.1536*RR for men\n0.2789 + 0.1259*RR for women\n0.2572 + 0.1464*RR for combined sexes",
                         baseEquation: qtpAdm,
                         classification: .linear,
                         notes: "104 healthy subjects, 50 men, 54 women, mean age 28.",
                         publicationDate: QTc.calculator(formula: .qtcAdm).publicationDate,
                         numberOfSubjects: QTc.calculator(formula: .qtcAdm).numberOfSubjects)
    ]
}
