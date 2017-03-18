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

    init(frame: CGRect, radius: CGFloat, center: CGPoint, colors: [CGColor], locations: [CGFloat] = [0.0, 1.0]) {
        self.colors = colors
        self.radius = radius
        self.center = center
        self.locations = locations

        super.init()

        self.rasterizationScale = UIScreen.main.scale * 2
        self.shouldRasterize = true
        self.frame = frame
        self.setNeedsDisplay()
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)

        ctx.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)

        ctx.drawRadialGradient(gradient!, startCenter: self.center, startRadius: 0.0, endCenter: self.center, endRadius: radius, options: CGGradientDrawingOptions(rawValue: 0))
    }
}
