## Description
This QTc framework includes formulas for QTc calculation, both common and obscure.  It is intended for universal use on both iOS and MacOs devices.  This framework is free to use in your own apps and programs.  NB: This is a work in progress!

## License
This QTc framework is open source, and licensed under the 
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).  When used with Apple devices via the iTunes App Store, it is subject to the [standard Apple iOS license agreement](http://images.apple.com/legal/sla/docs/AppleStoreApp.pdf).

## Installation
Download or clone the project and then drag the QTc.xcodeproj into your project in Xcode.
![figure 1](images/capture1.gif)

In the General tab of the target of your project click the Plus (+) under Linked Frameworks and Libraries and then select the QTc.framework from the dialog box.
![figure 2](images/capture2.gif)

Switch the target for your build to the appropriate Framework (QTc\_iOS or QTc\_Mac) and build the framework.  Afterwards switch the target back to your project.
![figure 3](images/capture3.gif)

Add this import statement to any Swift file using the framework:

    import QTc

To use with an Objective C file add:

    #import <QTc/QTc-Swift.h>

## Using the framework
### Static functions
QTc functions are labeled based on the proposed standard nomenclatue of [Rabkin](https://www.wjgnet.com/1949-8462/full/v7/i6/315.htm#B16).  Thus, for example, Bazett’s QTc formulat is QTcBZT and the Framingham formula is QTcFRM.  All QTc formulas are static functions and can be called like this:

    let qtc = QTc.qtcBzt(qtInSec: 420, rate: 56) // Swift

    double qtc = [QTc qtcBztWithQtInSec: 420, rate: 56]; // Objective C

Each function has 4 different signatures, using QT in sec or msec, RR in sec or msec or heart rate in beats per minute.  Functions using msec parameters return QTc in msec, while those using second parameters return QTc in seconds.  All parameters are Double in Swift, double in Objective C.

You can also call these functions from a single static function with signature:

	let qtc = QTc.qtc(formula: .qtcBzt, qtInSec: 420, rate: 56) // Swift

	double qtc = [QTc qtcWithFormula: Formula.qtcBzt qtInSec: 420 rate: 56]; // Objective C

### QTcCalculatorFactory
You can get an instance of a QTcCalculator using QTcCalculatorFactory.  For example:

    let qtcCalculator = QTcCalculatorFactory(formula .qtcBzt)

Then use the qtcCalculator instance to do calculations and get information about the calculator:

    let qtc = qtcCalculator.calculate(qtInMsec: 345, rate: 74) // qtc = 383
    let qtcCalculatorLongName = qtcCalculator.longName // longName = "Bazett"
    let qtcCalculatorShorName = qtcCalculator.shortName // shortName = "QTcBZT"

### Errors
None of the functions throw exceptions.  However, some QTc formulas have the potential for division by zero or performing fractional power operations on negative numbers.  Parameters are not checked for these problematic inputs.  Division by zero (generally if the RR interval is zero) will result in the value Double.infinity, and zero divided by itself (generally if the QT and RR are both zero) or a fractional root of a negative number (if the RR is negative) will result in Double.nan.  Thus if input parameters are not checked for sanity, it is necessary to check results as follows:

	let qtc = QTc.qtcBzt(qtInMsec: qt, rrInMsec: rr)
	if qtc == Double.infinity || qtc.isNaN {
		Error("Division by zero or root of negative number!")
		return
	} else {
		// carry on
	}

Of course your other option is never to send these bad parameters to the formulas:

	if qt <= 0 || rr <= 0 {
		Error("QT and RR can’t be less than or equal to zero!")
		return
	} else {
		let qtc = QTc.qtcBzt(qtInMsec: qt, rrInMsec: rr)
	}

### Tests
The QTc framework includes numerous unit tests to confirm accuracy, with more coming.

## References (partial list)
- Bazett HC. An analysis of the time relations of electrocardiograms. Heart 1920; 7:353-367.
- Fridericia L. Die sytolendauer in elektrokardiogramm bei normalen menschen und bei herzkranken. Acta Med Scand. 1920;53:469-486.
 - Sagie A, Larson MG, Goldberg RJ, Bengtson JR, Levy D. An improved method for adjusting the QT interval for heart rate (the Framingham Heart Study). Am J Cardiol. 1992;70:797-801.
- Hodges M, Salerno D, Erlien D. Bazett\’s QT correction reviewed: Evidence that a linear QT correction for heart rate is better. J Am Coll Cardiol. 1983;1:1983.
- Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. Int J Cardiol. 2014;174:535-540.
- Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Sch Med Univ Imp. 1934;17:53-55.

More QTc formulas coming!

## Copyright
Copyright © 2017 [EP Studios, Inc.](http://www.epstudiossoftware.com)

## Acknowledgments
The universal framework template was created based on this helpful [Medium post](https://medium.com/@ataibarkai/create-a-universal-swift-framework-for-ios-os-x-watchos-and-tvos-2aa26a8190dc) by Atai Barkai.

## Author
David Mann, MD

Email: [mannd@epstudiossoftware.com](mailto:mannd@epstudiossoftware.com)  
Website: [https://www.epstudiossoftware.com](https://www.epstudiossoftware.com)   

