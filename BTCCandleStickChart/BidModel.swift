//
//  Model.swift
//  BTCCandleStickChart
//
//  Created by Igor Kishik on 25.03.2020.
//  Copyright © 2020 Igor Kishik. All rights reserved.
//

import Foundation

class BidModel: Comparable
{
    public var bid: Double
    public var bidTime: Date
    
    init(bidTime: Date, bid: Double) {
        self.bidTime = bidTime
        self.bid = bid
    }
    
    static func < (lhs: BidModel, rhs: BidModel) -> Bool {
        return lhs.bidTime < rhs.bidTime
    }
    
    static func == (lhs: BidModel, rhs: BidModel) -> Bool {
        return lhs.bidTime == rhs.bidTime
    }
    
}
