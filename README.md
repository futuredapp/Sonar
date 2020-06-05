# Sonar

[![Build Status](https://app.bitrise.io/app/c8d6d0530984e7d3/status.svg?token=5a_F5V-Bpm1tYAi8IvvLig&branch=master)](https://app.bitrise.io/app/c8d6d0530984e7d3)
[![Version](https://img.shields.io/cocoapods/v/Sonar.svg?style=flat)](http://cocoapods.org/pods/Sonar)
[![License](https://img.shields.io/cocoapods/l/Sonar.svg?style=flat)](http://cocoapods.org/pods/Sonar)
[![Platform](https://img.shields.io/cocoapods/p/Sonar.svg?style=flat)](http://cocoapods.org/pods/Sonar)

<img src=Documentation/screenshot.png width=300 />
<img src=Documentation/sonar-animation.gif width=300 />

Simple radar style view, written in Swift, pure CoreAnimation (no images). Highly adjustable.

## Usage

Just place the UIView somewhere in your controller and make it SonarView class.

SonarView copies the data source and delegate patter from UITableView.

```swift
/// Data source
public weak var dataSource: SonarViewDataSource?

/// SonarViewDelegate and SonarViewLayout
public weak var delegate: SonarViewDelegate?
```
There are three required methods.

```swift
public protocol SonarViewDataSource: class {
    func numberOfWaves(sonarView: SonarView) -> Int
    func sonarView(sonarView: SonarView, numberOfItemForWaveIndex waveIndex: Int) -> Int
    func sonarView(sonarView: SonarView, itemViewForWave waveIndex: Int, atIndex: Int) -> SonarItemView
}
```

`SonarItemView` is just a UIView subclass. In order to use your custom view in radar, make your view SonarItemView subclass. The size of view is determined via layout. The layout is defined by SonarViewLayout protocol. Sonar comes with one predefined layout - SonarViewCenteredLayout. The items in a wave are placed from edges to the center, for example if we have 4 items in wave, first is placed at the left side, second at the right side, third at the left again but a right from the first one and so on. I know, the image would be better:

<img src="Documentation/sonarLayoutScreenshot.png" width="300" />

If you need different behaviour, you can of course create your own layout by adopting the SonarViewLayout and pass it to the SonarView. See [SonarViewLayout](Pod/Classes/SonarViewLayout.swift) for more information.

The last protocol is Delegate which handles selections and titles on each wave

```swift
public protocol SonarViewDelegate: class {
    func sonarView(sonarView: SonarView, didSelectObjectInWave waveIndex: Int, atIndex: Int)
    func sonarView(sonarView: SonarView, textForWaveAtIndex waveIndex: Int) -> String?
}
```

If `distanceForWaveAtIndex` returns nil, the label will be hidden. For more information see the Example project.

### Appearance

There are 3 colours that can be adjusted.

```swift
class public var lineColor: UIColor
class public var lineShadowColor: UIColor
class public var distanceTextColor: UIColor
```

## Contribution

If you need to expose another properties or you have ideas how to improve it, file issue or send pull request, I'll be happy to discuss it.

## Requirements

iOS 8+,

Version 2.x - Swift 2.2+

Version 3.x - Swift 3.0+

Version 4.x - Swift 4.2+

Version 5.x - Swift 5.0+

## Installation

Sonar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Sonar"
```

## Author

Aleš Kocur, aleskocur@icloud.com

## License

Sonar is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
