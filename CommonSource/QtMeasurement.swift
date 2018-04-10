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
    var qt: Double? // an optional, since QT not needed for QTp
    var intervalRate: Double  // RR interval or HR
    var units: Units
    var intervalRateType: IntervalRateType // an interval or HR
    var sex: Sex
    var age: Int?  // truncate ages to Int, may be nil as not always needed
}
