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
    
    var _needDraw = true
    
    let colors: [CGColor]
    
    init(frame: CGRect, radius: CGFloat, center: CGPoint, colors: [CGColor], locations: [CGFloat] = [0.0, 1.0]){
        self.colors = colors
        self.radius = radius
        self.center = center
        self.locations = locations
        
        super.init()
        
        self.frame = frame
        self.setNeedsDisplay()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
    }
    
    override func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx)
        if _needDraw {
            _needDraw = false
            
            CGContextSaveGState(ctx)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
            
            
            print("drawing gradient - center:\(self.center) radius:\(radius)")
            CGContextDrawRadialGradient(ctx, gradient, self.center, 0.0, self.center, radius, CGGradientDrawingOptions(rawValue: 0))
        }
    }
    
}

