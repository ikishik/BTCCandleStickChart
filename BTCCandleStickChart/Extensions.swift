//
//  Extensions.swift
//  BTCCandleStickChart
//
//  Created by Igor Kishik on 25.03.2020.
//  Copyright © 2020 Igor Kishik. All rights reserved.
//

import Foundation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
