//
//  ViewController.swift
//  BTCCandleStickChart
//
//  Created by Igor Kishik on 22.03.2020.
//  Copyright © 2020 Igor Kishik. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    private let scrollView = ChartScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackendConnector.shared.listen(listener: self)
        BackendConnector.shared.connect()
        
        /**
         Main view for drawing candles and horizontal scroll
         */
        scrollView.bounds = view.bounds
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.gap = 20.0
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                   scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                   scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                   scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.update()
    }
    
    deinit {
        BackendConnector.shared.disconnect()
    }
}

extension ViewController : SocketListener {
    func websocketDidConnect() {
        
        BackendConnector.shared.sendMessage("SUBSCRIBE: BTCUSD")
    }
    
    func websocketDidDisconnect() {
        
    }
    
    func websocketDidReceiveText(_ message: String) {
        
        let response = JSON(parseJSON: message)
        var ticks:[JSON]? = []
        
        if response["subscribed_list"].exists() {
            let ticksDict = response["subscribed_list"].dictionaryValue
            ticks = ticksDict["ticks"]?.arrayValue
        } else {
            ticks = response["ticks"].arrayValue
        }
        
        if let ticks = ticks {
            for tick in ticks {
                let bid = tick["b"].doubleValue
                scrollView.updateMaxMinValues(bid: bid)
                
                let bidDate = Date()
                let dateKey = bidDate.dateKey
                
                var bids = AppDelegate.bids
                
                if bids.keys.contains(dateKey) {
                    bids[dateKey]?.addBidModel(bidModel: BidModel(bidTime: bidDate, bid: bid))
                } else {
                    let bidModelMinute = BidModelMinute()
                    bidModelMinute.addBidModel(bidModel: BidModel(bidTime: bidDate, bid: bid))
                    bids[dateKey] = bidModelMinute
                }
                AppDelegate.bids = bids
            }
        }
        let bids = AppDelegate.bids.values.map { $0.isReady }
        if bids.last == true {
            scrollView.update()
        }
    }
    
    
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       // guard scrollView.panGestureRecognizer.state != .possible else { return }

        print("upd scroll")
        self.scrollView.update()
    }
}
