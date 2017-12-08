## Description
This QTc framework includes formulas for QTc calculation, both common and obscure.  It is intended for universal use on both iOS and MacOs devices.  This framework is free to use in your own apps and programs.  *NB: This is a work in progress!  I cannot guarantee backward compatibility of subsequent versions, regardless of version numbers, until things settle down!*

## Installation
### The easy way
Use Cocoapods to install the framwork.  After installing Cocoapods (see the [Cocoapods site](https://cocoapods.org) for how to do that), add a Podfile like this to the top level directory of your project:

	# Set your target platform
	platform :ios, '11.1'

	target '<MyApp>' do
		# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
		use_frameworks!

		pod 'QTc', :git => 'https://github.com/mannd/QTc.git', :branch => 'master'
	end

At this point in development it is probably best to use the master branch.  Note that the QTc framework uses Swift 4.

Install the pod by running from the command line within your project directory:

	$ pod install

From then on open the project using the .xcworkspace file, not the .xcodeproj file.

### The hard way
Download or clone the project and then drag the QTc.xcodeproj into your project in Xcode.
![figure 1](images/capture1.gif)

In the General tab of the target of your project click the Plus (+) under Linked Frameworks and Libraries and then select the QTc.framework from the dialog box.
![figure 2](images/capture2.gif)

Switch the target for your build to the appropriate Framework (QTc\_iOS or QTc\_Mac) and build the framework.  Afterwards switch the target back to your project.
![figure 3](images/capture3.gif)

You can then if you wish, make the library a git submodule within your app.  This is non-trivial, but [this Medium post](https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407) covers it well.

## Using the framework
Add this import statement to any Swift file using the framework:

    import QTc

To use with an Objective C file add:

    #import <QTc/QTc-Swift.h>

QTc functions are labeled based on the proposed standard nomenclature of [Rabkin](https://www.wjgnet.com/1949-8462/full/v7/i6/315.htm#B16).  Use the enum QTcFormula to select the QTc function:

	public enum QTcFormula {
		case qtcBzt  // Bazett
		case qtcFrd  // Fridericia
		case qtcFrm  // Framingham
		case qtcHdg  // Hodges
		case qtcRtha // Rautaharju (2014)a
		case qtcMyd  // Mayeda
		case qtcArr  // Arrowood
		case qtcKwt  // Kawataki
		// more coming
	}

QTp functions predict the QT based on the RR interval.  They are listed in the QTpFormula enum:

	public enum QTpFormula {
		case qtpArr  // Arrowood
		case qtpBdl  // Boudoulas
		case qtpAsh  // Ashman
		// etc.
	}

Generate a qtcCalculator class using the static function QTc.qtcCalculator(formula: QTcFormula) as shown below.

	let qtcBztCalculator = QTc.qtcCalculator(formula: .qtcBzt) // Swift

	QTcCalculator qtcBztCalculator = [QTc qtcCalculatorWithFormula: QTcFormula.qtcBzt]; // Objective C

Then use the calculator to calculate the QTc:

	let qtcBzt = qtcBztCalculator.calculate(qtInSec: 0.334, rrInSec: 0.785) // Swift

	double qtcBzt = [qtcBztCalculator calculateWithQtInSec: 0.334 rrInSec: 0.785]; // Objective C

Each function has 4 different signatures, using QT in sec or msec, RR in sec or msec or heart rate in beats per minute.  Functions using msec parameters return QTc in msec, while those using second parameters return QTc in seconds.  All parameters are Double in Swift, double in Objective C.  For example:

	let qtcInMsec = qtcBztCalculator.calculate(qtInMsec: 402, rate 72) // returns QTc in msec

	let qtcInSec = qtcBztCalculator.calculate(qtInSec: 0.402, rate 72) // returns QTc in sec

You can get other information from the calculator instance, for example:

	let qtcCalculator = QTc.qtcCalculator(formula: .qtcBzt)
    let qtcCalculatorLongName = qtcCalculator.longName // longName = "Bazett"
    let qtcCalculatorShorName = qtcCalculator.shortName // shortName = "QTcBZT"
	let qtcCalculatorReference = qtcCalculator.reference // reference = full literature reference of the formula
	let qtcCalculatorNotes = qtcCalculator.notes // notes = "Oldest, most common formula, but inaccurate at extremes of heart rate"
	let qtcCalculatorClassification = qtcCalculator.classification // classification = .power
	// this is the type of mathematical equation: .power, .linear, .exponential, etc.

## QTp formulas and formulas depending on sex and/or age
QTp formulas are similar to the QTc formulas, except there is no QT parameter.  Only rate or RR interval is needed to calculate the QTp.

Some QTc and QTp formulas are age and or sex dependent.  In this case add a sex: and/or age: parameter to the calling function.  For example:

	let qtpBdl = QTc.qtpCalculator(formula: .qtpBdl)
	let qtpInSec = qtpBdl.calculate(rrInSec: 77, sex: .male)

Note that in this case the formula uses sex but not age.  If you include extra age or sex parameters that are not used by the formula they will be ignored.  However failure to include a necessary parameter will result in the return of an error (Double.nan, see next section).

## Errors
None of the functions throw exceptions.  However, some QTc formulas have the potential for division by zero or performing fractional power operations on negative numbers.  Parameters are not checked for these problematic inputs.  Division by zero (generally if the RR interval is zero) will result in the value Double.infinity, and zero divided by itself (generally if the QT and RR are both zero) or a fractional root of a negative number (if the RR is negative) will result in Double.nan.  Thus if input parameters are not checked for sanity, it is necessary to check results as follows:

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

## Conversion functions
The QTc framework includes static functions to do common conversions, between seconds, milliseconds and heart rate, e.g.:

	let intervalInSec = 0.890
	let intervalInMsec = QTc.secToMsec(intervalInSec) // = 890
	let rate = QTc.msecToBpm(intervalInMsec) // = 67.41573

## Tests
The QTc framework includes numerous unit tests to confirm accuracy.

## You can help
No I am **not** asking for money!  No Patreon or Kickstarter!  If you are an academic electrophysiologist or cardiologist and have access to an online medical digital library, you can help.  Most of the journal articles that are sources here are shamelessly paywalled and difficult if not impossible for a retired EP like myself without an academic affiliation to obtain.  Even Bazett’s almost 100 year old original QT article is behind a paywall!  If you are willing to download and forward articles to me, that would be wonderful.  Your name will be added to this README, and you get the satisfaction of knowing you have contributed to the open sourcing of scientific knowledge, which should be freely available to all.  Please email me at [mannd@epstudiossoftware.com](mannd@epstudiossoftware.com) if you are interested in contributing and I can provide you with a list of articles.

Additionally, if you know of QTc or QTp formulas which are omitted here and need to be included, please email me or contact me on Twitter (@manndmd).

## Demo program
**EP QTc** is a demo program that I am writing and that will be available for download on the Apple App Store in the near future.  With it, you can calculate all the QTc formulas at once, see a graph of QTc intervals, calculate the QTu (ultimate QTc -- an average of all these formulas), investigate each formula individually, and just generally have a bunch of good clean EP QT fun.

## References (partial list)
- Bazett HC. An analysis of the time relations of electrocardiograms. Heart 1920; 7:353-367.
- Fridericia L. Die sytolendauer in elektrokardiogramm bei normalen menschen und bei herzkranken. Acta Med Scand. 1920;53:469-486.
- Sagie A, Larson MG, Goldberg RJ, Bengtson JR, Levy D. An improved method for adjusting the QT interval for heart rate (the Framingham Heart Study). Am J Cardiol. 1992;70:797-801.
- Hodges M, Salerno D, Erlien D. Bazett\’s QT correction reviewed: Evidence that a linear QT correction for heart rate is better. J Am Coll Cardiol. 1983;1:1983.
- Rautaharju PM, Mason JW, Akiyama T. New age- and sex-specific criteria for QT prolongation based on rate correction formulas that minimize bias at the upper normal limits. Int J Cardiol. 2014;174:535-540.
- Mayeda I. On time relation between systolic duration of heart and pulse rate. Acta Sch Med Univ Imp. 1934;17:53-55.
- Arrowood JA, Kline J, Simpson PM, Quigg RJ, Pippin JJ, Nixon JV, Mohrnty PK.  Modulation of the QT interval: effects of graded exercise and reflex cardiovascular stimulation.  J Appl Physiol. 1993;75:2217-2223.
- Kawataki M, Kashima T, Toda H, Tanaka H. Relation between QT interval and heart rate. applications and limitations of Bazett’s formula. J Electrocardiol. 1984;17:371-375.
- Dmitrienko AA, Sides GD, Winters KJ, et al. Electrocardiogram reference ranges derived from a standardized clinical trial population. Drug Inf J. 2005;39:395–405.
- Yoshinaga M, Tomari T, Aihoshi S, et al.  Exponential correction of QT interval to minimize the effect of the heart rate in children.  Jpn Circ J.  1993;57:102-108. 
- Boudoulas H, Geleris P, Lewis RP, Rittgers SE.  Linear relationship between electrical systole, mechanical systole, and heart rate.  Chest 1981;80:613-617.
- Ashman r.  The normal duration of the Q-T interval.  Am Heart J 1942;23:522-534. 

More QTc formulas coming!

## License
This QTc framework is open source, and licensed under the 
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).  When used with Apple devices via the iTunes App Store, it is subject to the [standard Apple iOS license agreement](http://images.apple.com/legal/sla/docs/AppleStoreApp.pdf).
## Copyright
Copyright © 2017 [EP Studios, Inc.](http://www.epstudiossoftware.com)

## Acknowledgments
The universal framework template was created based on this helpful [Medium post](https://medium.com/@ataibarkai/create-a-universal-swift-framework-for-ios-os-x-watchos-and-tvos-2aa26a8190dc) by Atai Barkai.

## Author
David Mann, MD

Email: [mannd@epstudiossoftware.com](mailto:mannd@epstudiossoftware.com) 
Website: [https://www.epstudiossoftware.com](https://www.epstudiossoftware.com) 

