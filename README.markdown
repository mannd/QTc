## Description
This QTc framework includes formulas for QTc and QTp calculation, both common and obscure.  It is intended for universal use in both iOS and macOS programs.  It is written in Swift but can be used in Objective C projects.  This framework is free to use in your own apps and programs.
*NB: This is a work in progress!  Backwards compatibility is not guaranteed.  We are continuing to add formulas to the framework.*

## Installation
Use Cocoapods to install the framwork.  After installing Cocoapods (see the [Cocoapods site](https://cocoapods.org) for how to do that), add a Podfile like this to the top level directory of your project:

	# Set your target platform
	platform :ios, '11.3'

	target '<MyApp>' do
		# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
		use_frameworks!

		pod 'QTc', :git => 'https://github.com/mannd/QTc.git', :branch => 'master'
	end

At this point in development it is probably best to use the master branch.  Note that the latest version of the QTc framework uses Swift 4.1.

Install the pod by running from the command line within your project directory:

	$ pod install

From then on open the project using the .xcworkspace file, not the .xcodeproj file.

## Using the framework
Add this import statement to any Swift file using the framework:

    import QTc

To use with an Objective C file add:

    #import <QTc/QTc-Swift.h>

## Formulas
QTc and QTp formulas are labeled based on the proposed standard nomenclature of [Rabkin](https://www.wjgnet.com/1949-8462/full/v7/i6/315.htm#B16).  QTc formulas try to correct the QT interval for heart rate.  QTp formulas predict the QT based on heart rate.  Don’t confuse the QTp with the same term QTp used in some recent studies to indicate a corrected QT interval measured to the the peak, rather than the end of the T wave.

Use the enum `Formula` to select QTc or QTp formulas:

	public enum Formula {
		// QTc formulas
		case qtcBzt  // Bazett
		case qtcFrd  // Fridericia
		case qtcFrm  // Framingham
		case qtcHdg  // Hodges
		case qtcRtha // Rautaharju (2014)a
		case qtcMyd  // Mayeda
		case qtcArr  // Arrowood
		case qtcKwt  // Kawataki
		// etc.

		// QTp formulas
		case qtpBzt  // Bazett
		case qtpFrd  // Fridericia
		// etc.
		}

There is also an enum `FormulaType`:

	public enum FormulaType {
		case .qtc
		case .qtp
	}

You can get the FormulaType from a Formula:

	let formulaType = Formula.qtcBzt.formulaType() // formulaType == FormulaType.qtc

## Calculators
### The easy way
The easiest way to get a calculator for a specific formula is to generate one using this static factory class:

	let calculator = QTc.calculator(formula: .qtcBzt) // generates a Bazett QTc calculator (Swift)

	Calculator calculator = [QTc calculatorWithFormula: Formula.qtcBzt]; // Qbjective C

(Note that most of the examples are given as Swift code.  See [Apple’s reference](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) for more information on calling Swift functions from Objective C.

Here is a QTp calculator:

	let qtpCalculator = QTc.calculator(formula: .qtpFrd) // Friedericia QTp calculator

QTc and QTp calculators are subclasses of the class `Calculator`.  Using a calculator generated in this way to calculate a QTc or QTp requires passing a `QtMeasurment` struct to the calculator.

### QtMeasurement

The `QtMeasurement` struct is a convenient way to package the measurements required for a QTc or QTp calculation.  It is defined as:

	public struct QtMeasurement {
		public let qt: Double? // an optional, since QT not needed for QTp
		public let intervalRate: Double  // RR interval or HR
		public let units: Units // may be .msec or .sec
		public let intervalRateType: IntervalRateType // may be .bpm or .interval
		public let sex: Sex = .unspecified // .male or .female, not required by many formulas
		public let age: Int? = nil  // may be nil as not always needed
	}

Units can be .msec or .sec, and IntervalRateType either .bpm or .interval (meaning the heart rate is given as beats per minute or an RR interval).  Sex is .male, .female, or .unspecified (not all formulas require sex or age).  A complete example for calculating a QTc interval using the Bazett formula is as follows.

	let qtMeasurement = QtMeasurement(qt: 367.0, intervalRate: 777.0, units: .msec, intervalRateType: .interval)
	let qtcBztCalculator = QTc.calculator(formula: .qtcBzt)
	let qtc = qtcBztCalculator.calculate(qtMeasurement) // qtc = 416.34711041

Note that if the QtMeasurement units are msec, the calculator returns a result in msec; if the units are secs, the result is also in secs.

### More ways to calculate (aka the less easy way)
If you are less interested in a universal calculator object, that handles QTc and QTp calculations the same way, you can instantiate specific QTc and QTp calculator classes.  These classes don’t require use of the QtMeasurement struct and you pass to their calculate methods parameters in secs or msecs directly.  The classes are `QTcCalculator` and `QTpCalculator`.

For example:

	let qtcBztCalculator = QTc.qtcCalculator(formula: .qtcBzt) // Swift

	QTcCalculator qtcBztCalculator = [QTc qtcCalculatorWithFormula: Formula.qtcBzt]; // Objective C

Then use the calculator to calculate the QTc:

	let qtcBzt = qtcBztCalculator.calculate(qtInSec: 0.334, rrInSec: 0.785) // Swift

	double qtcBzt = [qtcBztCalculator calculateWithQtInSec: 0.334 rrInSec: 0.785]; // Objective C

### Calculate functions
When using the `QTcCalculator` or `QTpCalculator` classes, each calculate function has 4 different signatures, using QT in sec or msec, RR in sec or msec or heart rate in beats per minute.  Functions using msec parameters return QTc in msec, while those using second parameters return QTc in seconds.  All interval/rate parameters are Double in Swift, double in Objective C.  For example:

	let qtcInMsec = qtcBztCalculator.calculate(qtInMsec: 402, rate 72) // returns QTc in msec
	let qtcInSec = qtcBztCalculator.calculate(qtInSec: 0.402, rate 72) // returns QTc in sec

## QTp formulas and formulas depending on sex and/or age
QTp formulas are similar to the QTc formulas, except there is no QT parameter.  Only rate or RR interval is needed to calculate the QTp.

Some QTc and QTp formulas are age and or sex dependent.  In this case add a sex: and/or age: parameter to the calling function.  For example:

	let qtpBdl = QTc.qtpCalculator(formula: .qtpBdl)
	let qtpInSec = qtpBdl.calculate(rrInSec: 77, sex: .male)

Note that in this case the formula uses sex but not age.  If you include extra age or sex parameters that are not used by the formula they will be ignored.  However failure to include a necessary parameter will result in the function throwing an exception (see below).

### Other calculator variables and functions
You can get other information from the calculator instance, for example:

	let qtcCalculator = QTc.qtcCalculator(formula: .qtcBzt)
    let longName = qtcCalculator.longName // "Bazett"
    let shorName = qtcCalculator.shortName // "QTcBZT"
	let reference = qtcCalculator.reference // literature reference in AMA style
	let notes = qtcCalculator.notes // facts about this formula
	let classification = qtcCalculator.classification // .power
	// this is the type of mathematical equation: .power, .linear, .exponential, etc.
	let date = qtcCalculator.publicationDate // year of publication
	let numberOfSubjects = qtcCalculator.numberOfSubjects // number of subjects studied

## Errors
### Mathematical errors
Some QTc and QTp formulas have the potential for division by zero or performing fractional power operations on negative numbers.  Parameters are not checked for these problematic inputs.  Division by zero (generally if the RR interval is zero) will result in the value Double.infinity, and zero divided by itself (generally if the QT and RR are both zero) or a fractional root of a negative number (if the RR is negative) will result in Double.nan.  Thus if input parameters are not checked for sanity, it is necessary to check results as follows:

	let qtc = QTc.qtcCalculator(formula: .qtcBzt).calculate(qtInMsec: qt, rrInMsec: rr)
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
		let qtc = QTc.qtcCalculator(formula: .qtcBzt).calculate(qtInMsec: qt, rrInMsec: rr)
	}

### Exceptions
Calculate methods of calculators can throw exceptions in certain situations.  For example, if you have a qt of nil in your `QtMeasurement` struct and pass this to a calculate method of a QTc calculator, a `CalculationError.qtMissing` exception will be thrown.  Similarly if a calculator from a formula requires that a sex parameter is provided and it isn’t, a `CalculationError.sexRequired` exception will be thrown.  See the `CalculationError` enum in QTc.swift for a complete list of possible exceptions.  Make sure you code includes exception handling for the calculate functions.

## Conversion functions
The QTc framework includes static functions to do common conversions, between seconds, milliseconds and heart rate, e.g.:

	let intervalInSec = 0.890
	let intervalInMsec = QTc.secToMsec(intervalInSec) // = 890
	let rate = QTc.msecToBpm(intervalInMsec) // = 67.41573

These functions don’t throw, but as with the calculate functions, division by zero will result in Double.infinity.

## Tests
The QTc framework includes numerous unit tests to confirm accuracy.

## You can help
No I am **not** asking for money!  No Patreon or Kickstarter!  If you are an academic electrophysiologist or cardiologist and have access to an online medical digital library, you can help.  Most of the journal articles that are sources here are shamelessly paywalled and difficult if not impossible for a retired EP like myself without an academic affiliation to obtain.  Even Bazett’s almost 100 year old original QT article is behind a paywall!  If you are willing to download and forward articles to me, that would be wonderful.  Your name will be added to this README, and you get the satisfaction of knowing you have contributed to the open sourcing of scientific knowledge, which should be freely available to all.  Please email me at [mannd@epstudiossoftware.com](mannd@epstudiossoftware.com) if you are interested in contributing and I can provide you with a list of articles.

Additionally, if you know of QTc or QTp formulas which are omitted here and need to be included, please email me or contact me on Twitter (@manndmd).

## Demo program
[**EP QTc**](https://github.com/mannd/EP-QTc) is a demo program that I am writing and that will be available for download on the Apple App Store in the near future.  With it, you can calculate all the QTc and QTp formulas at once, see a graph of intervals, determine some statistics on the formulas, investigate each formula individually, and just generally have a bunch of good clean EP QT fun.

## References
See the file *Formulas.swift* for an updated list of references.

## License
This QTc framework is open source, and licensed under the 
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).  When used with Apple devices via the iTunes App Store, it is subject to the [standard Apple iOS license agreement](http://images.apple.com/legal/sla/docs/AppleStoreApp.pdf).

## Copyright
Copyright © 2017, 2018 [EP Studios, Inc.](http://www.epstudiossoftware.com)

## Acknowledgments
Thanks to Marian Stiehler for help in acquiring the original literature that forms the basis of these QTc and QTp formulas!

The universal framework template was created based on this helpful [Medium post](https://medium.com/@ataibarkai/create-a-universal-swift-framework-for-ios-os-x-watchos-and-tvos-2aa26a8190dc) by Atai Barkai.

## Author
David Mann, MD

Email: [mannd@epstudiossoftware.com](mailto:mannd@epstudiossoftware.com) 
Website: [https://www.epstudiossoftware.com](https://www.epstudiossoftware.com) 

