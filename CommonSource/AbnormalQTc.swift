//
//  AbnormalQTc.swift
//  QTc
//
//  Created by David Mann on 4/13/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

import Foundation

// These are tests for abnormal QTc values from the literature.
// Using String base allows serialization of this enum.
public enum Criterion: String {
    case schwartz1985 = "schwartz1985"
    case fda2005 = "fda2005"
    case aha2009 = "aha2009"
    case esc2005 = "esc2005"
    case goldenberg2006 = "goldenberg2006"
    // TODO: the rest of them
}

// Usage: if Comaprison.greaterThan, then QTc greater than the value is abnormal
public enum Comparison {
    case greaterThan
    case greaterThanOrEqual
    case lessThan
    case lessThanOrEqual
}

public struct Severity: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let normal = Severity(rawValue: 1)
    public static let borderline = Severity(rawValue: 2)
    public static let abnormal = Severity(rawValue: 4)
    public static let mild = Severity(rawValue: 8)
    public static let moderate = Severity(rawValue: 16)
    public static let severe = Severity(rawValue: 32)
    public static let error = Severity(rawValue: 64)
    
    public func isAbnormal() -> Bool {
        return self.rawValue >= Severity.abnormal.rawValue
    }
}

public struct QTcMeasurement {
    let qtc: Double
    let units: Units
    let sex: Sex
    let age: Int?
    
    public init(qtc: Double, units: Units, sex: Sex = .unspecified, age: Int? = nil) {
        self.qtc = qtc
        self.units = units
        self.sex = sex
        self.age = age
    }
}

public typealias QTcTests = [QTcTest]

// QTcTest describes a test for an abnormal QTc value, for example, QTc > 470 msec in women would be:
// let test = QTcTest(value: 470, units: .msec, sex: .female, valueLimitType: .upper, valueIntervalType: .open)
public struct QTcTest {
    let value: Double
    let units: Units
    let valueComparison: Comparison
    let sex: Sex  // may be unspecified
    let age: Int?  // age cutoff is optional
    let ageComparison: Comparison
    public let severity: Severity
    
    public init(value: Double, units: Units, valueComparison: Comparison, sex: Sex = .unspecified, age: Int? = nil, ageComparison: Comparison = .lessThan, severity: Severity = .abnormal) {
        self.value = value
        self.units = units
        self.valueComparison = valueComparison
        self.sex = sex
        self.age = age
        self.ageComparison = ageComparison
        self.severity = severity
    }
    
    func isAbnormal(qtcMeasurement: QTcMeasurement) -> Bool {
        var qtcValue = qtcMeasurement.qtc
        if units != qtcMeasurement.units {
            switch units {
            case .sec:
                qtcValue = QTc.msecToSec(qtcValue)
            case .msec:
                qtcValue = QTc.secToMsec(qtcValue)
            }
        }
        var result = false
        // test sex
        if sex == .male || sex == .female {
            if sex != qtcMeasurement.sex {
                return result
            }
        }
        // test age -- it's complicated
        if let age = age {
            guard let measuredAge = qtcMeasurement.age else { return result }
            switch ageComparison {
            case .lessThan:
                if age < measuredAge { return result }
            case .lessThanOrEqual:
                if age <= measuredAge { return result }
            case .greaterThan:
                if age > measuredAge { return result }
            case .greaterThanOrEqual:
                if age >= measuredAge { return result }
            }
        }
        // At this point qtcMeasurement fits criteria to actually make the comparison
        switch valueComparison {
        case .greaterThan:
            if qtcValue > value { result = true }
        case .greaterThanOrEqual:
            if qtcValue >= value { result = true }
        case .lessThan:
            if qtcValue < value { result = true }
        case .lessThanOrEqual:
            if qtcValue <= value { result = true }
        }
        return result
    }
    
}

public struct QTcTestSuite {
    public let name: String
    let qtcTests: QTcTests
    let reference: String
    public let description: String // the test described in prose
    let notes: String?  // optional notes about this test suite
    
    public init(name: String, qtcTests: QTcTests, reference: String, description: String, notes: String? = nil) {
        self.name = name
        self.qtcTests = qtcTests
        self.reference = reference
        self.description = description
        self.notes = notes
    }
    
    // returns abnormal tests
    func abnormalQTcTests(qtcMeasurement: QTcMeasurement) -> [QTcTest] {
        var abnormalTests: [QTcTest] = []
        for qtcTest in qtcTests {
            if qtcTest.isAbnormal(qtcMeasurement: qtcMeasurement) {
                abnormalTests.append(qtcTest)
            }
        }
        return abnormalTests
    }
    
    func mostSevereFailure(failingTests: [QTcTest]) -> QTcTest? {
        if failingTests.count < 1 { return nil }
        if failingTests.count == 1 { return failingTests[0] }
        var mostSevereResult: QTcTest?
        var severity: Severity = .normal
        for test in failingTests {
            if UInt8(test.severity.rawValue) > UInt8(severity.rawValue) {
                severity = test.severity
                mostSevereResult = test
            }
        }
        return mostSevereResult
    }
    
