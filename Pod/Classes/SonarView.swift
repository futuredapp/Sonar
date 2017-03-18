//
//  SonarView.swift
//  Sonar
//
//  Created by Aleš Kocur on 13/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//
import UIKit

public protocol SonarViewDataSource: class {
    func numberOfWaves(sonarView: SonarView) -> Int
    func sonarView(sonarView: SonarView, numberOfItemForWaveIndex waveIndex: Int) -> Int
    func sonarView(sonarView: SonarView, itemViewForWave waveIndex: Int, atIndex: Int) -> SonarItemView
}

public protocol SonarViewDelegate: class {
    func sonarView(sonarView: SonarView, didSelectObjectInWave waveIndex: Int, atIndex: Int)
    func sonarView(sonarView: SonarView, textForWaveAtIndex waveIndex: Int) -> String?
}

public class SonarView: UIView {

    // Private properties
    private var waveLayer: WavesLayer!
    private var _itemViews: [SonarItemView] = []
    private var _shadows: [RadialGradientLayer] = []
    private var _labels: [UIView] = []
    private var _needsLayout = false

    // Public properties
    /// For SonarViewDelegate and SonarViewLayout
    public weak var delegate: SonarViewDelegate?
    public weak var dataSource: SonarViewDataSource? {
        didSet {
            self.reloadData()
        }
    }

    public static var lineColor: UIColor = UIColor(red: 0.898, green: 0.969, blue: 0.980, alpha: 1.00)
    public static var lineShadowColor: UIColor = UIColor(red: 0.949, green: 0.988, blue: 0.992, alpha: 1.00)
    public static var distanceTextColor: UIColor = UIColor(red: 0.663, green: 0.878, blue: 0.925, alpha: 1.00)

    public var sonarViewLayout: SonarViewLayout!

    public required init?(coder aDecoder: NSCoder) {
        self.sonarViewLayout = SonarViewCenteredLayout()
        super.init(coder: aDecoder)
        self.setup()
    }

    override init(frame: CGRect) {
        self.sonarViewLayout = SonarViewCenteredLayout()
        super.init(frame: frame)
        self.setup()
    }

