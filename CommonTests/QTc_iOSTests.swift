//
//  QTc_iOSTests.swift
//  QTc_iOSTests
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import XCTest
@testable import QTc

class QTc_iOSTests: XCTestCase {
    // Accuracy for all non-integral measurements
    let delta = 0.0000001
    let roughDelta = 0.1
    let veryRoughDelta = 0.5  // accurate to nearest half integer
    let veryVeryRoughDelta = 1.0 // accurate to 1 integer
    // source: https://link.springer.com/content/pdf/bfm%3A978-3-642-58810-5%2F1.pdf
    // Note this table is not accurate within 0.5 bpm when converting back from interval to rate
    let rateIntervalTable: [(rate: Double, interval: Double)] = [(20, 3000),  (25, 2400),
                                                                 (30, 2000), (35, 1714), (40, 1500),
                                                                 (45, 1333), (50, 1200), (55, 1091),
                                                                 (60, 1000), (65, 923), (70, 857), (75, 800),
                                                                 (80, 750), (85, 706), (90, 667), (95, 632),
                                                                 (100, 600), (105, 571), (110, 545), (115, 522),
                                                                 (120, 500), (125, 480), (130, 462), (135, 444),
                                                                 (140, 429), (145, 414), (150, 400), (155, 387),
                                                                 (160, 375), (165, 364), (170, 353), (175, 343),
                                                                 (180, 333), (185, 324), (190, 316), (195, 308),
                                                                 (200, 300), (205, 293), (210, 286), (215, 279),
                                                                 (220, 273), (225, 267), (230, 261), (235, 255),
                                                                 (240, 250), (245, 245), (250, 240), (255, 235),
                                                                 (260, 231), (265, 226), (270, 222), (275, 218),
                                                                 (280, 214), (285, 211), (290, 207), (295, 203),
                                                                 (300, 200), (305, 197), (310, 194), (315, 190),
                                                                 (320, 188), (325, 185), (330, 182), (335, 179),
                                                                 (340, 176), (345, 174), (350, 171), (355, 169),
                                                                 (360, 167), (365, 164), (370, 162), (375, 160),
                                                                 (380, 158), (385, 156), (390, 154), (395, 152),
                                                                 (400, 150)]
    // uses online QTc calculator: http://www.medcalc.com/qtc.html, random values
    let qtcBztTable: [(qt: Double, interval: Double, qtc: Double)] = [(318, 1345, 274), (451, 878, 481), (333, 451, 496)]
    // TODO: Add other hand calculated tables for each formula
    // table of calculated QTc from
    let qtcMultipleTable: [(rate: Double, rrInSec: Double, rrInMsec: Double, qtInMsec: Double,
                            qtcBzt: Double, qtcFrd: Double, qtcFrm: Double, qtcHDG: Double)] =
      [(88, 0.682, 681.8, 278, 336.7, 315.9, 327.0, 327.0), (112, 0.536, 535.7, 334, 456.3, 411.2, 405.5, 425.0),
       (47, 1.2766, 1276.6, 402, 355.8, 370.6, 359.4, 379.3), (132, 0.4545, 454.5, 219, 324.8, 284.8, 303, 345)]
    // TODO: Add new formulae here
    let qtcRandomTable: [(qtInSec: Double, rrInSec: Double, qtcMyd: Double, qtcRtha: Double,
                          qtcArr: Double, qtcKwt: Double)] = [(0.217, 1.228, 0.191683142324075,
                                                               0.20357003257329, 0.188180853891965, 0.206138989195107),
                                                              (0.617, 1.873, 0.422349852160997, 0.521139348638548,
                                                               0.540226253226725,0.527412865616186 ),
                                                              (0.441, 0.024, 4.19557027148694, 6.419, 0.744999998985912,
                                                               1.12043270968093),
                                                              (0.626, 1.938, 0.419771215123981, 0.525004471964224,
                                                               0.545939267391605, 0.530561692609049),
                                                              (0.594, 1.693, 0.432192914133319, 0.512952155936208,
                                                               0.527461134835087, 0.520741518839723),
                                                              (0.522, 0.670, 0.664846401046771, 0.607701492537313,
                                                               0.585658505426308, 0.576968100296572),
                                                              (0.162, 0.238, 0.385533865286431, 0.334890756302521,
                                                               0.400524764066341, 0.231937395103792),
                                                              (0.449, 0.738, 0.539436462235939, 0.50213369467028,
                                                               0.496257865770434, 0.484431360905827),
                                                              (0.364, 0.720, 0.443887132523326, 0.411185185185185,
                                                               0.415398777435965, 0.395155707875796),
                                                              (0.279, 0.013, 3.84399149834848, 7.33984615384616,
                                                               0.583, 0.826263113547243),
                                                              (0.184, 0.384, 0.328005981451736, 0.282388888888889,
                                                               0.347039639944786, 0.233741064151123)]
    
