//
//  SonarItemView.swift
//  Sonar
//
//  Created by Aleš Kocur on 13/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//

import UIKit

public struct SonarPosition {
    let waveIndex: Int
    let itemIndex: Int
}

open class SonarItemView: UIView {
    var position: SonarPosition!
}