    // Initial setup
    private func setup() {
        self.waveLayer = WavesLayer(frame: self.bounds, sonarView: self)
        self.waveLayer.shouldRasterize = true
        self.waveLayer.rasterizationScale = UIScreen.main.scale
        self.layer.addSublayer(self.waveLayer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if _needsLayout {
            waveLayer.frame = self.bounds
            _needsLayout = false
            _reloadData()
        }
    }

    // MARK: - Public API

    public func reloadData() {
        _needsLayout = true
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    // MARK: - Private

    private func _reloadData() {

        guard let dataSource = self.dataSource else {
            return
        }

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self._itemViews.forEach { $0.alpha = 0.0 }
        }) { _ in

            let numberOfWaves = dataSource.numberOfWaves(sonarView: self)
            self.waveLayer.setNumberOfWaves(numberOfWaves: numberOfWaves)

            self._itemViews.forEach { $0.removeFromSuperview() }
            self._itemViews.removeAll()
            self._shadows.forEach { $0.removeFromSuperlayer() }
            self._shadows.removeAll()
            self._labels.forEach { $0.removeFromSuperview() }
            self._labels.removeAll()

            for waveIndex in 0 ..< numberOfWaves {
                let numberOfItemsInWave = dataSource.sonarView(sonarView: self, numberOfItemForWaveIndex: waveIndex)
                if let textForWave = self.delegate?.sonarView(sonarView: self, textForWaveAtIndex: waveIndex) {
                    let distanceLabel = SonarView.distanceLabel()
                    distanceLabel.text = textForWave
                    distanceLabel.alpha = 0.0

                    self._labels.append(distanceLabel)
                    self.addSubview(distanceLabel)

                    let calculatedRadius = Double(self.waveLayer.radiusForWave(waveIndex: waveIndex))
                    let radius = calculatedRadius + (calculatedRadius * self.sonarViewLayout.waveRadiusOffset(sonarView: self))
                    let circlePath = self.waveLayer.circleAnglesForRadius(radius: CGFloat(radius))
                    let proportionalPosition = self.sonarViewLayout.positionForWaveLabel(sonarView: self, inWave: waveIndex)
                    let position = self.calculatePositionOnRadius(onRadius: radius, startAngle: Double(circlePath.startAngle), endAngle: Double(circlePath.endAngle), position: proportionalPosition)

                    distanceLabel.sizeToFit()
                    distanceLabel.layer.position = position

                    UIView.animate(withDuration: 0.3, delay: Double(waveIndex) * 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        distanceLabel.alpha = 1.0
                    }, completion: nil)

                    let gradientSize: CGFloat = 60
                    let gradient = RadialGradientLayer(frame: CGRect(center: position, width: gradientSize, height: gradientSize), radius: gradientSize / 2, center: CGPoint(x: gradientSize / 2, y: gradientSize / 2), colors: [UIColor.white.cgColor, UIColor.white.withAlphaComponent(1.0).cgColor, UIColor.white.withAlphaComponent(0.0).cgColor], locations: [0.0, 0.6, 1.0])
                    self._shadows.append(gradient)
                    self.layer.insertSublayer(gradient, below: distanceLabel.layer)
                }

                for itemIndex in 0 ..< numberOfItemsInWave {
                    let itemView = dataSource.sonarView(sonarView: self, itemViewForWave: waveIndex, atIndex: itemIndex)
                    self.configureItemView(itemView: itemView, forWave: waveIndex, atIndex: itemIndex, numberOfItemsInWave: numberOfItemsInWave)
                }
            }
        }
    }

    private func configureItemView(itemView: SonarItemView, forWave waveIndex: Int, atIndex itemIndex: Int, numberOfItemsInWave _: Int) {

        itemView.alpha = 0.0
        self.addSubview(itemView)
        _itemViews.append(itemView)
        itemView.position = SonarPosition(waveIndex: waveIndex, itemIndex: itemIndex)

        let itemSize = self.sonarViewLayout.sizeForItem(sonarView: self, inWave: waveIndex, atIndex: itemIndex)
        itemView.layer.bounds = CGRect(origin: CGPoint.zero, size: itemSize)

        let calculatedRadius = Double(self.waveLayer.radiusForWave(waveIndex: waveIndex))
        let radius = calculatedRadius + (calculatedRadius * self.sonarViewLayout.waveRadiusOffset(sonarView: self))
        let circlePath = self.waveLayer.circleAnglesForRadius(radius: CGFloat(radius))

        let proportionalPosition = self.sonarViewLayout.positionForItem(sonarView: self, inWave: waveIndex, atIndex: itemIndex)
        let position = self.calculatePositionOnRadius(onRadius: radius, startAngle: Double(circlePath.startAngle), endAngle: Double(circlePath.endAngle), position: proportionalPosition)

        // Set calculated position
        itemView.layer.position = position

        // Setup gesture recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SonarView.didSelectItem))
        itemView.addGestureRecognizer(tapGestureRecognizer)

        itemView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        UIView.animateKeyframes(withDuration: 0.4, delay: (Double(itemIndex) * 0.1) + (Double(waveIndex) * 0.3) + 0.1, options: UIViewKeyframeAnimationOptions.calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1 / 2) {
                itemView.alpha = 1.0
                itemView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
            UIView.addKeyframe(withRelativeStartTime: 1 / 2, relativeDuration: 1 / 2) {
                itemView.transform = .identity
            }
        }, completion: nil)
    }

    private class func distanceLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 10.0)
        label.textColor = SonarView.distanceTextColor

        return label
    }

    func didSelectItem(sender: UIGestureRecognizer) {
        if let itemView = sender.view as? SonarItemView {
            delegate?.sonarView(sonarView: self, didSelectObjectInWave: itemView.position.waveIndex, atIndex: itemView.position.itemIndex)
        }
    }

    /**
     Calculates position for view on given radius

     @param onRadius Circle radius where the position should be places
     @param position Position between 0 and numberOfPositions
     @param numberOfPositions Number of positions

     @return Point with calculated position
     */

    private func calculatePositionOnRadius(onRadius: Double, startAngle: Double, endAngle: Double, position: Double) -> CGPoint {

        let center = CGPoint(x: self.frame.width / 2, y: self.frame.height)
        let length = endAngle - startAngle
        let radianAngle = startAngle + (length * position)
        let x = onRadius * cos(radianAngle) + Double(center.x)
        let y = onRadius * sin(radianAngle) + Double(center.y)

        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

extension CGRect {
    init(center: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(x: center.x - (width / 2), y: center.y - (height / 2), width: width, height: height)
    }
}
