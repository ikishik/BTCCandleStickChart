//
//  ChartScrollView.swift
//  BTCCandleStickChart
//
//  Created by Igor Kishik on 25.03.2020.
//  Copyright © 2020 Igor Kishik. All rights reserved.
//

import UIKit

class ChartScrollView: UIScrollView {

    /**
     Used to show maximun and minimum graph values from bid
     */
    public var gap: Double = 20.0
    
    /**
     Constants for draw candles
     */
    struct LayoutConstants {
        static let candleBodyWidth: CGFloat = 16
        static let candleShadowWidth: CGFloat = 1
        static let candleSpacing: CGFloat = 8
        static let availableScrollContentHeight: CGFloat = 0.8
    }
    
    struct ColorConstants {
        static let positiveCandle: UIColor = .green
        static let negativeCandle: UIColor = .red
        static let candleShadow: UIColor = .gray
    }
    
    private let _mainLayer: CALayer = CALayer()
    private var _maxValue: Double = 0
    private var _minValue: Double = Double.infinity
    private var _requiredContentWidth: CGFloat {
        return (LayoutConstants.candleSpacing + LayoutConstants.candleBodyWidth) * CGFloat(AppDelegate.bids.count) + LayoutConstants.candleSpacing
    }
    private let steps = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9] //[0.25, 0.5, 0.75] //from 0 to 1

    override func didMoveToSuperview() {
        if superview != nil {
            layer.addSublayer(_mainLayer)
        }
    }
    
    /**
     Called when new bid comes from socket. It is needed for visible area
     */
    func updateMaxMinValues(bid: Double) {
        if bid > self._maxValue {
            self._maxValue = bid + gap
        }
        if bid < self._minValue {
            self._minValue = bid - gap
        }
    }

    /**
     Updates all candles with info (time, prices).
     */
    func update() {
        let width = frame.width
        let needToScroll = abs(bounds.origin.x + width - contentSize.width) <= 10 || width > contentSize.width
        
        /**
         We clear layers here to draw everything correctly
         */
        let texts = superview?.layer.sublayers?.filter {$0 is CATextLayer}
        texts?.forEach({$0.removeFromSuperlayer()})
        _mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let availableHeight = frame.height * LayoutConstants.availableScrollContentHeight
        contentSize = CGSize(width: _requiredContentWidth, height: frame.size.height)
        _mainLayer.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        
        let chartHeightRatio = availableHeight / CGFloat(_maxValue - _minValue)
        
        guard chartHeightRatio != 0, availableHeight != 0 else { return }
        
        let bids = AppDelegate.bids.values.sorted { (bid1, bid2) -> Bool in
            return bid1.date!.compare(bid2.date!) == .orderedAscending
        }

        let lineColor = UIColor.black.withAlphaComponent(0.7).cgColor
        let topLineFrame = CGRect(x: 0, y: (frame.height - availableHeight) / 2.0, width: max(contentSize.width, width), height: 1)
        let bottomLineFrame = CGRect(x: 0, y: (frame.height + availableHeight) / 2.0, width: max(contentSize.width, width), height: 1)
        
        /**
         Candles are drawn here
         */
        bids.enumerated().forEach { index, element in
            showCandle(index: index, candle: element, availableHeight: availableHeight, with: chartHeightRatio)
        }
        /**
         Reversed array is needed to draw time for current candle
         */
        bids.reversed().enumerated().forEach { index, element in
            if index % 2 == 0 {
                showTimeForCandle(candle: element, index: bids.count - index - 1, bottomLineY: bottomLineFrame.origin.y)
            }
        }
        
        let fontSize: CGFloat = 14
        let textColor = UIColor.black.withAlphaComponent(0.9).cgColor
        let textHeight = UIFont.systemFont(ofSize: fontSize).lineHeight
        let maxTextFrame = CGRect(x: 0, y: topLineFrame.minY - textHeight + frame.minY, width: UIScreen.main.bounds.width - 8, height: textHeight)
        let minTextFrame = CGRect(x: 0, y: bottomLineFrame.maxY + frame.minY, width: UIScreen.main.bounds.width - 8, height: textHeight)
        
        /**
         Prices are added to superview to pin them on the screen, without scrolling
         */
        _mainLayer.addRectangleLayer(frame: topLineFrame, color: lineColor)
        _mainLayer.addRectangleLayer(frame: bottomLineFrame, color: lineColor)
        superview?.layer.addTextLayer(frame: maxTextFrame, color: textColor, fontSize: fontSize,
                                text: _maxValue == 0 ? String() : String(Int(_maxValue)))
        superview?.layer.addTextLayer(frame: minTextFrame, color: textColor, fontSize: fontSize,
                                text: _minValue == .infinity ? String() : String(Int(_minValue)))
        
        let diff = _maxValue - _minValue
        steps.forEach { (step) in
            let value = _minValue + diff * step
            var frame = minTextFrame
            frame.origin.y = (minTextFrame.origin.y - maxTextFrame.origin.y) * CGFloat(step) + maxTextFrame.origin.y
            superview?.layer.addTextLayer(frame: frame, color: textColor, fontSize: fontSize, text: _minValue == .infinity ? String() : String(Int(value)))
        }
        
        guard needToScroll else { return }
        
        let rectToScroll = CGRect(x: contentSize.width - width, y: frame.minY, width: width, height: frame.height)
        scrollRectToVisible(rectToScroll, animated: false)
    }
    
    /**
     Method to draw candles, body and shadow
     */
    private func showCandle(index: Int, candle: BidModelMinute, availableHeight: CGFloat, with chartHeightRatio: CGFloat) {
        let color = candle.plusTrand == false ? ColorConstants.positiveCandle : ColorConstants.negativeCandle
        
        let candleShadowHeight = CGFloat(candle.shadowH - candle.shadowL) * chartHeightRatio
        let candleShadowOriginY = CGFloat(_maxValue - candle.shadowH) * chartHeightRatio
            + (frame.height - availableHeight) / 2.0
        let candleShadowOriginX = CGFloat(index) * (LayoutConstants.candleSpacing + LayoutConstants.candleBodyWidth) + LayoutConstants.candleSpacing + LayoutConstants.candleBodyWidth / 2.0
        
        let frameForCandleShadow = CGRect(x: candleShadowOriginX, y: candleShadowOriginY, width: LayoutConstants.candleShadowWidth, height: candleShadowHeight)
        
        let maxCandleBodyValue = max(candle.open, candle.close)
        let minCandleBodyValue = min(candle.open, candle.close)
        
        let candleBodyHeight = CGFloat(maxCandleBodyValue - minCandleBodyValue) * chartHeightRatio
        let candleBodyOriginY = CGFloat(_maxValue - maxCandleBodyValue) * chartHeightRatio
            + (frame.height - availableHeight) / 2.0
        let candleBodyOriginX = CGFloat(index) * (LayoutConstants.candleSpacing + LayoutConstants.candleBodyWidth) + LayoutConstants.candleSpacing
        
        let frameForCandleBody = CGRect(x: candleBodyOriginX, y: candleBodyOriginY, width: LayoutConstants.candleBodyWidth, height: candleBodyHeight)
        
        if contentOffset.x <= frameForCandleBody.maxX && contentOffset.x + bounds.width >= frameForCandleBody.minX {
            _mainLayer.addRectangleLayer(frame: frameForCandleShadow, color: ColorConstants.candleShadow.cgColor)
            _mainLayer.addRectangleLayer(frame: frameForCandleBody, color: color.cgColor, cornered: true)
        }
    }
    
    /**
     Method to calculate frame and draw time for candles (X-axis)
     */
    private func showTimeForCandle(candle: BidModelMinute, index: Int, bottomLineY: CGFloat) {
        let fontSize: CGFloat = 12
        let text = NSString(string: candle.date!.shortTime)
        var boundingBox = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil)
        boundingBox.origin.x = (CGFloat(index) * (LayoutConstants.candleSpacing + LayoutConstants.candleBodyWidth) + LayoutConstants.candleSpacing + LayoutConstants.candleBodyWidth / 2.0) - boundingBox.size.width/2
        boundingBox.origin.y = bottomLineY - boundingBox.height
        _mainLayer.addTextLayer(frame: boundingBox, color: UIColor.black.cgColor, fontSize: fontSize, text: text as String)
    }
}

extension CALayer {
    func addRectangleLayer(frame: CGRect, color: CGColor, borderColor: CGColor = UIColor.clear.cgColor, cornered: Bool = false) {
        let layer = CALayer()
        layer.frame = frame
        layer.backgroundColor = color
        layer.borderColor = borderColor
        layer.borderWidth = 2
        if cornered {
            layer.cornerRadius = 3
        }
        addSublayer(layer)
    }
    
    func addTextLayer(frame: CGRect, color: CGColor, fontSize: CGFloat, text: String) {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.foregroundColor = color
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.right
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = fontSize
        textLayer.string = text
        addSublayer(textLayer)
    }
}
