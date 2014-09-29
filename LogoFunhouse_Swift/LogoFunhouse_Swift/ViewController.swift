//
//  ViewController.swift
//  LogoFunhouse_Swift
//
//  Created by Collin Ruffenach on 8/6/14.
//  Copyright (c) 2014 Simple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        var rect = self.view.bounds;
        let length = min(CGRectGetWidth(rect), CGRectGetHeight(rect))
        rect.size = CGSize(width: length, height: length);
        let logo = Logo(iterations: 5, resolution: 10000, amplitude: 0.2, frequency: 2.0)
        for path in logo.paths(rect) {
            let layer = CAShapeLayer()
            layer.path = path.CGPath
            layer.lineWidth = 2.0;
            layer.strokeColor = UIColor.redColor().CGColor
            layer.fillColor = UIColor.clearColor().CGColor
            layer.position = CGPointMake(0, (CGRectGetHeight(self.view.bounds)-CGRectGetWidth(self.view.bounds))/2.0)
            self.view.layer.addSublayer(layer)
        }
    }
}