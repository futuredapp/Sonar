import UIKit

extension CGFloat {
    func toDegrees() -> CGFloat {
        return self * (180.0 / CGFloat(Double.pi))
    }
}

class WavesLayer: CALayer {

    private(set) var numberOfWaves: Int
    private var needsLayout = true
    private var waveLayers: [CALayer] = []
    private var distanceBetweenWaves: CGFloat = 0.0
    weak var sonarView: SonarView!

    init(frame: CGRect, numberOfWaves: Int = 5, sonarView: SonarView) {
        self.sonarView = sonarView
        self.numberOfWaves = numberOfWaves
        super.init()
        self.frame = frame
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        if let layer = layer as? WavesLayer {
            self.numberOfWaves = layer.numberOfWaves
            self.sonarView = layer.sonarView
            self.waveLayers = layer.waveLayers
            self.needsLayout = false
        } else {
            self.numberOfWaves = 5
            assertionFailure("Missuse of the overriden initializatior!")
        }
        super.init(layer: layer)
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        if self.needsLayout {
            needsLayout = false
            drawWaves()
        }
    }

    func setNumberOfWaves(numberOfWaves: Int) {
        self.numberOfWaves = numberOfWaves
        needsLayout = true
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func drawWaves() {

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            self._drawWaves()
        }

        waveLayers.forEach { layer in

            addAnimation(for: "strokeEnd", layer: layer)
            if let layer = layer as? RadialGradientLayer {

                addAnimation(for: "opacity", layer: layer)
            }
        }

        CATransaction.commit()
    }

    private func addAnimation(for keyPath: String,
                              layer: CALayer,
                              isReverted: Bool = true,
                              beginTime: CFTimeInterval? = nil) {

        let animation = CABasicAnimation(keyPath: keyPath)
        if let beginTime = beginTime {

            animation.beginTime = beginTime
        }
        animation.duration = 0.3
        animation.fromValue = isReverted ? 1.0 : 0.0
        animation.toValue = isReverted ? 0.0 : 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: keyPath)
    }

    private func _drawWaves() {
        // Clean up existing layers if there are some
        waveLayers.forEach { $0.removeFromSuperlayer() }
        waveLayers.removeAll()

        // Calculate distance between layers
        distanceBetweenWaves = calculateDistanceBetweenWaves()

        if numberOfWaves == 0 {
            return
        }

        // Draw new layers
        for num in (0 ..< numberOfWaves).reversed() {
            let calculatedRadius = CGFloat(num + 1) * distanceBetweenWaves
            let radius = calculatedRadius + (calculatedRadius * CGFloat(sonarView.sonarViewLayout.waveRadiusOffset(sonarView: sonarView)))
            let layer = self.circleWithRadius(radius: radius)

            addAnimation(for: "strokeEnd",
                         layer: layer,
                         isReverted: false,
                         beginTime: CACurrentMediaTime() + Double(num) * 0.3)

            layer.strokeEnd = 0.0

            layer.frame = self.bounds
            self.addSublayer(layer)
            waveLayers.append(layer)

            let gradientColors = [UIColor.white.cgColor, UIColor.white.cgColor, SonarView.lineShadowColor.cgColor]
            let gradientSize = 1.0 - (18 / radius)
            let gradientLocations: [CGFloat] = [0.0, gradientSize, 1.0]
            let gradient = RadialGradientLayer(frame: self.frame, radius: radius - 0.5, center: CGPoint(x: self.frame.width / 2, y: self.frame.height), colors: gradientColors, locations: gradientLocations)

            addAnimation(for: "opacity",
                         layer: gradient,
                         isReverted: false,
                         beginTime: CACurrentMediaTime() + Double(num) * 0.3)

            gradient.opacity = 0.0
            self.addSublayer(gradient)
            waveLayers.append(gradient)
        }
    }

    private func calculateDistanceBetweenWaves() -> CGFloat {
        return self.frame.height / CGFloat((numberOfWaves + 1))
    }

    func circleAnglesForRadius(radius: CGFloat) -> (startAngle: CGFloat, endAngle: CGFloat) {
        let width = Double(self.frame.width)
        // Calculate angle α from equation b = 2a × cosα for isosceles triangle
        let b: Double = width < (Double(radius) * 2) ? width : Double(radius)
        let a = Double(radius)
        let alpha = acos(b / (2 * a))

        let beta = Double.pi - (Double(alpha) * 2)

        // Add up half of computed angle to either side from the top of arc (3/2⫪)
        let halfOfBeta = beta / 2
        let piAndHalf = 1.5 * Double.pi // just a 3/2⫪ constant

        let startRad = Double(round(1000 * alpha) / 1000) == Double(round(1000 * beta) / 1000) ? CGFloat(Double.pi) : CGFloat(piAndHalf - halfOfBeta)
        let endRad = Double(round(1000 * alpha) / 1000) == Double(round(1000 * beta) / 1000) ? CGFloat(2 * Double.pi) : CGFloat(piAndHalf + halfOfBeta)

        return (startAngle: startRad, endAngle: endRad)
    }

    private func circleWithRadius(radius: CGFloat) -> CAShapeLayer {

        let circlePath = self.circleAnglesForRadius(radius: radius)
        let arcCenter = CGPoint(x: self.frame.width / 2, y: self.frame.height)

        let arc = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: circlePath.startAngle, endAngle: circlePath.endAngle, clockwise: true)
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
        if index < 0 || index >= numberOfWaves {
            assertionFailure("*** WavesLayer: Out of range!")
        }

        return calculateDistanceBetweenWaves() * (CGFloat(index) + 1)
    }
}
