//
//  Date+Extension.swift
//  BTCCandleStickChart
//
//  Created by Igor Kishik on 25.03.2020.
//  Copyright © 2020 Igor Kishik. All rights reserved.
//

import Foundation

extension Date {
    /**
    Used to key in dict with data from server
    */
    public var dateKey: String {
        get {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd:HH:mm"
            return formatter.string(from: self)
        }
    }
    
    /**
     Used to show time in Chart
     */
    public var shortTime: String {
            get {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: self)
            }
        }
}
