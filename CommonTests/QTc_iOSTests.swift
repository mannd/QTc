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
    let rateIntervalTable: [(rate: Double, interval: Double)] = [(20, 3000),  (25, 2400), (30, 2000), (35, 1714), (40, 1500), (45, 1333), (50, 1200), (55, 1091), (60, 1000), (65, 923), (70, 857), (75, 800), (80, 750), (85, 706), (90, 667), (95, 632), (100, 600), (105, 571), (110, 545), (115, 522), (120, 500), (125, 480), (130, 462), (135, 444), (140, 429), (145, 414), (150, 400), (155, 387), (160, 375), (165, 364), (170, 353), (175, 343), (180, 333), (185, 324), (190, 316), (195, 308), (200, 300), (205, 293), (210, 286), (215, 279), (220, 273), (225, 267), (230, 261), (235, 255), (240, 250), (245, 245), (250, 240), (255, 235), (260, 231), (265, 226), (270, 222), (275, 218), (280, 214), (285, 211), (290, 207), (295, 203), (300, 200), (305, 197), (310, 194), (315, 190), (320, 188), (325, 185), (330, 182), (335, 179), (340, 176), (345, 174), (350, 171), (355, 169), (360, 167), (365, 164), (370, 162), (375, 160), (380, 158), (385, 156), (390, 154), (395, 152), (400, 150)]
    // uses online QTc calculator: http://www.medcalc.com/qtc.html, random values
    let qtcBztTable: [(qt: Double, interval: Double, qtc: Double)] = [(318, 1345, 274), (451, 878, 481), (333, 451, 496)]
    // table of calculated QTc from
    let qtcMultipleTable: [(rate: Double, rrInSec: Double, rrInMsec: Double, qtInMsec: Double, qtcBzt: Double, qtcFrd: Double, qtcFrm: Double, qtcHDG: Double)] = [(88, 0.682, 681.8, 278, 336.7, 315.9, 327.0, 327.0), (112, 0.536, 535.7, 334, 456.3, 411.2, 405.5, 425.0), (47, 1.2766, 1276.6, 402, 355.8, 370.6, 359.4, 379.3)]
 
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
        XCTAssertEqualWithAccuracy(QTc.msecToSec(1117), 1.117, accuracy: delta)
        
        // bpm <-> sec conversions
        XCTAssertEqual(QTc.bpmToSec(1), 60)
        // Swift divide by zero doesn't throw
        XCTAssertNoThrow(QTc.bpmToSec(0))
        XCTAssert(QTc.bpmToSec(0).isInfinite)
        XCTAssertEqual(QTc.bpmToSec(0), Double.infinity)
        XCTAssertEqualWithAccuracy(QTc.bpmToSec(0.333), 180.18018018018, accuracy: delta)
        
        // bpm <-> msec conversions
        // we'll check published conversion table with rough accuracy
        // source: https://link.springer.com/content/pdf/bfm%3A978-3-642-58810-5%2F1.pdf
        XCTAssertEqualWithAccuracy(QTc.bpmToMsec(215), 279, accuracy: veryRoughDelta)
        for (rate, interval) in rateIntervalTable {
            XCTAssertEqualWithAccuracy(QTc.bpmToMsec(rate), interval, accuracy: veryRoughDelta)
            XCTAssertEqualWithAccuracy(QTc.msecToBpm(interval), rate, accuracy: veryVeryRoughDelta)
        }
    }
    
    func testQTcFunctions() {
        // QTcBZT (Bazett)
        XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInSec:0.3, rrInSec:1.0), 0.3, accuracy: delta)
        XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInMsec:300, rrInMsec:1000), 300, accuracy:delta)
        XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInSec: 0.3, rate: 60), 0.3, accuracy: delta)
        XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInMsec: 300, rate: 60), 300, accuracy: delta)
        for (qt, interval, qtc) in qtcBztTable {
            XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInMsec: qt, rrInMsec: interval), qtc, accuracy: veryRoughDelta)
        }
        XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInMsec: 456, rate: 77), 516.6, accuracy: roughDelta)
        XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInMsec: 369, rrInMsec: 600), 476.4, accuracy: roughDelta)
        XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInSec: 2.78, rate: 88), 3.3667, accuracy: roughDelta)
        XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInSec: 2.78, rrInSec: QTc.bpmToSec(88)), 3.3667, accuracy: roughDelta)


        // QTcFRD (Fridericia)
        XCTAssertEqualWithAccuracy(QTc.qtcFrd(qtInMsec: 456, rate: 77), 495.5, accuracy: roughDelta)
        XCTAssertEqualWithAccuracy(QTc.qtcFrd(qtInMsec: 369, rrInMsec: 600), 437.5, accuracy: roughDelta)
        XCTAssertEqualWithAccuracy(QTc.qtcFrd(qtInSec: 2.78, rate: 88), 3.1586, accuracy: roughDelta)
        XCTAssertEqualWithAccuracy(QTc.qtcFrd(qtInSec: 2.78, rrInSec: QTc.bpmToSec(88)), 3.1586, accuracy: roughDelta)
        
        // run through multiple QTcs
        for (rate, rrInSec, rrInMsec, qtInMsec, qtcBzt, qtcFrd, qtcFrm, qtcHdg) in qtcMultipleTable {
            // all 4 forms of QTc calculation are tested for each calculation
            // QTcBZT
            XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInMsec: qtInMsec, rate: rate), qtcBzt, accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcBzt), accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcBzt, accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcBzt(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcBzt), accuracy: roughDelta)

            // QTcFRD
            XCTAssertEqualWithAccuracy(QTc.qtcFrd(qtInMsec: qtInMsec, rate: rate), qtcFrd, accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcFrd(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcFrd), accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcFrd(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcFrd, accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcFrd(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcFrd), accuracy: roughDelta)
            
            // QTcFRM
            XCTAssertEqualWithAccuracy(QTc.qtcFrm(qtInMsec: qtInMsec, rate: rate), qtcFrm, accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcFrm(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcFrm), accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcFrm(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcFrm   , accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcFrm(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcFrm), accuracy: roughDelta)
            
            // QTcHDG
            XCTAssertEqualWithAccuracy(QTc.qtcHdg(qtInMsec: qtInMsec, rate: rate), qtcHdg, accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcHdg(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcHdg), accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcHdg(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcHdg   , accuracy: roughDelta)
            XCTAssertEqualWithAccuracy(QTc.qtcHdg(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcHdg), accuracy: roughDelta)

        }
        
        // QTcRHTa
        XCTAssertEqualWithAccuracy(QTc.qtcRtha(qtInSec: 0.444, rate: 58.123), 0.43937, accuracy: delta)
        
        // handle zero RR
        XCTAssertEqual(QTc.qtcBzt(qtInSec: 300, rrInSec: 0), Double.infinity)
        XCTAssertEqual(QTc.qtcFrd(qtInSec: 300, rrInSec: 0), Double.infinity)

        
    }
    
}
