//
//  BidModelMinute.swift
//  BTCCandleStickChart
//
//  Created by Igor Kishik on 25.03.2020.
//  Copyright © 2020 Igor Kishik. All rights reserved.
//

import Foundation

class BidModelMinute {
    
    public var shadowH: Double = 0
    public var shadowL: Double = Double.infinity
    public var open: Double = 0
    public var close: Double = 0
    
    public var plusTrand: Bool {
        get {
            return close - open  > 0
        }
    }
    public var date: Date?
    
    public var isReady: Bool {
        get {
            return _bidModels.count > 1
        }
    }
    private var _bidModels:[BidModel] = []
    
    func addBidModel(bidModel: BidModel) {
        if date == nil {
            date = bidModel.bidTime
        }
        _bidModels.append(bidModel)
        calc()
    }

    private func calc() {
                
        if _bidModels.count > 0 {
            _bidModels.sort(by: >)
            open = _bidModels[0].bid
            close = _bidModels[_bidModels.count - 1].bid

            for bidModel in self._bidModels {
                shadowH = shadowH < bidModel.bid ? bidModel.bid : shadowH
                shadowL = shadowL > bidModel.bid ? bidModel.bid : shadowL
            }
            
        }
        
    }
}
