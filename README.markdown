## Description
This QTc framework is intended for universal use with both iOS and MacOs devices.  The framework includes formulas for QTc calculation, both common and obscure.

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
QTc functions are labeled based on the proposed standard nomenclatue of [Rabkin](https://www.wjgnet.com/1949-8462/full/v7/i6/315.htm#B16).  Thus, for example, Bazett’s QTc formulat is QTcBZT and the Framingham formula is QTcFRM.  All QTc formulas are static functions and are called like:

    let qtc = QTc.qtcBzt(qtInSec: 420, rate: 56) // Swift

    double qtc = [QTc qtcBztWithQtInSec: 420, rate: 56]; // Objective C

Each function has 4 different signatures, using QT in sec or msec, RR in sec or msec or heart rate in beats per minute.  Functions using msec parameters return QTc in msec, while those using second parameters return QTc in seconds.  All parameters are Double in Swift, double in Objective C.

### QTcCalculator factory
You can get an instance of a QTcCalculator using QTcCalculatorFactory.  For example:

    let qtcCalculator = QTcCalculatorFactory(formula .qtcBzt)

Then use the qtcCalculator instance to do calculations and get information about the calculator:

    let qtc = qtcCalculator.calculate(qtInMsec: 345, rate: 74) // qtc = 383
    let qtcCalculatorLongName = qtcCalculator.longName // longName = "Bazett"
    let qtcCalculatorShorName = qtcCalculator.shortName // shortName = "QTcBZT"

## Copyright
Copyright © 2017 [EP Studios, Inc.](http://www.epstudiossoftware.com)

## Acknowledgments
TBD.
The universal framework template was created based on this helpful [Medium post](https://medium.com/@ataibarkai/create-a-universal-swift-framework-for-ios-os-x-watchos-and-tvos-2aa26a8190dc) by Atai Barkai.

## Author
David Mann, MD

Email: [mannd@epstudiossoftware.com](mailto:mannd@epstudiossoftware.com)  
Website: [https://www.epstudiossoftware.com](https://www.epstudiossoftware.com)   