 override func setUp() {
 super.setUp()
 // Put setup code here. This method is called before the invocation of each test method in the class.
 }
 
 override func tearDown() {
 // Put teardown code here. This method is called after the invocation of each test method in the class.
 super.tearDown()
 }
 
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testConversions() {
        // sec <-> msec conversions
        XCTAssertEqual(QTc.secToMsec(1), 1000)
        XCTAssertEqual(QTc.secToMsec(2), 2000)
        XCTAssertEqual(QTc.msecToSec(1000), 1)
        XCTAssertEqual(QTc.msecToSec(2000), 2)
        XCTAssertEqual(QTc.msecToSec(0), 0)
        XCTAssertEqual(QTc.secToMsec(0), 0)
        XCTAssertEqual(QTc.msecToSec(2000), 2)                
        XCTAssertEqual(QTc.msecToSec(1117), 1.117, accuracy: delta)
        
        // bpm <-> sec conversions
        XCTAssertEqual(QTc.bpmToSec(1), 60)
        // Swift divide by zero doesn't throw
        XCTAssertNoThrow(QTc.bpmToSec(0))
        XCTAssert(QTc.bpmToSec(0).isInfinite)
        XCTAssertEqual(QTc.bpmToSec(0), Double.infinity)
        XCTAssertEqual(QTc.bpmToSec(0.333), 180.18018018018, accuracy: delta)
        
        // bpm <-> msec conversions
        // we'll check published conversion table with rough accuracy
        // source: https://link.springer.com/content/pdf/bfm%3A978-3-642-58810-5%2F1.pdf
        XCTAssertEqual(QTc.bpmToMsec(215), 279, accuracy: veryRoughDelta)
        for (rate, interval) in rateIntervalTable {
            XCTAssertEqual(QTc.bpmToMsec(rate), interval, accuracy: veryRoughDelta)
            XCTAssertEqual(QTc.msecToBpm(interval), rate, accuracy: veryVeryRoughDelta)
        }
    }
    
