//
//  SonarView.swift
//  Sonar
//
//  Created by Aleš Kocur on 13/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//

import UIKit
import MapKit

public protocol SonarViewDataSource: class {
    func numberOfWaves(sonarView: SonarView) -> Int
    func sonarView(sonarView: SonarView, numberOfItemForWaveIndex waveIndex: Int) -> Int
    func sonarView(sonarView: SonarView, itemViewForWave waveIndex: Int, atIndex: Int) -> SonarItemView
}

public protocol SonarViewDelegate: class {
    func sonarView(sonarView: SonarView, didSelectObjectInWave waveIndex: Int, atIndex: Int)
    func sonarView(sonarView: SonarView, distanceForWaveAtIndex waveIndex: Int) -> Distance?
}

public protocol SonarViewLayout: class {
    func sonarView(sonarView: SonarView, sizeForItemInWave waveIndex: Int, atIndex: Int) -> CGSize
}

public typealias Distance = Double

public class SonarView: UIView {

    // Private properties
    private var waveLayer: WavesLayer!
    private var _itemViews: [SonarItemView] = []
    private var _shadows: [RadialGradientLayer] = []
    private var _needsLayout = false
    private lazy var distanceFormatter: MKDistanceFormatter = MKDistanceFormatter()
    
    // Public properties
    public weak var delegate: SonarViewDelegate?
    public weak var dataSource: SonarViewDataSource? {
        didSet {
            self.reloadData()
        }
    }
    public static var lineColor: UIColor = UIColor(red: 0.898, green: 0.969, blue: 0.980, alpha: 1.00)
    public static var lineShadowColor: UIColor = UIColor(red: 0.949, green: 0.988, blue: 0.992, alpha: 1.00)
    public static var distanceTextColor: UIColor = UIColor(red: 0.663, green: 0.878, blue: 0.925, alpha: 1.00)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    // Initial setup
    private func setup() {
        self.waveLayer = WavesLayer(frame: self.bounds)
        self.waveLayer.rasterizationScale = UIScreen.mainScreen().scale
        self.layer.addSublayer(self.waveLayer)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.waveLayer.frame = self.bounds
        
        if _needsLayout {
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
        
        let numberOfWaves = dataSource.numberOfWaves(self)
        self.waveLayer.setNumberOfWaves(numberOfWaves)
        
        _itemViews.forEach { $0.removeFromSuperview() }
        _itemViews.removeAll()
        _shadows.forEach { $0.removeFromSuperlayer() }
        _shadows.removeAll()
        
        for waveIndex in 0..<numberOfWaves {
            let numberOfItemsInWave = dataSource.sonarView(self, numberOfItemForWaveIndex: waveIndex)
            
            if let distance = self.delegate?.sonarView(self, distanceForWaveAtIndex: waveIndex) {
                let distanceLabel = SonarView.distanceLabel()
                distanceLabel.text = distanceFormatter.stringFromDistance(distance)
                
                self.addSubview(distanceLabel)
                
                let radius = Double(self.waveLayer.radiusForWave(waveIndex: waveIndex))
                let circlePath = self.waveLayer.circleAnglesForRadius(radius: CGFloat(radius))
                let position = self.calculatePositionOnRadius(radius, startAngle: Double(circlePath.startAngle), endAngle: Double(circlePath.endAngle), position: 0, numberOfPositions: 1)
                
                distanceLabel.sizeToFit()
                distanceLabel.layer.position = position
                
                let gradientSize: CGFloat = 60
                let gradient = RadialGradientLayer(frame: CGRect(center: position, width: gradientSize, height: gradientSize), radius: gradientSize / 2, center: CGPointMake(gradientSize / 2, gradientSize / 2), colors: [UIColor.whiteColor().CGColor, UIColor.whiteColor().colorWithAlphaComponent(1.0).CGColor, UIColor.whiteColor().colorWithAlphaComponent(0.0).CGColor], locations: [0.0, 0.6, 1.0])
                _shadows.append(gradient)
                self.layer.insertSublayer(gradient, below: distanceLabel.layer)
            }
            
            for itemIndex in 0..<numberOfItemsInWave {
                let itemView = dataSource.sonarView(self, itemViewForWave: waveIndex, atIndex: itemIndex)
                configureItemView(itemView, forWave: waveIndex, atIndex: itemIndex, numberOfItemsInWave: numberOfItemsInWave)
            }
        }
    }

    
    private func configureItemView(itemView: SonarItemView, forWave waveIndex: Int, atIndex itemIndex: Int, numberOfItemsInWave: Int) {
        
        self.addSubview(itemView)
        _itemViews.append(itemView)
        itemView.position = SonarPosition(waveIndex: waveIndex, itemIndex: itemIndex)
        
        // If delegate conforms to SonarViewLayout protocol, use given size, otherwise use autolayout to calculate its compressed size
        if let layoutDelegate = self.delegate as? SonarViewLayout {
            let itemSize = layoutDelegate.sonarView(self, sizeForItemInWave: waveIndex, atIndex: itemIndex)
            itemView.layer.bounds = CGRect(origin: CGPointZero, size: itemSize)
        } else {
            itemView.layer.bounds = CGRect(origin: CGPointZero, size: itemView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize))
        }
        
        let radius = Double(self.waveLayer.radiusForWave(waveIndex: waveIndex))
        let circlePath = self.waveLayer.circleAnglesForRadius(radius: CGFloat(radius))
        let position = self.calculatePositionOnRadius(radius, startAngle: Double(circlePath.startAngle), endAngle: Double(circlePath.endAngle), position: itemIndex, numberOfPositions: numberOfItemsInWave)
        
        // Set calculated position
        itemView.layer.position = position
        
        // Setup gesture recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didSelectItem:"))
        itemView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private class func distanceLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 10.0)
        label.textColor = SonarView.distanceTextColor

        return label
    }
    
    func didSelectItem(sender: UIGestureRecognizer) {
        if let itemView = sender.view as? SonarItemView {
            delegate?.sonarView(self, didSelectObjectInWave: itemView.position.waveIndex, atIndex: itemView.position.itemIndex)
        }
    }
    
    /**
    Calculates position for view on given radius 
    
    @param onRadius Circle radius where the position should be places
    @param position Position between 0 and numberOfPositions
    @param numberOfPositions Number of positions 
    
    @return Point with calculated position
    */
    
    private func calculatePositionOnRadius(onRadius: Double, startAngle: Double, endAngle: Double, position: Int, numberOfPositions: Int) -> CGPoint {
        
        if position < 0 || position >= numberOfPositions {
            assertionFailure("*** SonarView: Out of range!")
        }
        
        let center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))
        let length = endAngle - startAngle
        
        let radianAngle = (length * (Double(position + 1) / Double(numberOfPositions + 1))) + startAngle
        
        let x = onRadius * cos(radianAngle) + Double(center.x)
        let y = onRadius * sin(radianAngle) + Double(center.y)
        
        return CGPointMake(CGFloat(x), CGFloat(y))
    }
}


extension CGRect {
    init(center: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(x: center.x - (width / 2), y: center.y - (height / 2), width: width, height: height)
    }
}
