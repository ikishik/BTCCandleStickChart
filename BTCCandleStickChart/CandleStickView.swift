//
//  CandleStickView.swift
//  BTCCandleStickChart
//
//  Created by Igor Kishik on 23.03.2020.
//  Copyright © 2020 Igor Kishik. All rights reserved.
//

import UIKit

@IBDesignable
class CandleStickView: UIView {
    
    @IBInspectable var startColor: UIColor = .red
    @IBInspectable var endColor: UIColor = .green

    /**
    Used for Gradient font in view
    */
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                       colors: colors as CFArray,
                                    locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        
        context.drawLinearGradient(gradient,
                            start: startPoint,
                              end: endPoint,
                          options: [])
    }
    

}
