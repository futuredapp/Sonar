//
//  SonarViewCenteredLayout.swift
//  Pods
//
//  Created by Aleš Kocur on 15/01/16.
//
//

import Foundation

protocol SonarViewCenteredLayoutDelegate: class {
    func sizeForItem(sonarView: SonarView, inWave waveIndex: Int, atIndex index: Int) -> CGSize
}

class SonarViewCenteredLayout {
    weak var delegate: SonarViewCenteredLayoutDelegate?
    var itemSize: CGSize = CGSizeMake(50, 50)
    var segmentPadding: Double = 2.0
    var paddingFromEdge: Double = 5.0
}

extension SonarViewCenteredLayout: SonarViewLayout {
    
    func sizeForItem(sonarView: SonarView, inWave waveIndex: Int, atIndex index: Int) -> CGSize {
        if let delegate = delegate {
            return delegate.sizeForItem(sonarView, inWave: waveIndex, atIndex: index)
        } else {
            return itemSize
        }
    }
    
    func positionForItem(sonarView: SonarView, inWave waveIndex: Int, atIndex index: Int) -> Double {
        guard let numberOfItemsInWave = sonarView.dataSource?.sonarView(sonarView, numberOfItemForWaveIndex: waveIndex) else {
            assertionFailure("*** SonarViewCenteredLayout: Missing DataSource!")
            return 0.0
        }
        
        if numberOfItemsInWave % 2 == 0 {
            
            let fullSegmentSize: Double = 100.0 // Just a value that represents 100%
            let segmentSize = (fullSegmentSize / Double(numberOfItemsInWave + 2)) + segmentPadding
            let paddingFromEdge: Double = segmentSize - 5.0
            
            if index % 2 == 0 {
                let size = (paddingFromEdge + (Double(index / 2) * segmentSize))
                return size / fullSegmentSize
            } else {
                let size = fullSegmentSize - (paddingFromEdge + (Double((index / 2)) * segmentSize))
                return size / fullSegmentSize
            }
            
        }
        
        return (Double(index + 1) / Double(numberOfItemsInWave + 1))
    }
    
    func positionForWaveLabel(sonarView: SonarView, inWave waveIndex: Int) -> Double {
        return 0.5
    }
}
