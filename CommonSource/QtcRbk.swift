//
//  QtcRbk.swift
//  QTc_iOS
//
//  Created by David Mann on 9/22/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

import Foundation


/// QTcRBK is based on a complex cubic spline function.
///
/// We have split out the components to make the math as clear as possible.
enum QtcRbk {
    // Fundamental component of the basic functions b0 to b1.
    private static func f(_ x: Double, _ c0: Double, _ c1: Double) -> Double {
        return (x - c0) / (c1 - c0)
    }

    // returns f^2
    private static func f2(_ x: Double, _ c0: Double, _ c1: Double) -> Double {
        return pow(f(x, c0, c1), 2)
    }

    // returns f^3
    private static func f3(_ x: Double, _ c0: Double, _ c1: Double) -> Double {
        return pow(f(x, c0, c1), 3)
    }

    // g = 1 - f
    private static func g(_ x: Double, _ c0: Double, _ c1: Double) -> Double {
        return 1 - f(x, c0, c1)
    }

    // returns g^2
    private static func g2(_ x: Double, _ c0: Double, _ c1: Double) -> Double {
        return pow(g(x, c0, c1), 2)
    }

    // returns g^3
    private static func g3(_ x: Double, _ c0: Double, _ c1: Double) -> Double {
        return pow(g(x, c0, c1), 3)
    }

    private static func ind(_ x: Double, _ min: Double, _ max: Double) -> Double {
        if min <= x && x < max { return 1.0 }
        else { return 0 }
    }

    internal static func b0(_ x: Double) -> Double {
        return g3(x, 35, 61) * ind(x, 35, 61)
    }

    internal static func b1(_ x: Double) -> Double {
        return f(x, 35, 61) * (g2(x, 35, 61) + g(x, 35, 61) * g(x, 35, 67) + g2(x, 35, 67))
            * ind(x, 35, 61)
            +
            g2(x, 35, 67) * g(x, 61, 67) * ind(x, 61, 67)
    }

    internal static func b2(_ x: Double) -> Double {
        return f(x, 35, 61) * f(x, 35, 67) * (g(x, 35, 61) + g(x, 35, 67) + g(x, 35, 73))
            * ind(x, 35, 61)
            +
            f(x, 35, 67) * g(x, 61, 67) * (g(x, 35, 67) + g(x, 35, 73)) * ind(x, 61, 67)
            +
            f(x, 61, 67) * g(x, 35, 73) * g(x, 61, 73) * ind(x, 61, 67)
            +
            g(x, 35, 73) * g(x, 61, 73) * g(x, 67, 73) * ind(x, 67, 73)
    }

    internal static func b3(_ x: Double) -> Double {
        return f(x, 35, 61) * f(x, 35, 67) * f(x, 35, 73) * ind(x, 35, 61)
            +
            (f(x, 35, 73) * (f(x, 35, 67) * g(x, 61, 67) + f(x, 61, 67) * g(x, 61, 73)))
            * ind(x, 61, 67)
            +
            f(x, 61, 67) * f(x, 61, 73) * g(x, 61, 81) * ind(x, 61, 67)
            +
            (g(x, 67, 73) * (f(x, 35, 73) * g(x, 61, 73) + f(x, 61, 73) * g(x, 61, 81)))
            * ind(x, 67, 73)
            +
            f(x, 67, 73) * g(x, 61, 81) * g(x, 67, 81) * ind(x, 67, 73)
            +
            g(x, 61, 81) * g(x, 67, 81) * g(x, 73, 81) * ind(x, 73, 81)
    }

}