    func testQTcFunctions() {
        // QTcBZT (Bazett)
        let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        XCTAssertEqual(qtcBzt.calculate(qtInSec:0.3, rrInSec:1.0), 0.3, accuracy: delta)
        XCTAssertEqual(qtcBzt.calculate(qtInMsec:300, rrInMsec:1000), 300, accuracy:delta)
        XCTAssertEqual(qtcBzt.calculate(qtInSec: 0.3, rate: 60), 0.3, accuracy: delta)
        XCTAssertEqual(qtcBzt.calculate(qtInMsec: 300, rate: 60), 300, accuracy: delta)
        for (qt, interval, qtc) in qtcBztTable {
            XCTAssertEqual(qtcBzt.calculate(qtInMsec: qt, rrInMsec: interval), qtc, accuracy: veryRoughDelta)
        }
        XCTAssertEqual(qtcBzt.calculate(qtInMsec: 456, rate: 77), 516.6, accuracy: roughDelta)
        XCTAssertEqual(qtcBzt.calculate(qtInMsec: 369, rrInMsec: 600), 476.4, accuracy: roughDelta)
        XCTAssertEqual(qtcBzt.calculate(qtInSec: 2.78, rate: 88), 3.3667, accuracy: roughDelta)
        XCTAssertEqual(qtcBzt.calculate(qtInSec: 2.78, rrInSec: QTc.bpmToSec(88)), 3.3667, accuracy: roughDelta)
        XCTAssertEqual(qtcBzt.calculate(qtInSec: 5.0, rrInSec: 0), Double.infinity)
        XCTAssertEqual(qtcBzt.calculate(qtInSec: 5.0, rrInSec: 0), Double.infinity)

        // QTcFRD (Fridericia)
        let qtcFrd = QTc.qtcCalculator(formula: .qtcFrd)
        XCTAssertEqual(qtcFrd.calculate(qtInMsec: 456, rate: 77), 495.5, accuracy: roughDelta)
        XCTAssertEqual(qtcFrd.calculate(qtInMsec: 369, rrInMsec: 600), 437.5, accuracy: roughDelta)
        XCTAssertEqual(qtcFrd.calculate(qtInSec: 2.78, rate: 88), 3.1586, accuracy: roughDelta)
        XCTAssertEqual(qtcFrd.calculate(qtInSec: 2.78, rrInSec: QTc.bpmToSec(88)), 3.1586, accuracy: roughDelta)
        
        // run through multiple QTcs
        let qtcFrm = QTc.qtcCalculator(formula: .qtcFrm)
        let qtcHdg = QTc.qtcCalculator(formula: .qtcHdg)
        for (rate, rrInSec, rrInMsec, qtInMsec, qtcBztResult, qtcFrdResult, qtcFrmResult, qtcHdgResult) in qtcMultipleTable {
            // all 4 forms of QTc calculation are tested for each calculation
            // QTcBZT
            XCTAssertEqual(qtcBzt.calculate(qtInMsec: qtInMsec, rate: rate), qtcBztResult, accuracy: roughDelta)
            XCTAssertEqual(qtcBzt.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcBztResult), accuracy: roughDelta)
            XCTAssertEqual(qtcBzt.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcBztResult, accuracy: roughDelta)
            XCTAssertEqual(qtcBzt.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcBztResult), accuracy: roughDelta)

