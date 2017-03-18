//
//  SonarViewLayout.swift
//  Pods
//
//  Created by Aleš Kocur on 15/01/16.
//
//
import UIKit
public protocol SonarViewLayout {

    /**
     Size for item in wave and position

     @param sonarView SonarView which is being layouted
     @param waveIndex Index of wave
     @param index Index inside the wave

     @return Size for item
     */

    func sizeForItem(sonarView: SonarView, inWave waveIndex: Int, atIndex index: Int) -> CGSize

    /**
     Position on the wave line (in percents, value between 0 and 1)

     @param sonarView SonarView which is being layouted
     @param waveIndex Index of wave
     @param index Index of wave

     @return Value between 0 and 1 where 0 is the left begining of the wave and 1 is the right end of the wave
     */

    func positionForItem(sonarView: SonarView, inWave waveIndex: Int, atIndex index: Int) -> Double

    /**
     Position for label on each wave

     @param sonarView SonarView which is being layouted
     @param waveIndex Index of wave

     @return Value between 0 and 1 where 0 is the left begining of the wave and 1 is the right end of the wave
     */

    func positionForWaveLabel(sonarView: SonarView, inWave waveIndex: Int) -> Double

    /**
     Offset for waves

     @param sonarView SonarView which is being layouted

     @return Value between 0 and 1
     */

    func waveRadiusOffset(sonarView: SonarView) -> Double
}
