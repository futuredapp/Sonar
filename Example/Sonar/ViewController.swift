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

class ViewController: UIViewController {
    
    @IBOutlet weak var sonarView: SonarView!
    
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
            return 2
        case 2:
            return 4
        default:
            return 2
        }
    }
    
    func sonarView(sonarView: SonarView, itemViewForWave waveIndex: Int, atIndex: Int) -> SonarItemView {
        return TestSonarItemView(frame: CGRectZero)
    }
}

extension ViewController: SonarViewLayout {
    func sonarView(sonarView: SonarView, sizeForItemInWave waveIndex: Int, atIndex: Int) -> CGSize {
        return CGSizeMake(50, 50)
    }
}

extension ViewController: SonarViewDelegate {
    func sonarView(sonarView: SonarView, didSelectObjectInWave waveIndex: Int, atIndex: Int) {
        print("Did select item in wave \(waveIndex) at index \(atIndex)")
    }
    
    func sonarView(sonarView: SonarView, distanceForWaveAtIndex waveIndex: Int) -> Distance {
        return 100.0 * Double(waveIndex + 1)
    }
}


func delay(delay: Double, closure: Void -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