    public func failingTest(measurement: QTcMeasurement) -> QTcTest? {
        return mostSevereFailure(failingTests: abnormalQTcTests(qtcMeasurement: measurement))
    }
    
    public func severity(measurement: QTcMeasurement) -> Severity {
        let result = failingTest(measurement: measurement)
        if let result = result {
            return result.severity
        }
        else {
            return .normal
        }
    }
}

public struct AbnormalQTc {
    static let testSuiteDictionary: [Criterion: QTcTestSuite] =
        [.schwartz1985:
            QTcTestSuite(
                name: "Schwartz 1985",
                qtcTests: [QTcTest(value: 440, units: .msec, valueComparison: .greaterThan)],
                reference: "Schwartz PJ. Idiopathic long QT syndrome: Progress and questions. American Heart Journal. 1985;109(2):399-411. doi:10.1016/0002-8703(85)90626-X",
                description: "QTc > 440 msec",
                notes: "Simple but outdated criterion, from long QT syndrome data.  Overdiagnoses long QTc and no reckoning of sex difference in QT duration."),
         .fda2005:
            QTcTestSuite(
                name: "FDA 2005",
                qtcTests: [
                    QTcTest(value: 450, units: .msec, valueComparison: .greaterThan, severity: .mild),
                    QTcTest(value: 480, units: .msec, valueComparison: .greaterThan, severity: .moderate),
                    QTcTest(value: 500, units: .msec, valueComparison: .greaterThan, severity: .severe)],
                reference: "Guidance for Industry E14 Clinical Evaluation of QT/QTc Interval Prolongation and Proarrhythmic Potential for Non-Antiarrhythmic Drugs. :20.",
                description: "QTc > 450 msec mild prolongation\nQTc > 480 msec moderate prolongation\nQTc > 500 msec severe prolongation",
                notes: "Used in FDA trials."),
         .aha2009:
            QTcTestSuite(
                name: "AHA 2009",
                qtcTests: [
                QTcTest(value: 450, units: .msec, valueComparison: .greaterThanOrEqual, sex: .male),
                QTcTest(value: 460, units: .msec, valueComparison: .greaterThanOrEqual, sex: .female),
                // We include test below if sex not specified, since by above 2 tests this must be true.  This
                // test is redundant with the one above, but we leave them both in for clarity's sake.
                QTcTest(value: 460, units: .msec, valueComparison: .greaterThanOrEqual, sex: .unspecified),
                QTcTest(value: 390, units: .msec, valueComparison: .lessThanOrEqual)],
                reference: "AHA/ACCF/HRS Recommendations for the Standardization and Interpretation of the Electrocardiogram: Part IV: The ST Segment, T and U Waves, and the QT Interval A Scientific Statement From the American Heart Association Electrocardiography and Arrhythmias Committee, Council on Clinical Cardiology; the American College of Cardiology Foundation; and the Heart Rhythm Society Endorsed by the International Society for Computerized Electrocardiology. Journal of the American College of Cardiology. 2009;53(11):982-991. doi:10.1016/j.jacc.2008.12.014",
                description: "QTc ≥ 450 msec men\nQTc ≥ 460 msec women\nQTc ≤ 390 msec men and women",
                notes: "Includes both long and short QTc criteria."),
         .esc2005:
            QTcTestSuite(
                name: "ESC 2005",
                qtcTests: [
                QTcTest(value: 440, units: .msec, valueComparison: .greaterThan, sex: .male),
                QTcTest(value: 460, units: .msec, valueComparison: .greaterThan, sex: .female),
                // include below when sex unspecified
                QTcTest(value: 460, units: .msec, valueComparison: .greaterThan),
                QTcTest(value: 300, units: .msec, valueComparison: .lessThan)],
                reference: "Corrado, Domenico, Antonio Pelliccia, Hans Halvor Bjørnstad, Luc Vanhees, Alessandro Biffi, Mats Borjesson, Nicole Panhuyzen-Goedkoop, et al. “Cardiovascular Pre-Participation Screening of Young Competitive Athletes for Prevention of Sudden Death: Proposal for a Common European ProtocolConsensus Statement of the Study Group of Sport Cardiology of the Working Group of Cardiac Rehabilitation and Exercise Physiology and the Working Group of Myocardial and Pericardial Diseases of the European Society of Cardiology.” European Heart Journal 26, no. 5 (March 1, 2005): 516–24. https://doi.org/10.1093/eurheartj/ehi108.",
                description: "QTc > 440 msec men\nQTc > 460 msec women\nQTc < 300 msec men and women",
                notes: "Includes both long and short QTc criteria.")

    ]
    
    public static func qtcLimits(criterion: Criterion) -> QTcTestSuite? {
        return testSuiteDictionary[criterion]
    }

}


