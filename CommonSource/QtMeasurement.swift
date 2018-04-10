//
//  QtMeasurement.swift
//  QTc_iOS
//
//  Created by David Mann on 4/9/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

import Foundation

public enum IntervalRateType {
    case interval
    case rate
}

public enum Units {
    case msec
    case sec
}

// Wrap up the parameters needed to measure QTc and QTp
public struct QtMeasurement {
    public let qt: Double? // an optional, since QT not needed for QTp
    public let intervalRate: Double  // RR interval or HR
    public let units: Units
    public let intervalRateType: IntervalRateType // an interval or HR
    public let sex: Sex
    public let age: Int?  // truncate ages to Int, may be nil as not always needed
    
    // In Swift, default init is interval, so must specifically declare public init
    public init(qt: Double?, intervalRate: Double, units: Units,
        intervalRateType: IntervalRateType, sex: Sex, age: Int?) {
        self.qt = qt
        self.intervalRate = intervalRate
        self.units = units
        self.intervalRateType = intervalRateType
        self.sex = sex
        self.age = age
    }
}
