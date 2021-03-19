//
//  ChartLine.swift
//  Trading
//
//  Created by Maroun Achille on 28/05/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartLine {
    var fromPoint: NSPoint = NSPoint(x: 0, y: 0)
    var toPoint: NSPoint =  NSPoint(x: 0, y: 0)
    var quote: Double = 0.0
    var desc: String = ""
    var per: Double = 0.0
    var sep: String = ""
    var textLayer: CATextLayer?
    
    func intTextLayer(color: NSColor) {
        textLayer = CATextLayer()
        textLayer?.foregroundColor = color.cgColor
        textLayer?.alignmentMode = CATextLayerAlignmentMode.left
        textLayer?.contentsScale = NSScreen.main!.backingScaleFactor
        textLayer?.font = NSFont(name: "HelveticaNeue-Bold", size: 13)
        textLayer?.fontSize = 13
    }
    
    func setTextLayer(roundDec: Int) {
        if let textLayer = textLayer {
            textLayer.frame = NSMakeRect(fromPoint.x + 6, fromPoint.y  , 200 , 18)
            textLayer.string = (per == 0.0 ? desc + sep + Calculate.formatNumber(roundDec, quote) : desc + sep + Calculate.formatNumber(roundDec, quote) + " Per : " + Calculate.formatNumber(2, per))
        }
    }
    
    func textToDraw(roundDec: Int ) -> String {
        return (per == 0.0 ? desc + " " + Calculate.formatNumber(roundDec, quote) : desc + " " + Calculate.formatNumber(roundDec, quote) + " Per : " + Calculate.formatNumber(2, per))
    }
    
}

class FibPosition {
    var fibPoint: [ChartLine]
    var fibColorDraw: NSColor
    var roundDec: Int
    
    init (roundDec: Int) {
        fibColorDraw = NSColor(hex: ChartDefaultValue.colorArray[ChartDefaultValue.j])!
        ChartDefaultValue.j = (ChartDefaultValue.j  + 1 ) % ChartDefaultValue.colorArray.count
        self.roundDec = roundDec
        fibPoint = [ChartLine]()
        for _ in 0...4 {
            let fibline = ChartLine()
            fibline.intTextLayer(color: fibColorDraw)
            fibline.sep = " : "
            fibPoint.append(fibline)
        }
    }
    
    func setPoint0 (_ from: NSPoint, _ to: NSPoint, quote: Double) {
        fibPoint[0].fromPoint = from
        fibPoint[0].toPoint = to
        fibPoint[0].quote = quote
        fibPoint[0].desc = "00-00"
        fibPoint[0].setTextLayer(roundDec: roundDec)
    }
    
    func setPoint100 (_ from: NSPoint, _ to: NSPoint, quote: Double) {
        fibPoint[4].fromPoint = from
        fibPoint[4].toPoint = to
        fibPoint[4].quote = quote
        fibPoint[4].per = ( fibPoint[4].quote - fibPoint[0].quote ) / fibPoint[0].quote * 100
        fibPoint[4].desc = "100-"
        fibPoint[4].setTextLayer(roundDec: roundDec)
        fibPoint[0].fromPoint.x =  fibPoint[4].fromPoint.x
        fibPoint[0].setTextLayer(roundDec: roundDec)
    }
    
    func varPoint (per: Double) -> Double {
        let diff = fibPoint[4].quote - fibPoint[0].quote
        return diff * per + fibPoint[0].quote
    }
    
    func setPoint38 (_ from: NSPoint, _ to: NSPoint, quote: Double) {
        fibPoint[1].fromPoint = from
        fibPoint[1].toPoint = to
        fibPoint[1].quote = quote
        fibPoint[1].desc = "38-62"
        fibPoint[1].setTextLayer(roundDec: roundDec)
    }
    
    func setPoint50 (_ from: NSPoint, _ to: NSPoint, quote: Double) {
        fibPoint[2].fromPoint = from
        fibPoint[2].toPoint = to
        fibPoint[2].quote = quote
        fibPoint[2].desc = "50-50"
        fibPoint[2].setTextLayer(roundDec: roundDec)
    }
    
    func setPoint62 (_ from: NSPoint, _ to: NSPoint, quote: Double) {
        fibPoint[3].fromPoint = from
        fibPoint[3].toPoint = to
        fibPoint[3].quote = quote
        fibPoint[3].desc = "62-38"
        fibPoint[3].setTextLayer(roundDec: roundDec)
    }
}

class TPosition {
    var tpPoint: [ChartLine]
    var tpColorDraw: NSColor
    var roundDec: Int
    
    init (roundDec: Int) {
        tpColorDraw = NSColor(hex: ChartDefaultValue.colorArray[ChartDefaultValue.j])!
        ChartDefaultValue.j = (ChartDefaultValue.j  + 1 ) % ChartDefaultValue.colorArray.count
        self.roundDec = roundDec
        tpPoint = [ChartLine]()
        for _ in 0...1 {
            let tpline = ChartLine()
            tpline.intTextLayer(color: tpColorDraw)
            tpPoint.append(tpline)
        }
    }
    
    func setPoint0 (_ from: NSPoint, quote: Double) {
        tpPoint[0].fromPoint = NSPoint(x: from.x - 70, y: from.y)
        tpPoint[0].toPoint = NSPoint(x: from.x + 70, y: from.y)
        tpPoint[0].quote = quote
        tpPoint[0].setTextLayer(roundDec: roundDec)
    }
    
    func setPoint100 (_ from: NSPoint, quote: Double) {
        tpPoint[1].fromPoint = NSPoint(x: from.x - 70, y: from.y)
        tpPoint[1].toPoint = NSPoint(x: from.x + 70, y: from.y)
        tpPoint[1].quote = quote
        tpPoint[1].per = ( tpPoint[1].quote - tpPoint[0].quote ) / tpPoint[0].quote * 100
        tpPoint[1].setTextLayer(roundDec: roundDec)
    }
}
