//
//  TestSonarItemView.swift
//  Sonar
//
//  Created by Aleš Kocur on 13/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//

import UIKit
import Sonar

class TestSonarItemView: SonarItemView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.redColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
