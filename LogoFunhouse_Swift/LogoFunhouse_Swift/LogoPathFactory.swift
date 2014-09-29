//
//  LogoPathFactory.swift
//  LogoFunhouse_Swift
//
//  Created by Collin Ruffenach on 8/25/14.
//  Copyright (c) 2014 Simple. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    func map<U>(transform : (index: Int, object: T) -> U) -> [U] {
        var results = [U]()
        for (i, obj) in enumerate(self) {
            results.append(transform(index: i, object: obj))
        }
        return results  
    }
}

struct Logo {

    var iterations : Int
    var resolution : Int
    var amplitude : Double
    var frequency : Double
    
    func points(#phase : Double) -> [CGPoint] {

        let accelerate = true
        
        //for(int i = 1; i < resolution+1; i++)
        //x = (0.5+0.5*amplitude*sinf(phase+frequency*(i*resolutionIncrement)))*cosf(i*resolutionIncrement);
        //y = (0.5+0.5*amplitude*sinf(phase+frequency*(i*resolutionIncrement)))*sinf(i*resolutionIncrement);

        if accelerate {
            var sketchpad = [Double](count: resolution, repeatedValue: 0.0)
            let resolutionIncrement = Double(2.0*M_PI)/Double(resolution)
            sketchpad = sketchpad.map() { (index: Int, object : Double) in
                return Double(index)*resolutionIncrement
            }
            let resolutionIncrementSinCos = sincos(sketchpad)
            sketchpad = mul(sketchpad, [Double](count: resolution, repeatedValue: frequency))
            sketchpad = add(sketchpad, [Double](count: resolution, repeatedValue: phase))
            sketchpad = sin(sketchpad)
            sketchpad = mul(sketchpad, [Double](count: resolution, repeatedValue: 0.5*amplitude))
            sketchpad = add(sketchpad, [Double](count: resolution, repeatedValue: 0.5))
            let x = mul(resolutionIncrementSinCos.cos, sketchpad)
            let y = mul(resolutionIncrementSinCos.sin, sketchpad)
            return x.map({ (index, object) in return CGPoint(x : x[index], y : y[index])})
        } else {
            let resolutionIncrement = Double(2.0*M_PI)/Double(resolution)
            var points = [CGPoint]()
            for i in 0..<resolution {
                points.append( CGPoint(x : (0.5 +
                                        0.5 *
                                        amplitude *
                                        sin(phase + frequency * (Double(i) * resolutionIncrement))) *
                                        cos(Double(i)*resolutionIncrement),
                                       y : (0.5 +
                                        0.5 *
                                        amplitude *
                                        sin(phase + frequency * (Double(i) * resolutionIncrement))) *
                                        sin(Double(i)*resolutionIncrement)))
                                
            }
            let end = NSDate().timeIntervalSince1970
            return points
        }
    }
    
    func pathPoints() -> [[CGPoint]] {
        let phaseIncrement = Double(2.0*M_PI)/Double(self.iterations);
        var shapes = [[CGPoint]]()
        for i in 1...self.iterations {
            shapes.append(
                Logo(iterations: self.iterations,
                    resolution: self.resolution,
                    amplitude: self.amplitude,
                    frequency: self.frequency
                ).points(phase: Double(i)*phaseIncrement)
            )
        }
        return shapes
    }
    
    func paths(frame : CGRect) -> [UIBezierPath] {
        let now = NSDate().timeIntervalSince1970
        println("paths Start \(now)")
        var shapes = pathPoints()
        var x = shapes.map({$0.map({$0.x})}).reduce([CGFloat](), combine: {$0 + $1})
        var y = shapes.map({$0.map({$0.y})}).reduce([CGFloat](), combine: {$0 + $1})
        var minPoint = CGPoint(x: x.reduce(CGFloat.max, combine: {min($0, $1)}), y: y.reduce(CGFloat.max, combine: {min($0, $1)}))
        var maxPoint = CGPoint(x: x.reduce(CGFloat.min, combine: {max($0, $1)}), y: y.reduce(CGFloat.min, combine: {max($0, $1)}))
        let xScaler = maxPoint.x - minPoint.x
        let yScaler = maxPoint.y - minPoint.y
    
        var normalizedShapes = shapes.map({$0.map({CGPoint(x: $0.x/xScaler, y: $0.y/yScaler)})})
        var paths = [UIBezierPath]()
        
            for points in normalizedShapes {
                var path = UIBezierPath()
                for (index, point) in enumerate(points) {
                    var scaledPoint = CGPoint(x: point.x * CGRectGetWidth(frame),
                                              y: point.y * CGRectGetHeight(frame))
                    scaledPoint = CGPoint(x: scaledPoint.x + CGRectGetWidth(frame)/2.0,
                                          y: scaledPoint.y + CGRectGetHeight(frame)/2.0)
                    
                    if (index == 0) {
                        path.moveToPoint(scaledPoint)
                    } else {
                        path.addLineToPoint(scaledPoint)
                    }
                }
                path.closePath()
                paths.append(path)
            }
        let end = NSDate().timeIntervalSince1970
        println("paths End \(end) \nTime: \(end - now)")
        return paths
    }
}