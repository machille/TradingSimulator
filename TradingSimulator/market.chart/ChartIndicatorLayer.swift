//
//  IndicatorView2.swift
//  Trading
//
//  Created by Maroun Achille on 30/09/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartIndicatorLayer {
    
    private var ph0: CGFloat = 0, pw0: CGFloat = 0
    private var ph1: CGFloat = 0, pw1: CGFloat = 0
    private var gh: CGFloat = 0, gw: CGFloat = 0
    
    private var scaleLigneF: CGFloat = 20.0
    private var scaleLine: Double = 0.0
    private var rect2d = NSMakeRect(5 ,5 , 20, 20)
    
    private var lineCount: Int = 0
    private var text: String = " "
    
    private var linePrint1 = [Int](), linePrint2 = [Int]()
    
    private var valueMax: Double = 0.0, valueMin: Double = 0.0
    private var vvalueMax: Double = 0.0, vvalueMin: Double = 0.0, valueDiv: Double = 0.0
    
    private var indicDrawArray = [IndicatorDraw]()
    
    private let headerLayer = CATextLayer()
    private var box1PathLayer: CAShapeLayer?
    private var box2PathLayer: CAShapeLayer?
    private var columnPathLayer: CAShapeLayer?
    private var linePathLayer: CAShapeLayer?
    private var linePathZeroLayer: CAShapeLayer?
    private var linePathLine1Layer: CAShapeLayer?
    private var linePathLine2Layer: CAShapeLayer?
    
    var indicSet: IndicatorSetting
    
    var csp: ChartControllerView
    
    init (indicSet: IndicatorSetting, csp: ChartControllerView) {
        self.indicSet = indicSet
        self.csp = csp
        
        headerLayer.foregroundColor = csp.chartD.headColor.cgColor
        headerLayer.backgroundColor = csp.chartD.backColor.cgColor
        headerLayer.alignmentMode = CATextLayerAlignmentMode.left
        headerLayer.contentsScale = NSScreen.main!.backingScaleFactor
        headerLayer.font = ChartDefaultValue.headerFont
        headerLayer.fontSize = ChartDefaultValue.fontSize
        headerLayer.cornerRadius = 3.0
    }
    
    func refresh() {
        guard let histQuote = csp.histQuote else {
            return
        }
        
        indicDrawArray.removeAll()
        indicDrawArray.append(contentsOf: Indicator.indicator(indic: indicSet, hist: histQuote.getHist(contain: csp.chartD.type)))
        valueDiv = 1.00
        
        if indicSet.type != IndicatorType.Oscillator.rawValue  {
            valueMin = 999999999999.0
            valueMax = -999999999999.0
            var minLine: Double = 0.0, maxLine : Double = 0.0
            
            for indicD in indicDrawArray {
                (minLine, maxLine) = indicD.getMinMax(from: csp.dateMin, to: csp.dateMax)
                valueMin = min(valueMin, minLine)
                valueMax = max(valueMax, maxLine)
            }
            
            if valueMax < 0.0 {
                vvalueMax = valueMax - ( valueMax * csp.perLine  / 100.0)
            } else {
                vvalueMax = valueMax + ( valueMax * csp.perLine  / 100.0)
            }
            if (valueMin < 0.0) {
                vvalueMin = valueMin + ( valueMin * csp.perLine  / 100.0)
            } else {
                vvalueMin = valueMin - ( valueMin * csp.perLine  / 100.0)
            }
        } else {
            valueMin = 0.0
            valueMax = 100.0
        }
        
        if indicSet.splineValue1 != "" && indicSet.splineValue1.count > 1 {
            linePrint1.removeAll()
            for str in indicSet.splineValue1.split(separator: ",") {
                if let value = Int(str) {
                    linePrint1.append(value)
                }
            }
        }
        if indicSet.splineValue2 != "" && indicSet.splineValue2.count > 1 {
            linePrint2.removeAll()
            for str in indicSet.splineValue2.split(separator: ",") {
                if let value = Int(str) {
                    linePrint2.append(value)
                }
            }
        }
        if indicSet.id == "VOLUME" {
            valueMin = 0.0
            vvalueMin = 0.0
            text = Calculate.formatNumber(csp.roundDec, valueMax)
            let pos1 = (text.count / 4) - 1
            if pos1 > 0  {
                valueDiv = pow(10, Double(pos1 * 3) )
            } else {
                valueDiv = 1.00
            }
        }
    }

    private func quotePosition (_ quote: Double) -> CGFloat {
        guard let histQuote = csp.histQuote else {
            return 1
        }
       //BUG in Graphic : this application, or a library it uses, has passed an invalid numeric value (NaN, or not-a-number) to CoreGraphics API and this value is being ignored. Please fix this problem.
        
        if indicSet.id == "RSLine" && histQuote.id == "SP500" {
            return 1
        }
        
        if indicSet.id == "VOLUME" && valueMax == 0.0 {
            return 1
        }
        
        if indicSet.type == IndicatorType.Follow.rawValue  {
            let nquote = (quote - vvalueMin ) / scaleLine
            return CGFloat(nquote) * scaleLigneF
        } else if indicSet.type == IndicatorType.Point.rawValue {
            let nquote = (quote - vvalueMin ) / scaleLine
            return CGFloat(nquote) * scaleLigneF
        } else {
            return gh * CGFloat(quote) / 100
        }
    }
    //*****************************************************************
    func buildChart(rootLayer: CALayer,
                    w: CGFloat, h: CGFloat,
                    x: CGFloat, y: CGFloat,
                    pw0: CGFloat, pw1: CGFloat) {
        
        if h < 10  || w < 10 {
            return
        }

        self.pw0 = pw0
        self.pw1 = pw1
        ph0 = y + ChartDefaultValue.hhIndic
        ph1 = y + h - ChartDefaultValue.hhIndic
        gw = pw1 - pw0
        gh = ph1 - ph0
        
        let path2 = NSBezierPath(rect:  NSMakeRect(x + 2, y + 2, w - 4, h - 4))
        let box1PathLayer = self.box1PathLayer ?? CAShapeLayer()
        box1PathLayer.path = path2.cgPath
        box1PathLayer.lineWidth = 1
        box1PathLayer.lineCap = .round
        box1PathLayer.strokeColor = ChartDefaultValue.box1Color.cgColor
        rootLayer.addSublayer(box1PathLayer)
        
        let path3 = NSBezierPath(rect: NSMakeRect(self.pw0 ,self.ph0, gw, gh))
        let box2PathLayer = self.box2PathLayer ?? CAShapeLayer()
        box2PathLayer.path = path3.cgPath
        box2PathLayer.lineWidth = 1.0
        box2PathLayer.lineCap = .round
        box2PathLayer.strokeColor = ChartDefaultValue.box2Color.cgColor
        rootLayer.addSublayer(box2PathLayer)
 
        // check if there is enough Data to draw
        for indicD in indicDrawArray {
            
            if indicSet.id == "RSLine" {
                continue
            }

            guard indicD.getValue(at: csp.dateMax) != nil else {
                text = "\(indicSet.desc) : 0.0"
                let width = ChartDefaultValue.textBoldWidth(text: text) * 1.1
                headerLayer.frame = NSMakeRect(pw0 + 2, ph1 - ChartDefaultValue.hhIndic - ChartDefaultValue.fontHeight / 2 - 2, width, 15)
                headerLayer.string = text
                rootLayer.addSublayer(headerLayer)
                return
            }
        }
       
///******************************** PAINT LINE************************************
        var xh: CGFloat = 0, xw1: CGFloat = 0, xh1: CGFloat = 0
        
        if indicSet.type != IndicatorType.Oscillator.rawValue {
            let linePathLayer = self.linePathLayer ?? CAShapeLayer()
            
            lineCount = Int(gh / ChartDefaultValue.scaleLigneD)
            scaleLine = (vvalueMax - vvalueMin) / Double(lineCount)
            if (scaleLine < 0.0 ) {
                return
            }
            scaleLigneF = gh / CGFloat(lineCount)
            xh = ph0 + scaleLigneF
            
            var de = vvalueMin + scaleLine
            
            xw1 = pw1 + 9
            
            let linePath = NSBezierPath()
            
            for _ in 1...lineCount - 1 {
                text = Calculate.formatNumber(csp.roundDec, de / valueDiv)
                xh1 = xh - ChartDefaultValue.fontHeight / 4
                
                rootLayer.addSublayer(textLayer(text: text, x: xw1, y: xh1, foreColor: csp.chartD.lineColor))
                
                linePath.move(to: CGPoint(x: pw0 + 1, y: xh))
                linePath.line(to: CGPoint(x: pw1 - 1, y: xh))
                
                xh += scaleLigneF
                de += scaleLine
            }
            linePathLayer.path = linePath.cgPath
            linePathLayer.opacity = 1
            linePathLayer.lineWidth = 1.0
            linePathLayer.lineCap = .round
            linePathLayer.strokeColor = csp.chartD.lineColor.cgColor
           
            if self.linePathLayer == nil {
                self.linePathLayer = linePathLayer
            }
            rootLayer.addSublayer(linePathLayer)
            
        } else {
            scaleLine = 100.0
            xw1 = pw1 + 9
        }
        
        if indicSet.splineZero == "1" {
            let linePathZeroLayer = self.linePathZeroLayer ?? CAShapeLayer()

            xh = ph0 + quotePosition(0.0)
            xh1 = xh - ChartDefaultValue.fontHeight / 4

            text = "0.0"
            rootLayer.addSublayer(textLayer(text: text, x: xw1, y: xh1, foreColor: indicSet.splineColor0))
            
            let linePathZero = NSBezierPath()
            linePathZero.move(to: CGPoint(x: pw0 + 1, y: xh))
            linePathZero.line(to: CGPoint(x: pw1 - 1, y: xh))
           
            linePathZeroLayer.path = linePathZero.cgPath
            linePathZeroLayer.opacity = 1
            linePathZeroLayer.lineWidth = 2.0
            linePathZeroLayer.lineCap = .round
            linePathZeroLayer.strokeColor = indicSet.splineColor0.cgColor
           
            if self.linePathZeroLayer == nil {
                self.linePathZeroLayer = linePathZeroLayer
            }
            rootLayer.addSublayer(linePathZeroLayer)
        }
        
        if linePrint1.count > 0 {
            let linePathLine1Layer = self.linePathLine1Layer ?? CAShapeLayer()
            let linePathLine1 = NSBezierPath()

            for linePrintValue in linePrint1 {
                xh = ph0 + quotePosition(Double(linePrintValue))
                if xh > ph1 || xh < ph0 {
                    continue
                }
                xh1 = xh - ChartDefaultValue.fontHeight / 4
                text = String(linePrintValue)
                rootLayer.addSublayer(textLayer(text: text, x: xw1, y: xh1, foreColor: indicSet.splineColor1))
                
                linePathLine1.move(to: CGPoint(x: pw0 + 1, y: xh))
                linePathLine1.line(to: CGPoint(x: pw1 - 1, y: xh))
            }
            linePathLine1Layer.path = linePathLine1.cgPath
            linePathLine1Layer.opacity = 1
            linePathLine1Layer.lineWidth = 2.0
            linePathLine1Layer.lineCap = .round
            linePathLine1Layer.strokeColor = indicSet.splineColor1.cgColor
           
            if self.linePathLine1Layer == nil {
                self.linePathLine1Layer = linePathLine1Layer
            }
            rootLayer.addSublayer(linePathLine1Layer)
        }
        
        if linePrint2.count > 0 {
            let linePathLine2Layer = self.linePathLine2Layer ?? CAShapeLayer()
            let linePathLine2 = NSBezierPath()
            
            for linePrintValue in linePrint2 {
                xh = ph0 + quotePosition(Double(linePrintValue))
                if xh > ph1 || xh < ph0 {
                    continue
                }
                xh1 = xh - 5
                text = String(linePrintValue)
                rootLayer.addSublayer(textLayer(text: text, x: xw1, y: xh1, foreColor: indicSet.splineColor2))

                linePathLine2.move(to: CGPoint(x: pw0 + 1, y: xh))
                linePathLine2.line(to: CGPoint(x: pw1 - 1, y: xh))
            }

            linePathLine2Layer.path = linePathLine2.cgPath
            linePathLine2Layer.opacity = 1
            linePathLine2Layer.lineWidth = 2.0
            linePathLine2Layer.lineCap = .round
            linePathLine2Layer.strokeColor = indicSet.splineColor2.cgColor
           
            if self.linePathLine2Layer == nil {
                self.linePathLine2Layer = linePathLine2Layer
            }
            rootLayer.addSublayer(linePathLine2Layer)

        }
///******************************** PAINT COLUMUN ************************************
        var yw =  csp.firstPosition
        var monthTest: Int = 0, monthSave: Int = 0
        let columnPath = NSBezierPath()
        let columnPathLayer = self.columnPathLayer ?? CAShapeLayer()

        monthSave = CDate.addMonth(csp.dateArray.first!, csp.monthCount)
        
        for indicD in indicDrawArray {
            indicD.clearPath()
        }
        
        for  lineDate in csp.dateArray {
            
            for indicD in indicDrawArray {

                if let indicValue = indicD.getValue(at: lineDate) {
                    if indicD.model == IndicatorModel.Histogram.rawValue {
                        if indicValue > 0 {
                            indicD.pathColor1.move(to: CGPoint(x: yw, y: ph0 + quotePosition(0.0)) )
                            indicD.pathColor1.line(to: CGPoint(x: yw, y: ph0 + quotePosition(indicValue)) )
                        } else {
                            indicD.pathColor2.move(to: CGPoint(x: yw, y: ph0 + quotePosition(0.0)) )
                            indicD.pathColor2.line(to: CGPoint(x: yw, y: ph0 + quotePosition(indicValue)) )
                        }
                    } else if  indicD.model == IndicatorModel.Point.rawValue {
                        
                        let yy = quotePosition(indicValue)
                        if indicValue <= 0.0 {
                            indicD.pathColor1.appendRect(NSMakeRect(yw - (csp.scaleColumnF / 2.0) + 0.7, ph0 + yy,  csp.scaleColumnF - 0.7 , 3 ))
                        } else {
                            indicD.pathColor2.appendRect(NSMakeRect(yw - (csp.scaleColumnF / 2.0) + 0.7, ph0 + yy,  csp.scaleColumnF - 0.7 , 3 ))
                        }
                        
                    } else {
                        if indicD.pathColor1.elementCount == 0 {
                            indicD.pathColor1.move(to: CGPoint(x: yw, y: ph0 + quotePosition(indicValue)) )
                        } else {
                            indicD.pathColor1.line(to: CGPoint(x: yw, y: ph0 + quotePosition(indicValue)) )
                            indicD.pathColor1.move(to: CGPoint(x: yw, y: ph0 + quotePosition(indicValue)) )
                        }
                    }
                }
            }
            
            monthTest = CDate.getMonth(lineDate)
            if monthTest == monthSave {
                columnPath.move(to: CGPoint(x: yw, y: ph1))
                columnPath.line(to: CGPoint(x: yw, y: ph0))
                monthSave = CDate.addMonth(lineDate, csp.monthCount)
            }
            
            yw += csp.scaleColumnF
        }
        
        columnPathLayer.path = columnPath.cgPath
        columnPathLayer.opacity = 1
        columnPathLayer.lineCap = .round
        columnPathLayer.strokeColor = csp.chartD.columnColor.cgColor
        
        if self.columnPathLayer == nil {
            self.columnPathLayer = columnPathLayer
        }
        rootLayer.addSublayer(columnPathLayer)
    
///********************************* HEADER  *****************************************
  
        text = "" 
        /// sorted to draw point in last
        for indicD in indicDrawArray.sorted(by: { $0.model < $1.model }) {
            text = "\(text) \(indicD.desc) : \(Calculate.formatNumber(csp.roundDec, indicD.getValue(at: csp.dateMax) ?? 0.0))"
         
            if indicD.pathColor1.elementCount > 0 {
                indicD.setPathColor1(model: indicD.model)
                rootLayer.addSublayer(indicD.pathColor1Layer)
            }
            
            if indicD.pathColor2.elementCount > 0 {
                indicD.setPathColor2(model: indicD.model)
                rootLayer.addSublayer(indicD.pathColor2Layer!)
            }
        }
        
        if indicSet.id == "VOLUME" {
            text = "\(text) / \(Calculate.formatNumber(csp.roundDec, valueDiv)) "
        }
        
        let width = ChartDefaultValue.textBoldWidth(text: text) * 1.1
        headerLayer.frame = NSMakeRect(pw0 + 2, ph1 - ChartDefaultValue.hhIndic - ChartDefaultValue.fontHeight / 2 - 2, width, 15)
        headerLayer.string = text
        rootLayer.addSublayer(headerLayer)
    }
    
    func textLayer(text: String, x: CGFloat, y: CGFloat, foreColor: NSColor) -> CATextLayer {
        let lineText = CATextLayer()
        lineText.foregroundColor = foreColor.cgColor
        lineText.backgroundColor = csp.chartD.backColor.cgColor
        lineText.alignmentMode = CATextLayerAlignmentMode.left
        lineText.contentsScale = NSScreen.main!.backingScaleFactor
        lineText.font = ChartDefaultValue.font
        lineText.fontSize = ChartDefaultValue.fontSize
        let width = ChartDefaultValue.textWidth(text: text) * 1.1
        lineText.frame = NSMakeRect(x, y, width, 15)
        lineText.string = text
        return lineText
    }
}
