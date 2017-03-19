//
//  ViewController.swift
//  Sonar
//
//  Created by Aleš Kocur on 01/01/16.
//  Copyright © 2016 Aleš Kocur. All rights reserved.
//

import UIKit
import CoreLocation
import Sonar
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sonarView: SonarView!
    fileprivate lazy var distanceFormatter: MKDistanceFormatter = MKDistanceFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.sonarView.delegate = self
        self.sonarView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reloadData(_ sender: AnyObject) {
        sonarView.reloadData()
    }
}

extension ViewController: SonarViewDataSource {
    func numberOfWaves(sonarView: SonarView) -> Int {
        return 4
    }
    
    func sonarView(sonarView: SonarView, numberOfItemForWaveIndex waveIndex: Int) -> Int {
        switch waveIndex {
        case 0:
            return 2
        case 1:
            return 3
        case 2:
            return 4
        default:
            return 2
        }
    }
    
    func sonarView(sonarView: SonarView, itemViewForWave waveIndex: Int, atIndex: Int) -> SonarItemView {
        let itemView = self.newItemView()
        itemView.imageView.image = randomAvatar()
        
        return itemView
    }
    
    // MARK: - Helpers
    
    fileprivate func randomAvatar() -> UIImage {
        let index = arc4random_uniform(3) + 1
        return UIImage(named: "avatar\(index)")!
    }
    
    fileprivate func newItemView() -> TestSonarItemView {
        return Bundle.main.loadNibNamed("TestSonarItemView", owner: self, options: nil)!.first as! TestSonarItemView
    }
}

extension ViewController: SonarViewDelegate {
    func sonarView(sonarView: SonarView, didSelectObjectInWave waveIndex: Int, atIndex: Int) {
        print("Did select item in wave \(waveIndex) at index \(atIndex)")
    }
    
    func sonarView(sonarView: SonarView, textForWaveAtIndex waveIndex: Int) -> String? {
        
        if self.sonarView(sonarView: sonarView, numberOfItemForWaveIndex: waveIndex) % 2 == 0 {
            return self.distanceFormatter.string(fromDistance: 100.0 * Double(waveIndex + 1))
        } else {
            return nil
        }
    }
}


func delay(_ delay: Double, closure: @escaping (Void) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

