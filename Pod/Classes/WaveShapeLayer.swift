//
//  WaveShapeLayer.swift
//  Sonar
//
//  Created by Aleš Kocur on 01/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//

import UIKit

class WaveShapeLayer: CAShapeLayer {
    
    override init() {
        super.init()
        self.setNeedsDisplay()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx)
        
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 5), 5.0, UIColor.blackColor().CGColor);

    }
}
