//
//  RadialGradienLayer.swift
//  Sonar
//
//  Created by Aleš Kocur on 13/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//

import UIKit

class RadialGradientLayer: CALayer {
    
    let radius: CGFloat
    let center: CGPoint
    let locations: [CGFloat]
    
    let colors: [CGColor]
    
    init(frame: CGRect, radius: CGFloat, center: CGPoint, colors: [CGColor], locations: [CGFloat] = [0.0, 1.0]){
        self.colors = colors
        self.radius = radius
        self.center = center
        self.locations = locations
        
        super.init()
        
        self.rasterizationScale = UIScreen.mainScreen().scale * 2
        self.shouldRasterize = true
        self.frame = frame
        self.setNeedsDisplay()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx)
        
        CGContextSaveGState(ctx)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        
        CGContextDrawRadialGradient(ctx, gradient, self.center, 0.0, self.center, radius, CGGradientDrawingOptions(rawValue: 0))
        
    }
    
}

