//
//  WaveLayer.swift
//  Sonar
//
//  Created by Aleš Kocur on 01/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//
import UIKit

enum WavesLayerError: Error {
    case OutOfBounds
}

extension CGFloat {
    func toDegrees() -> CGFloat {
        return self * (180.0 / CGFloat(Double.pi))
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

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
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

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            self._drawWaves()
        }

        _waveLayers.forEach { layer in
            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.duration = 0.3
            strokeAnimation.fromValue = 1.0
            strokeAnimation.toValue = 0.0
            strokeAnimation.isRemovedOnCompletion = false
            strokeAnimation.fillMode = kCAFillModeForwards
            layer.add(strokeAnimation, forKey: "strokeEnd")

            if let layer = layer as? RadialGradientLayer {
                let displayAnimation = CABasicAnimation(keyPath: "opacity")
                displayAnimation.duration = 0.3
                displayAnimation.fromValue = 1.0
                displayAnimation.toValue = 0.0
                displayAnimation.isRemovedOnCompletion = false
                displayAnimation.fillMode = kCAFillModeForwards
                layer.add(displayAnimation, forKey: "opacity")
            }
        }

        CATransaction.commit()
    }

    private func _drawWaves() {
        // Clean up existing layers if there are some
        _waveLayers.forEach { $0.removeFromSuperlayer() }
        _waveLayers.removeAll()

        // Calculate distance between layers
        _distanceBetweenWaves = calculateDistanceBetweenWaves()

        if _numberOfWaves == 0 {
            return
        }

        // Draw new layers
        for num in (0 ..< _numberOfWaves).reversed() {
            let calculatedRadius = CGFloat(num + 1) * _distanceBetweenWaves
            let radius = calculatedRadius + (calculatedRadius * CGFloat(_sonarView.sonarViewLayout.waveRadiusOffset(sonarView: _sonarView)))
            let layer = self.circleWithRadius(radius: radius)

            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.duration = 0.3
            strokeAnimation.beginTime = CACurrentMediaTime() + Double(num) * 0.3
            strokeAnimation.fromValue = 0.0
            strokeAnimation.toValue = 1.0
            strokeAnimation.isRemovedOnCompletion = false
            strokeAnimation.fillMode = kCAFillModeForwards

            layer.add(strokeAnimation, forKey: "strokeEnd")

            layer.strokeEnd = 0.0

            layer.frame = self.bounds
            self.addSublayer(layer)
            _waveLayers.append(layer)

            let gradientColors = [UIColor.white.cgColor, UIColor.white.cgColor, SonarView.lineShadowColor.cgColor]
            let gradientSize = 1.0 - (18 / radius)
            let gradientLocations: [CGFloat] = [0.0, gradientSize, 1.0]
            let gradient = RadialGradientLayer(frame: self.frame, radius: radius - 0.5, center: CGPoint(x: self.frame.width / 2, y: self.frame.height), colors: gradientColors, locations: gradientLocations)

            let displayAnimation = CABasicAnimation(keyPath: "opacity")
            displayAnimation.duration = 0.3
            displayAnimation.beginTime = CACurrentMediaTime() + Double(num) * 0.3
            displayAnimation.fromValue = 0.0
            displayAnimation.toValue = 1.0
            displayAnimation.isRemovedOnCompletion = false
            displayAnimation.fillMode = kCAFillModeForwards

            gradient.add(displayAnimation, forKey: "opacity")

            gradient.opacity = 0.0
            self.addSublayer(gradient)
            _waveLayers.append(gradient)
        }
    }

    private func calculateDistanceBetweenWaves() -> CGFloat {
        return self.frame.height / CGFloat((_numberOfWaves + 1))
    }

    func circleAnglesForRadius(radius r: CGFloat) -> (startAngle: CGFloat, endAngle: CGFloat) {
        let w = Double(self.frame.width)
        // Calculate angle α from equation b = 2a × cosα for isosceles triangle
        let b: Double = w < (Double(r) * 2) ? w : Double(r)
        let a = Double(r)
        let alpha = acos(b / (2 * a))

        let beta = Double.pi - (Double(alpha) * 2)

        // Add up half of computed angle to either side from the top of arc (3/2⫪)
        let halfOfBeta = beta / 2
        let M_3_2_PI: Double = (3 / 2) * Double.pi // just a 3/2⫪ constant
        // TODO: The rounding is ugly!!!
        let startRad = Double(round(1000 * alpha) / 1000) == Double(round(1000 * beta) / 1000) ? CGFloat(Double.pi) : CGFloat(M_3_2_PI - halfOfBeta)
        let endRad = Double(round(1000 * alpha) / 1000) == Double(round(1000 * beta) / 1000) ? CGFloat(2 * Double.pi) : CGFloat(M_3_2_PI + halfOfBeta)

        return (startAngle: startRad, endAngle: endRad)
    }

    private func circleWithRadius(radius r: CGFloat) -> CAShapeLayer {

        let circlePath = self.circleAnglesForRadius(radius: r)
        let arcCenter = CGPoint(x: self.frame.width / 2, y: self.frame.height)

        let arc = UIBezierPath(arcCenter: arcCenter, radius: r, startAngle: circlePath.startAngle, endAngle: circlePath.endAngle, clockwise: true)
        let layer = CAShapeLayer()

        layer.path = arc.cgPath
        layer.strokeColor = SonarView.lineColor.cgColor
        layer.frame = self.bounds
        layer.fillColor = UIColor.white.cgColor
        layer.lineWidth = 1.5
        layer.rasterizationScale = UIScreen.main.scale

        return layer
    }

    func radiusForWave(waveIndex index: Int) -> CGFloat {
        if index < 0 || index >= _numberOfWaves {
            assertionFailure("*** WavesLayer: Out of range!")
        }

        return calculateDistanceBetweenWaves() * (CGFloat(index) + 1)
    }
}
