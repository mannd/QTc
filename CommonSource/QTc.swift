//
//  QTc.swift
//  QTc
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

/// TODO: is @objc tag needed if inheritance from NSObject?
@objc public class QTc: NSObject {
    // static conversion functions
    public static func secToMsec(_ sec: Double) -> Double {
        return sec * 1000
    }

    public static func msecToSec(_ msec: Double) -> Double {
        return msec / 1000
    }
    
    public static func bpmToSec(_ bpm: Double) -> Double {
        return 60 / bpm
    }

    public static func secToBpm(_ sec: Double) -> Double {
        return 60 / sec
    }

    public static func bpmToMsec(_ bpm: Double) -> Double {
        return 60_000 / bpm
    }

    public static func msecToBpm(_ msec: Double) -> Double {
        return 60_000 / msec
    }
    
    // QTc formulae
    
    // Bazett (QTcBZT)
    // base formula
    public static func qtcBzt(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec / sqrt(rrInSec)
    }
    
    public static func qtcBzt(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcBzt(qtInSec: msecToSec(qtInMsec), rrInSec: msecToSec(rrInMsec)))
    }
    
    public static func qtcBzt(qtInSec: Double, rate: Double) -> Double {
        return qtcBzt(qtInSec: qtInSec, rrInSec: bpmToSec(rate))
    }
    
    public static func qtcBzt(qtInMsec: Double, rate: Double) -> Double {
        return qtcBzt(qtInMsec: qtInMsec, rrInMsec: bpmToMsec(rate))
    }
    
    // Fridericia (QTcFRD)
    // base formula
    public static func qtcFrd(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec / pow(rrInSec, 1 / 3.0)
    }
    
    public static func qtcFrd(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcFrd(qtInSec: msecToSec(qtInMsec), rrInSec: msecToSec(rrInMsec)))
    }
    
    public static func qtcFrd(qtInSec: Double, rate: Double) -> Double {
        return qtcFrd(qtInSec: qtInSec, rrInSec: bpmToSec(rate))
    }
    
    public static func qtcFrd(qtInMsec: Double, rate: Double) -> Double {
        return qtcFrd(qtInMsec: qtInMsec, rrInMsec: bpmToMsec(rate))
    }
    
    // Framingham (a.k.a. Sagie) (QTcFRM)
    // base formula
    public static func qtcFrm(qtInSec: Double, rrInSec: Double) -> Double {
        return qtInSec + 0.154 * (1.0 - rrInSec)
    }
    
    public static func qtcFrm(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcFrm(qtInSec: msecToSec(qtInMsec), rrInSec: msecToSec(rrInMsec)))
    }
    
    public static func qtcFrm(qtInSec: Double, rate: Double) -> Double {
        return qtcFrm(qtInSec: qtInSec, rrInSec: bpmToSec(rate))
    }
    
    public static func qtcFrm(qtInMsec: Double, rate: Double) -> Double {
        return qtcFrm(qtInMsec: qtInMsec, rrInMsec: bpmToMsec(rate))
    }
    
    // Hodges (QTcHDG)
    public static func qtcHdg(qtInSec: Double, rrInSec: Double) -> Double {
        return qtcHdg(qtInSec: qtInSec, rate: secToBpm(rrInSec))
    }
    
    public static func qtcHdg(qtInMsec: Double, rrInMsec: Double) -> Double {
        return secToMsec(qtcHdg(qtInSec: msecToSec(qtInMsec), rate: msecToBpm(rrInMsec)))
    }
    
    //base formula
    public static func qtcHdg(qtInSec: Double, rate: Double) -> Double {
        return qtInSec + 0.00175 * (rate - 60)
    }
    
    public static func qtcHdg(qtInMsec: Double, rate: Double) -> Double {
        return secToMsec(qtcHdg(qtInSec: msecToSec(qtInMsec), rate: rate))
    }

    // Rautaharju (2014) (QTcRTHa)
    public static func qtcRtha(qtInSec: Double, rrInSec: Double) -> Double {
        return qtcRtha(qtInSec: qtInSec, rate: secToBpm(rrInSec))
   }

   public static func qtcRtha(qtInMsec: Double, rrInMsec: Double) -> Double  {
       return secToMsec(qtcRtha(qtInSec: msecToSec(qtInMsec), rate: msecToBpm(rrInMsec)))
   }
    
   public static func qtcRtha(qtInSec: Double, rate: Double) -> Double {
       return qtInSec * (120.0 + rate) / 180.0 
   }
   
   public static func qtcRtha(qtInMsec: Double, rate: Double) -> Double {
       return secToMsec(qtcRtha(qtInSec: msecToSec(qtInMsec), rate: rate))
   }

}

