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

    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 25
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.clipsToBounds = true
    }

}
