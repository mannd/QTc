//
//  QTc.swift
//  QTc
//
//  Created by David Mann on 9/18/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

class Formulas {
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
    
    static let qtcDictionary: [QTcFormula : QTcCalculator] = [.qtcBzt: QTcCalculator(formula: .qtcBzt, longName: "Bazett", shortName: "QTcBZT",
                                       reference: "Bazett HC. An analysis of the time relations of electrocardiograms. Heart 1920; 7:353-367.",
                                       equation: "QT/RR^0.5",
                                       baseEquation: {qtInSec, rrInSec in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.5)}),
        .qtcFrd:
            QTcCalculator(formula: .qtcFrd, longName: "Fridericia", shortName: "QTcFRM",
                                      reference: "Fridericia L. Die sytolendauer in elektrokardiogramm bei normalen menschen und bei herzkranken. Acta Med Scand. 1920;53:469-486.",
                                      equation: "QT/RR^0.333",
                                      baseEquation: {qtInSec, rrInSec in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 1 / 3.0)}),
        .qtcMyd:
            QTcCalculator(formula: .qtcMyd, longName: "Mayeda", shortName: "QTcMYD",
                                      reference: "Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Sch Med Univ Imp. 1934;17:53-55.",
                                      equation: "QT/RR^0.604",
                                      baseEquation: {qtInSec, rrInSec in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.604)}),
        .qtcFrm:
        QTcCalculator(formula: .qtcFrm, longName: "Framingham (Sagie)", shortName: "QTcFRM",
                                  reference: "Sagie A, Larson MG, Goldberg RJ, Bengtson JR, Levy D. An improved method for adjusting the QT interval for heart rate (the Framingham Heart Study),. Am J Cardiol. 1992;70:797-801.",
                                  equation: "QT + 0.154*(1-RR)",
                                  baseEquation: {qtInSec, rrInSec in qtcLinear(qtInSec: qtInSec, rrInSec: rrInSec, alpha: 0.154)}),
        .qtcHdg:
            QTcCalculator(formula: .qtcHdg, longName: "Hodges", shortName: "QTcHDG",
                                      reference: "Hodges M, Salerno D, Erlien D. Bazett’s QT correction reviewed: Evidence that a linear QT correction for heart rate is better. J Am Coll Cardiol. 1983;1:1983.",
                                      equation: "QT + 1.75*(HR-60)",
                                      baseEquation: {qtInSec, rrInSec in qtInSec + 0.00175 * (QTc.secToBpm(rrInSec) - 60)}),
        .qtcRtha:
            QTcCalculator(formula: .qtcRtha, longName: "Rautaharju (2014)a", shortName: "QTcRTHa",
                                      reference: "Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. Int J Cardiol. 2014;174:535-540.",
                                      equation: "QT * (120 + HR),/180",
                                      baseEquation: {qtInSec, rrInSec in qtInSec * (120.0 + QTc.secToBpm(rrInSec)) / 180.0}),
        .qtcArr:
            QTcCalculator(formula: .qtcArr, longName: "Arrowood", shortName: "QTcARR",
                                      reference: "Arrowood JA, Kline J, Simpson PM, Quigg RJ, Pippin JJ, Nixon JV, Mohrnty PK.  Modulation of the QT interval: effects of graded exercise and reflex cardiovascular stimulation.  J Appl Physiol. 1993;75:2217-2223.",
                                      equation: "QT + 0.304 - 0.492*e^(-0.008*HR)",
                                      baseEquation: {qtInSec, rrInSec in qtInSec + 0.304 - 0.492 * exp(-0.008 * QTc.secToBpm(rrInSec))}),
         .qtcKwt:
            QTcCalculator(formula: .qtcKwt, longName: "Kawataki", shortName: "QTcKWT",
                                      reference: "Kawataki M, Kashima T, Toda H, Tanaka H. Relation between QT interval and heart rate. applications and limitations of Bazett’s formula. J Electrocardiol. 1984;17:371-375.",
                                      equation: "QT/RR^0.25",
                                      baseEquation: {qtInSec, rrInSec in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.25)})]
 
}
