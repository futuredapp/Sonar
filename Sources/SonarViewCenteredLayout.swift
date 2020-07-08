//
//  SonarViewCenteredLayout.swift
//  Pods
//
//  Created by Aleš Kocur on 15/01/16.
//
//
import Foundation
import UIKit

public protocol SonarViewCenteredLayoutDelegate: class {
    func sizeForItem(sonarView: SonarView, inWave waveIndex: Int, atIndex index: Int) -> CGSize
}

public class SonarViewCenteredLayout {
    public weak var delegate: SonarViewCenteredLayoutDelegate?
    public var itemSize: CGSize = CGSize(width: 50, height: 50)
    public var segmentPadding: Double = 0.0
    public var edgeItemsShift: Double = 6.0
    public var waveRadiusOffset: Double = 0.0
}

extension SonarViewCenteredLayout: SonarViewLayout {

    public func sizeForItem(sonarView: SonarView, inWave waveIndex: Int, atIndex index: Int) -> CGSize {
        if let delegate = delegate {
            return delegate.sizeForItem(sonarView: sonarView, inWave: waveIndex, atIndex: index)
        } else {
            return itemSize
        }
    }

    public func positionForItem(sonarView: SonarView, inWave waveIndex: Int, atIndex index: Int) -> Double {
        guard let numberOfItemsInWave = sonarView.dataSource?.sonarView(sonarView: sonarView, numberOfItemForWaveIndex: waveIndex) else {
            assertionFailure("*** SonarViewCenteredLayout: Missing DataSource!")
            return 0.0
        }

        if numberOfItemsInWave % 2 == 0 {

            let fullSegmentSize: Double = 100.0 // Just a value that represents 100%
            let segmentSize = (fullSegmentSize / Double(numberOfItemsInWave + 1)) + segmentPadding
            let padding: Double = segmentSize - edgeItemsShift

            if index % 2 == 0 {
                let size = (padding + (Double(index / 2) * segmentSize))
                return size / fullSegmentSize
            } else {
                let size = fullSegmentSize - (padding + (Double((index / 2)) * segmentSize))
                return size / fullSegmentSize
            }
        }

        return (Double(index + 1) / Double(numberOfItemsInWave + 1))
    }

    public func positionForWaveLabel(sonarView _: SonarView, inWave _: Int) -> Double {
        return 0.5
    }

    public func waveRadiusOffset(sonarView _: SonarView) -> Double {
        return waveRadiusOffset
    }
}
