//
//  WaveLayer.swift
//  Sonar
//
//  Created by Aleš Kocur on 01/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//

import UIKit

enum WavesLayerError: ErrorType {
    case OutOfBounds
}

extension CGFloat {
    func toDegrees() -> CGFloat {
        return self * (180.0 / CGFloat(M_PI))
    }
}

class WavesLayer: CALayer {
    
    private(set) var _numberOfWaves: Int
    private var _needsLayout = true
    private var _waveLayers: [CALayer] = []
    private var _distanceBetweenWaves: CGFloat = 0.0
    weak var _sonarView: SonarView!
    
    init(frame: CGRect, numberOfWaves: Int = 5, sonarView: SonarView) {
        self._sonarView = sonarView
        self._numberOfWaves = numberOfWaves
        super.init()
        self.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: AnyObject) {
        if let l = layer as? WavesLayer {
            self._numberOfWaves = l.numberOfWaves()
            self._sonarView = l._sonarView
            self._waveLayers = l._waveLayers
            self._needsLayout = false
        } else {
            self._numberOfWaves = 5
            assertionFailure("Missuse of the overriden initializatior!")
        }
        super.init(layer: layer)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        if self._needsLayout {
            _needsLayout = false
            drawWaves()
        }
    }
    
    func setNumberOfWaves(numberOfWaves: Int) {
        self._numberOfWaves = numberOfWaves
        _needsLayout = true
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func numberOfWaves() -> Int {
        return _numberOfWaves
    }
    
    private func drawWaves() {
        
        // Clean up existing layers if there are some
        _waveLayers.forEach { $0.removeFromSuperlayer() }
        _waveLayers.removeAll()
        
        // Calculate distance between layers
        _distanceBetweenWaves = calculateDistanceBetweenWaves()
        
        if _numberOfWaves == 0 {
            return
        }
        
        // Draw new layers
        for num in (0..<_numberOfWaves).reverse() {
            let calculatedRadius = CGFloat(num + 1) * _distanceBetweenWaves
            let radius = calculatedRadius + (calculatedRadius * CGFloat(_sonarView.sonarViewLayout.waveRadiusOffset(_sonarView)))
            let layer = self.circleWithRadius(radius: radius)
            layer.frame = self.bounds
            self.addSublayer(layer)
            _waveLayers.append(layer)
            
            let gradientColors = [UIColor.whiteColor().CGColor, UIColor.whiteColor().CGColor, SonarView.lineShadowColor.CGColor]
            let gradientSize = 1.0 - (18 / radius)
            let gradientLocations: [CGFloat] = [0.0, gradientSize, 1.0]
            let gradient = RadialGradientLayer(frame: self.frame, radius: radius - 0.5, center: CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)), colors: gradientColors, locations: gradientLocations)
            self.addSublayer(gradient)
            _waveLayers.append(gradient)
        }
    }
    
    private func calculateDistanceBetweenWaves() -> CGFloat {
        return CGRectGetHeight(self.frame) / CGFloat((_numberOfWaves + 1))

    }
    
    func circleAnglesForRadius(radius r: CGFloat) -> (startAngle: CGFloat, endAngle: CGFloat) {
        let w = Double(CGRectGetWidth(self.frame))
        // Calculate angle α from equation b = 2a × cosα for isosceles triangle
        let b: Double = w < (Double(r) * 2) ? w : Double(r)
        let a = Double(r)
        let alpha = acos(b / (2 * a))
        
        let beta = M_PI - (Double(alpha) * 2)
        
        // Add up half of computed angle to either side from the top of arc (3/2⫪)
        let halfOfBeta = beta / 2
        let M_3_2_PI: Double = (3 / 2) * M_PI // just a 3/2⫪ constant
        // TODO: The rounding is ugly!!!
        let startRad = Double(round(1000 * alpha) / 1000) == Double(round(1000 * beta) / 1000) ? CGFloat(M_PI) : CGFloat(M_3_2_PI - halfOfBeta)
        let endRad = Double(round(1000 * alpha) / 1000) == Double(round(1000 * beta) / 1000) ? CGFloat(2 * M_PI) : CGFloat(M_3_2_PI + halfOfBeta)
        
        return (startAngle: startRad, endAngle: endRad)
    }
    
    private func circleWithRadius(radius r: CGFloat) -> CALayer {
        
        let circlePath = self.circleAnglesForRadius(radius: r)
        let arcCenter = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))
        
        let arc = UIBezierPath(arcCenter: arcCenter, radius: r, startAngle: circlePath.startAngle, endAngle: circlePath.endAngle, clockwise: true)
        let layer = CAShapeLayer()

        layer.path = arc.CGPath
        layer.strokeColor = SonarView.lineColor.CGColor
        layer.frame = self.bounds
        layer.fillColor = UIColor.whiteColor().CGColor
        layer.lineWidth = 1.5
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        return layer
    }
    
    func radiusForWave(waveIndex index: Int) -> CGFloat {
        if index < 0 || index >= _numberOfWaves {
            assertionFailure("*** WavesLayer: Out of range!")
        }
        
        return calculateDistanceBetweenWaves() * (CGFloat(index) + 1)
    }
    
    
}


