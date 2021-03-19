//
//  IndicatorValue.swift
//  Trading
//
//  Created by Maroun Achille on 09/04/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class IndicatorDraw {
    
    var desc: String
    var model: String
    var type: String
    var stop: Bool
    
    var color1: NSColor
    var color2: NSColor
    
    var pathColor1: NSBezierPath
    var pathColor2: NSBezierPath

    var pathColor1Layer: CAShapeLayer
    var pathColor2Layer: CAShapeLayer?
    
    var headerTextLayer: CATextLayer?
    
    var indicDict = [Date: Double] ()
    
    init() {
        desc = "Indic"
        model = "Line"
        type = "Chart"
        stop = false
        color1 = NSColor(hex: "#32d82f")! //green
        color2 = NSColor(hex: "#32d82f")! //green

        pathColor1 = NSBezierPath()
        pathColor2 = NSBezierPath()
        pathColor1Layer = CAShapeLayer()
    }
    
    func clearPath () {
        pathColor1.removeAllPoints()
        pathColor2.removeAllPoints()
    }
    
    
    func setPathColor1(model: String) {
        pathColor1Layer.path = pathColor1.cgPath
        pathColor1Layer.opacity = 1
        pathColor1Layer.lineCap = .round
        if model == IndicatorModel.Point.rawValue  {
            pathColor1Layer.fillColor = color1.cgColor
        } else if model == IndicatorModel.Histogram.rawValue {
            pathColor1Layer.strokeColor = color1.cgColor
            pathColor1Layer.lineWidth = 2.0
        } else {
            pathColor1Layer.strokeColor = color1.cgColor
        }
    }
    
    func setPathColor2(model: String) {
        let pathColor2Layer = self.pathColor2Layer ?? CAShapeLayer()
        
        pathColor2Layer.path = pathColor2.cgPath
        pathColor2Layer.opacity = 1
        pathColor2Layer.lineCap = .round
        if model == IndicatorModel.Point.rawValue  {
            pathColor2Layer.fillColor = color2.cgColor
        } else if model == IndicatorModel.Histogram.rawValue {
            pathColor2Layer.strokeColor = color2.cgColor
            pathColor2Layer.lineWidth = 2.0
        } else {
            pathColor2Layer.strokeColor = color2.cgColor
        }
        if self.pathColor2Layer == nil {
            self.pathColor2Layer = pathColor2Layer
        }
    }
    
    func getValue(at: Date) -> Double? {
        if let val = indicDict[at] {
            return val
        } else {
            return nil
        }
    }

    func getMinMax(from: Date, to: Date ) -> (Double, Double) {
        let tmpIndic = indicDict.filter { $0.key >= from && $0.key < to}
        let dictValues = [Double](tmpIndic.values)
        if let minValue = dictValues.min(), let maxValue = dictValues.max() {
             return (minValue, maxValue)
        } else {
             return (0.0, 0.0)
        }
    }
    
    func textLayer (text: String, x: CGFloat, y: CGFloat, backColor: NSColor) -> CATextLayer {
        let headerTextLayer = self.headerTextLayer ?? CATextLayer()
        headerTextLayer.foregroundColor = color1.cgColor
        headerTextLayer.backgroundColor = backColor.cgColor
        headerTextLayer.alignmentMode = CATextLayerAlignmentMode.left
        headerTextLayer.contentsScale = NSScreen.main!.backingScaleFactor
        headerTextLayer.font = ChartDefaultValue.font
        headerTextLayer.fontSize = ChartDefaultValue.fontSize
        let width = ChartDefaultValue.textWidth(text: text) * 1.1
        headerTextLayer.frame = NSMakeRect(x, y, width, 15)
        headerTextLayer.string = text
        return headerTextLayer
    }
}
