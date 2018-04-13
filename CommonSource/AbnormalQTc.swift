//
//  AbnormalQTc.swift
//  QTc
//
//  Created by David Mann on 4/13/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

import Foundation

// These are tests for abnormal QTc values from the literature
public enum Criterion {
    case simple // across the board upper limit of 440 msec in older literature
    case fda  // FDA criteria characterizes limits of 450 mild, 480 moderate, and 500 severe.
    // reference: https://www.fda.gov/downloads/Drugs/GuidanceComplianceRegulatoryInformation/Guidances/ucm073153.pdf
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
    let name: String
    let qtcTests: QTcTests
    let reference: String
    let description: String // the test described in prose
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
        var worstTest: QTcTest?
        var severity: Severity = .normal
        for test in failingTests {
            if UInt8(test.severity.rawValue) > UInt8(severity.rawValue) {
                severity = test.severity
                worstTest = test
            }
        }
        return worstTest
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
    static let CriteriaDictionary: [Criterion: QTcTestSuite] =
        [.simple:
            QTcTestSuite(
                name: "Schwartz, 1985",
                qtcTests: [QTcTest(value: 440, units: .msec, valueComparison: .greaterThan)],
                reference: "Schwartz PJ. Idiopathic long QT syndrome: Progress and questions. American Heart Journal. 1985;109(2):399-411. doi:10.1016/0002-8703(85)90626-X",
                description: "QTc > 440 msec",
                notes: "Simple but outdated criterion, from long QT syndrome data.  Overdiagnoses long QTc and no reckoning of sex difference in QT duration.")
    ]

}