            // QTcFRD
            XCTAssertEqual(qtcFrd.calculate(qtInMsec: qtInMsec, rate: rate), qtcFrdResult, accuracy: roughDelta)
            XCTAssertEqual(qtcFrd.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcFrdResult), accuracy: roughDelta)
            XCTAssertEqual(qtcFrd.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcFrdResult, accuracy: roughDelta)
            XCTAssertEqual(qtcFrd.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcFrdResult), accuracy: roughDelta)
            
   
         // QTcFRM
            XCTAssertEqual(qtcFrm.calculate(qtInMsec: qtInMsec, rate: rate), qtcFrmResult, accuracy: roughDelta)
            XCTAssertEqual(qtcFrm.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcFrmResult), accuracy: roughDelta)
            XCTAssertEqual(qtcFrm.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcFrmResult, accuracy: roughDelta)
            XCTAssertEqual(qtcFrm.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcFrmResult), accuracy: roughDelta)
            
            // QTcHDG
            XCTAssertEqual(qtcHdg.calculate(qtInMsec: qtInMsec, rate: rate), qtcHdgResult, accuracy: roughDelta)
            XCTAssertEqual(qtcHdg.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcHdgResult), accuracy: roughDelta)
            XCTAssertEqual(qtcHdg.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcHdgResult, accuracy: roughDelta)
            XCTAssertEqual(qtcHdg.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcHdgResult), accuracy: roughDelta)

        }
        
        // handle zero RR
        XCTAssertEqual(qtcBzt.calculate(qtInSec: 300, rrInSec: 0), Double.infinity)
        XCTAssertEqual(qtcFrd.calculate(qtInSec: 300, rrInSec: 0), Double.infinity)
        // handle zero QT and RR
        XCTAssert(qtcFrd.calculate(qtInMsec: 0, rrInMsec: 0).isNaN)
        // handle negative RR
        XCTAssert(qtcBzt.calculate(qtInMsec: 300, rrInMsec: -100).isNaN)
        
        // QTcRHTa
        let qtcRtha = QTc.qtcCalculator(formula: .qtcRtha)
        XCTAssertEqual(qtcRtha.calculate(qtInSec: 0.444, rate: 58.123), 0.43937, accuracy: delta)

        // QTcMyd
        let qtcMyd = QTc.qtcCalculator(formula: .qtcMyd)
        XCTAssertEqual(qtcMyd.calculate(qtInSec: 0.399, rrInSec: 0.788), 0.46075606, accuracy: delta)
        
        // QTcArr
        let qtcArr = QTc.qtcCalculator(formula: .qtcArr)
        XCTAssertEqual(qtcArr.calculate(qtInSec: 0.275, rate: 69), 0.295707844, accuracy: delta)
        
        // Run through more multiple QTcs
        let qtcKwt = QTc.qtcCalculator(formula: .qtcKwt)
        for (qtInSec, rrInSec, qtcMydResult, qtcRthaResult, qtcArrResult, qtcKwtResult) in qtcRandomTable {
            XCTAssertEqual(qtcMyd.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcMydResult, accuracy: delta)
            XCTAssertEqual(qtcRtha.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcRthaResult, accuracy: delta)
            XCTAssertEqual(qtcArr.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcArrResult, accuracy: delta)
            XCTAssertEqual(qtcKwt.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcKwtResult, accuracy: delta)
        }
        
    }

    // Most QTc functions will have QTc == QT at HR 60 (RR 1000 msec)
    func testEquipose() {
        let sampleQTs = [0.345, 1.0, 0.555, 0.114, 0, 0.888]
        // Subset of QTc formulae, only including non-exponential formulas
        let formulas: [QTcFormula] = [.qtcBzt, .qtcFrd, .qtcHdg, .qtcFrm, .qtcMyd, .qtcRtha]
        
        for formula in formulas {
            let qtc = QTc.qtcCalculator(formula: formula)
            for qt in sampleQTs {
                XCTAssertEqual(qtc.calculate(qtInSec: qt, rrInSec: 1.0), qt)
            }
        }
    }
    
    func testQTcConvert() {
       let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        let qtcHdg = QTc.qtcCalculator(formula: .qtcHdg)
        let qtcRtha = QTc.qtcCalculator(formula: .qtcRtha)
        let qtcFrm = QTc.qtcCalculator(formula: .qtcFrm)
        XCTAssertEqual(qtcBzt.calculate(qtInMsec: 356.89, rrInMsec: 891.32), QTc.secToMsec(qtcBzt.calculate(qtInSec: 0.35689, rrInSec: 0.89132)))
        XCTAssertEqual(qtcHdg.calculate(qtInSec: 0.299, rrInSec: 0.5), QTc.msecToSec(qtcHdg.calculate(qtInMsec: 299, rate: 120)))
        XCTAssertEqual(qtcRtha.calculate(qtInSec: 0.489, rate: 78.9), QTc.msecToSec(qtcRtha.calculate(qtInMsec: 489, rate: 78.9)))
        XCTAssertEqual(qtcFrm.calculate(qtInMsec: 843, rrInMsec: 300), qtcFrm.calculate(qtInMsec: 843, rate: 200))
    }
    
    
//    func testQTpConvert() {
//        XCTAssertEqual(QTc.qtpArr(rrInSec: 0.253), QTc.msecToSec(QTc.qtpArr(rrInMsec: 253)))
//        XCTAssertEqual(QTc.qtpArr(rrInSec: 0.500), QTc.qtpArr(rate: 120))
//    }

}
