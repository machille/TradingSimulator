//
//  ChartQuoteView.swift
//  Trading
//
//  Created by Maroun Achille on 04/12/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartQuoteLayer {
    
    private var w: CGFloat = 0, h: CGFloat = 0
    
    private var ph0: CGFloat = 0, pw0: CGFloat = 0
    private var ph1: CGFloat = 0, pw1: CGFloat = 0
    private var gh: CGFloat = 0, gw: CGFloat = 0
    
    private var scaleLigneF: CGFloat = 20.0
    private var scaleColumnD: CGFloat = 1.0
    
    private var scalePrice: Double = 0.0
    private var text: String = " "
    private var widthText: CGFloat = 0
    
    private let quoteTextLayer = CATextLayer()
    private let headerLayer = CATextLayer()
    private let headerQuoteLayer = CATextLayer()
    private let quoteLayer = CATextLayer()
    
    private var paintLineLayer: CAShapeLayer?
    
    private var box1Layer = CAShapeLayer()
    private var box2Layer = CAShapeLayer()
    
    private var columnPathLayer: CAShapeLayer?
    private var linePathLayer: CAShapeLayer?
    private var jcLowPathLayer: CAShapeLayer?
    private var jcHighPathLayer: CAShapeLayer?
    private var jcHighBodyPathLayer: CAShapeLayer?
    private var jcLowBodyPathLayer: CAShapeLayer?
    
    var csp: ChartControllerView
    
    init(csp: ChartControllerView) {
        self.csp = csp
        
        headerLayer.foregroundColor = csp.chartD.headColor.cgColor
        headerLayer.backgroundColor = csp.chartD.backColor.cgColor
        headerLayer.alignmentMode = CATextLayerAlignmentMode.left
        headerLayer.contentsScale = NSScreen.main!.backingScaleFactor
        headerLayer.font = ChartDefaultValue.headerFont
        headerLayer.fontSize = ChartDefaultValue.fontSize
        headerLayer.cornerRadius = 3.0
        
        headerQuoteLayer.foregroundColor = csp.chartD.backColor.cgColor
        headerQuoteLayer.alignmentMode = CATextLayerAlignmentMode.center
        headerQuoteLayer.contentsScale = NSScreen.main!.backingScaleFactor
        headerQuoteLayer.font = ChartDefaultValue.font
        headerQuoteLayer.fontSize = ChartDefaultValue.fontSize
        headerQuoteLayer.cornerRadius = 3.0
        
        quoteLayer.foregroundColor = csp.chartD.backColor.cgColor
        quoteLayer.alignmentMode = CATextLayerAlignmentMode.center
        quoteLayer.contentsScale = NSScreen.main!.backingScaleFactor
        quoteLayer.font = ChartDefaultValue.font
        quoteLayer.fontSize = ChartDefaultValue.fontSize
        quoteLayer.cornerRadius = 3.0
        
        quoteTextLayer.backgroundColor = csp.chartD.headColor.cgColor
        quoteTextLayer.foregroundColor = csp.chartD.backColor.cgColor
        quoteTextLayer.alignmentMode = CATextLayerAlignmentMode.left
        quoteTextLayer.contentsScale = NSScreen.main!.backingScaleFactor
        quoteTextLayer.font = ChartDefaultValue.font
        quoteTextLayer.fontSize = ChartDefaultValue.fontSize
        quoteTextLayer.cornerRadius = 3.0
    }
    
    func quotePosition (_ quote: Double) -> CGFloat {
        let nquote = (quote - csp.ppriceMin) / scalePrice
        return CGFloat(nquote) * scaleLigneF
    }
    
    func positionQuote (_ position: CGFloat) -> Double {
        return csp.ppriceMin + ( Double(position - ph0 + 0.4) * scalePrice / Double(scaleLigneF))
    }
    
    func buildChart(rootLayer: CALayer,
                    w: CGFloat, h: CGFloat,
                    x: CGFloat, y: CGFloat,
                    pw0: CGFloat, pw1: CGFloat,
                    ph0: CGFloat, ph1: CGFloat) {
  
        if h < 10  || w < 10 {
            return
        }

        guard csp.histQuote != nil else {
            return
        }
        
        let hh = rootLayer.bounds.height
            
        self.pw0 = pw0
        self.pw1 = pw1
        self.ph0 = ph0
        self.ph1 = ph1
                
        self.gw = self.pw1 - pw0 - ChartDefaultValue.wMargin
        self.gh = ph1 - self.ph0

        let boxPath1 = NSBezierPath(rect: NSMakeRect(x + 2, y + 2, w - 4, h - 4))
        box1Layer.path = boxPath1.cgPath
        box1Layer.lineWidth = 1
        box1Layer.lineCap = .round
        box1Layer.fillRule = CAShapeLayerFillRule.evenOdd
        box1Layer.strokeColor = ChartDefaultValue.box1Color.cgColor
        rootLayer.addSublayer(box1Layer)
        
        let boxPath2 = NSBezierPath(rect: NSMakeRect(pw0 ,ph0, gw + ChartDefaultValue.wMargin, gh))
        box2Layer.path = boxPath2.cgPath
        box2Layer.lineWidth = 1
        box2Layer.lineCap = .round
        box2Layer.fillRule = CAShapeLayerFillRule.evenOdd
        box2Layer.strokeColor = ChartDefaultValue.box2Color.cgColor
        rootLayer.addSublayer(box2Layer)
        
        quoteTextLayer.frame = NSMakeRect(w - 425 - 32, hh - 22 , 425 - 4 , 18)
        rootLayer.addSublayer(quoteTextLayer)
        
        let lineCount = Int(gh / ChartDefaultValue.scaleLigneD)
        scalePrice = (csp.ppriceMax - csp.ppriceMin) / Double(lineCount)
        
        if scalePrice < 0.0  || lineCount < 4 {
            return
        }
        scaleLigneF = gh / CGFloat(lineCount)

        paintLine(rootLayer: rootLayer, lineCount: lineCount)
        
        if csp.chartD.model == ChartModel.LineChart.rawValue {
            paintColumnLine(rootLayer: rootLayer)
        } else if csp.chartD.model == ChartModel.BarsChart.rawValue {
            paintColumnHL(rootLayer: rootLayer)
        } else {
            paintColumnJC(rootLayer: rootLayer)
        }

        paintHeader(rootLayer: rootLayer)

        paintIndicChart(rootLayer: rootLayer)

        if csp.chartD.type != ChartType.Weekly.rawValue {
            paintArrow(rootLayer: rootLayer)
        }
    }
    
    //MARK: -- Paint Line
    private func paintLine(rootLayer: CALayer, lineCount: Int)  {
            
        let paintLineLayer = self.paintLineLayer ?? CAShapeLayer()
        let linePath = NSBezierPath()

        var xh: CGFloat, xw1: CGFloat, xh1: CGFloat
        var de = csp.ppriceMin
            
        xw1 = pw1 + 5
        xh = ph0
            
        for _ in 1...lineCount-1 {
            xh += scaleLigneF
            de += scalePrice

            text = Calculate.formatNumber(csp.roundDec, de)
            xh1 = xh - 5
            rootLayer.addSublayer(textLayer(text: text, x: xw1, y: xh1, foreColor: csp.chartD.lineColor))
                
            linePath.move(to: CGPoint(x: pw0 + 1, y: xh))
            linePath.line(to: CGPoint(x: pw1 - 1, y: xh))

        }
            
        paintLineLayer.path = linePath.cgPath
        paintLineLayer.opacity = 1
        paintLineLayer.lineCap = .round
        paintLineLayer.fillRule = CAShapeLayerFillRule.evenOdd
        paintLineLayer.strokeColor = csp.chartD.lineColor.cgColor
                  
        if self.paintLineLayer == nil {
            self.paintLineLayer = paintLineLayer
        }
        rootLayer.addSublayer(paintLineLayer)
    }

    //MARK: - paint chart in line mode
    private func paintColumnLine(rootLayer: CALayer) {

        let columnPathLayer = self.columnPathLayer ?? CAShapeLayer()
        let linePathLayer = self.linePathLayer ?? CAShapeLayer()
            
        let linePath = NSBezierPath()
        let columnPath = NSBezierPath()
            
        var yw: CGFloat = 0.0 , yh: CGFloat = 0.0, yw1: CGFloat = 0.0
        var monthTest: Int  = 0, monthSave: Int = 0
        var aCount: Int = 0, dayCount: Int = 0, j2: Int = 0
            
        scaleColumnD = 1.0
        dayCount = csp.numberOfRows()
            
        csp.scaleColumnF = gw / (CGFloat(dayCount) * scaleColumnD)
        csp.dayFrequency = Int ((1 + csp.scaleColumnF ) / csp.scaleColumnF )
        csp.scaleColumnF = csp.scaleColumnF * CGFloat(csp.dayFrequency)  * scaleColumnD
        aCount = Int(round(Double(dayCount / csp.dayFrequency) ) )
        csp.columnPoint = Array(repeating: 0.0, count: aCount+2)
            
        csp.firstPosition = pw0
        yw = csp.firstPosition
        yh = ph0 - ChartDefaultValue.fontHeight
            
        if csp.scaleColumnF < 2.0 {
            csp.monthCount = csp.dayFrequency * 2
        } else {
            csp.monthCount = csp.dayFrequency
        }
            
        if csp.chartD.type == ChartType.Weekly.rawValue {
            csp.monthCount += 1
        }
        monthSave = CDate.addMonth(csp.dateMin, csp.monthCount)
        
        if let sharep = csp.getStockQuote(at: csp.dateMin) {
            linePath.move(to: CGPoint(x: yw, y: ph0 + quotePosition(sharep.close)) )
        } else {
            return
        }
        csp.columnPoint[j2] = pw0
            
        for i in stride(from: 0, to: csp.numberOfRows(), by: csp.dayFrequency) {
            let sQuote = csp.histQuoteArray[i]
            csp.dateArray.append(sQuote.dateQuote)
            monthTest = CDate.getMonth(sQuote.dateQuote)
                
            if monthTest == monthSave {
                text = CDate.formatDate(sQuote.dateQuote , ChartDefaultValue.dateFormat)
                yw1 = yw - ( ChartDefaultValue.fontWidth / 2 )
                rootLayer.addSublayer(textLayer(text: text, x: yw1, y: yh, foreColor: csp.chartD.columnColor))
                    
                columnPath.move(to: CGPoint(x: yw, y: ph1))
                columnPath.line(to: CGPoint(x: yw, y: ph0))
                monthSave = CDate.addMonth(sQuote.dateQuote, csp.monthCount)
            }
            linePath.line(to: CGPoint(x: yw, y: ph0 + quotePosition(sQuote.close)))
            linePath.move(to: CGPoint(x: yw, y: ph0 + quotePosition(sQuote.close)))
                
            j2 += 1
            yw += csp.scaleColumnF
            csp.columnPoint[j2] = yw - (csp.scaleColumnF / 2)
        }

        columnPathLayer.path = columnPath.cgPath
        columnPathLayer.opacity = 1
        columnPathLayer.lineCap = .round
        columnPathLayer.strokeColor = csp.chartD.columnColor.cgColor

        linePathLayer.path = linePath.cgPath
        linePathLayer.opacity = 1
        linePathLayer.lineWidth = 2.0
        linePathLayer.lineCap = .round
        linePathLayer.strokeColor = csp.chartD.defaultColor.cgColor
           
        if self.linePathLayer == nil {
            self.linePathLayer = linePathLayer
        }
        rootLayer.addSublayer(linePathLayer)

        if self.columnPathLayer == nil {
            self.columnPathLayer = columnPathLayer
        }
        rootLayer.addSublayer(columnPathLayer)
    }
        
        // MARK: - paint chart in Bar chart High Low
        private func paintColumnHL(rootLayer: CALayer) {
     
            let columnPathLayer = self.columnPathLayer ?? CAShapeLayer()
            let linePathLayer = self.linePathLayer ?? CAShapeLayer()

            let linePath = NSBezierPath()
            let columnPath = NSBezierPath()
            
            var yw: CGFloat = 0 , yh: CGFloat = 0, yw1 : CGFloat = 0.0
            var monthTest: Int  = 0, monthSave: Int = 0
            var aCount: Int = 0, dayCount: Int = 0, j2: Int = 0
            var fpHight: Double = 0.0, fpLow: Double = 0.0, fpOpen: Double = 0.0
            
            scaleColumnD = 3.0 //param.getScaleColumnD()
            dayCount = csp.numberOfRows()
            csp.scaleColumnF = (gw - scaleColumnD)  / (CGFloat(dayCount) * scaleColumnD )
            csp.dayFrequency = Int((1 + csp.scaleColumnF ) / csp.scaleColumnF )
            csp.scaleColumnF = csp.scaleColumnF * CGFloat(csp.dayFrequency)  * scaleColumnD
            aCount = Int(round(Double(dayCount / csp.dayFrequency ) ) )
            csp.columnPoint = Array(repeating: 0.0, count: aCount+2)
            
            csp.firstPosition = pw0  + scaleColumnD
            yw = csp.firstPosition + 1.0
            yh = ph0 - ChartDefaultValue.fontHeight
            
            if (csp.scaleColumnF < 2.0) {
                csp.monthCount = csp.dayFrequency * 2
            } else {
                csp.monthCount = csp.dayFrequency
            }
            
            if csp.chartD.type == ChartType.Weekly.rawValue {
                csp.monthCount += 1
            }
            
            monthSave = CDate.addMonth(csp.dateMin, csp.monthCount)
            csp.columnPoint[j2] = pw0
            
            var histIterator = csp.histQuoteArray.makeIterator()
            while let sQuote = histIterator.next() {
                
                fpOpen = sQuote.open
                fpHight = sQuote.high
                fpLow = sQuote.low
                
                if  csp.dayFrequency > 1 {
                    for _ in 1..<csp.dayFrequency {
                        if let sQuote = histIterator.next() {
                            fpHight = max(fpHight, sQuote.high)
                            fpLow = min(fpLow, sQuote.low)
                        } else {
                            break
                        }
                    }
                }
                
                csp.dateArray.append(sQuote.dateQuote)
                monthTest = CDate.getMonth(sQuote.dateQuote)
                
                if monthTest == monthSave {
                    text = CDate.formatDate(sQuote.dateQuote , ChartDefaultValue.dateFormat)
                    yw1 = yw - ( ChartDefaultValue.fontWidth / 2 )
                    rootLayer.addSublayer(textLayer(text: text, x: yw1, y: yh, foreColor: csp.chartD.columnColor))
                    
                    columnPath.move(to: CGPoint(x: yw, y: ph1))
                    columnPath.line(to: CGPoint(x: yw, y: ph0))
                    monthSave = CDate.addMonth(sQuote.dateQuote, csp.monthCount)
                }
                
                linePath.move(to: CGPoint(x: yw, y: ph0 + quotePosition(fpHight)))
                linePath.line(to: CGPoint(x: yw, y: ph0 + quotePosition(fpLow)))
                linePath.move(to: CGPoint(x: yw, y: ph0 + quotePosition(sQuote.close)))
                linePath.line(to: CGPoint(x: yw + 2.0, y: ph0 + quotePosition(sQuote.close)))
                linePath.move(to: CGPoint(x: yw - 2.0, y: ph0 + quotePosition(fpOpen)))
                linePath.line(to: CGPoint(x: yw, y: ph0 + quotePosition(fpOpen)))
                
                j2 += 1
                yw += csp.scaleColumnF
                csp.columnPoint[j2] = yw - (csp.scaleColumnF / 2)
            }
            
            columnPathLayer.path = columnPath.cgPath
            columnPathLayer.opacity = 1
            columnPathLayer.lineCap = .round
            columnPathLayer.strokeColor = csp.chartD.columnColor.cgColor

            linePathLayer.path = linePath.cgPath
            linePathLayer.opacity = 1
            linePathLayer.lineWidth = 2.0
            linePathLayer.lineCap = .round
            linePathLayer.strokeColor = csp.chartD.defaultColor.cgColor
           
            if self.linePathLayer == nil {
                self.linePathLayer = linePathLayer
            }
            rootLayer.addSublayer(linePathLayer)

            if self.columnPathLayer == nil {
                self.columnPathLayer = columnPathLayer
            }
            rootLayer.addSublayer(columnPathLayer)
        }
        
        // MARK: - paint chart in Japanese candle
        private func paintColumnJC(rootLayer: CALayer) {
        
            var yw: CGFloat = 0 , yh: CGFloat = 0, yw1: CGFloat = 0.0, yy: CGFloat = 0.0, diff: CGFloat = 0.0
            var monthTest: Int  = 0, monthSave: Int = 0
            var aCount: Int = 0, dayCount: Int = 0, j2: Int = 0
            var fpHight: Double = 0.0, fpLow: Double = 0.0, fpOpen: Double = 0.0
        
            let columnPathLayer = self.columnPathLayer ?? CAShapeLayer()
            let jcLowPathLayer = self.jcLowPathLayer ?? CAShapeLayer()
            let jcHighPathLayer = self.jcHighPathLayer ?? CAShapeLayer()
            let jcHighBodyPathLayer = self.jcHighBodyPathLayer ?? CAShapeLayer()
            let jcLowBodyPathLayer = self.jcLowBodyPathLayer ?? CAShapeLayer()
            
            let columnPath = NSBezierPath()
            let jcLowPath = NSBezierPath()
            let jcHighPath = NSBezierPath()
            let jcHighBodyPath = NSBezierPath()
            let jcLowBodyPath = NSBezierPath()
            
            scaleColumnD = 3 //param.getScaleColumnD();
            
            dayCount = csp.numberOfRows()
            csp.scaleColumnF = (gw - scaleColumnD)  / (CGFloat(dayCount) * scaleColumnD )
            csp.dayFrequency = Int((1 + csp.scaleColumnF ) / csp.scaleColumnF )
            csp.scaleColumnF = csp.scaleColumnF * CGFloat(csp.dayFrequency)  * scaleColumnD
            aCount = Int(round(Double(dayCount / csp.dayFrequency ) ) )
            csp.columnPoint = Array(repeating: 0.0, count: aCount+2)
            
            csp.firstPosition = pw0  + scaleColumnD
            yw = csp.firstPosition + 1.0
            yh = ph0 - ChartDefaultValue.fontHeight
            
            if (csp.scaleColumnF < 2.0) {
                csp.monthCount = csp.dayFrequency * 2
            } else {
                csp.monthCount = csp.dayFrequency
            }
            
            if csp.chartD.type == ChartType.Weekly.rawValue {
                csp.monthCount += 1
            }
            monthSave = CDate.addMonth(csp.dateMin, csp.monthCount)
            csp.columnPoint[j2] = pw0
            
            var histIterator = csp.histQuoteArray.makeIterator()
            while let sQuote = histIterator.next() {
                fpOpen = sQuote.open
                fpHight = sQuote.high
                fpLow = sQuote.low
                if csp.dayFrequency > 1 {
                    for _ in 1..<csp.dayFrequency {
                        if let sQuote = histIterator.next() {
                            fpHight = max(fpHight, sQuote.high)
                            fpLow = min(fpLow, sQuote.low)
                        } else {
                            break
                        }
                    }
                }
                csp.dateArray.append(sQuote.dateQuote)
                monthTest = CDate.getMonth(sQuote.dateQuote)
                
                if monthTest == monthSave {
                    text = CDate.formatDate(sQuote.dateQuote , ChartDefaultValue.dateFormat)
                    yw1 = yw - ( ChartDefaultValue.fontWidth / 2 )
                    rootLayer.addSublayer(textLayer(text: text, x: yw1, y: yh, foreColor: csp.chartD.columnColor))
                    
                    columnPath.move(to: CGPoint(x: yw, y: ph1))
                    columnPath.line(to: CGPoint(x: yw, y: ph0))
                    monthSave = CDate.addMonth(sQuote.dateQuote, csp.monthCount)
                }
                
                diff = abs( quotePosition(fpOpen) - quotePosition(sQuote.close) )
                diff = diff < 1 ? 1 : diff
                
                if fpOpen > sQuote.close {
                    jcLowPath.move(to: CGPoint(x: yw, y: ph0 + quotePosition(fpHight)))
                    jcLowPath.line(to: CGPoint(x: yw, y: ph0 + quotePosition(fpLow)))
                    yy = quotePosition(sQuote.close)
                    jcLowBodyPath.appendRect(NSMakeRect(yw - (csp.scaleColumnF / 2.0) + 0.5, ph0 + yy,  csp.scaleColumnF - 0.5 , diff ))
                } else {
                    jcHighPath.move(to: CGPoint(x: yw, y: ph0 + quotePosition(fpHight)))
                    jcHighPath.line(to: CGPoint(x: yw, y: ph0 + quotePosition(fpLow)))
                    yy = quotePosition(fpOpen)
                    jcHighBodyPath.appendRect(NSMakeRect(yw - (csp.scaleColumnF / 2.0) + 0.5, ph0 + yy,  csp.scaleColumnF - 0.5 , diff ))
                }
                
                j2 += 1
                yw += csp.scaleColumnF
                csp.columnPoint[j2] = yw - (csp.scaleColumnF / 2)
            }
            
            
            columnPathLayer.path = columnPath.cgPath
            columnPathLayer.opacity = 1
            columnPathLayer.lineCap = .round
            columnPathLayer.strokeColor = csp.chartD.columnColor.cgColor

            if self.columnPathLayer == nil {
                self.columnPathLayer = columnPathLayer
            }
            rootLayer.addSublayer(columnPathLayer)

            jcHighPathLayer.path = jcHighPath.cgPath
            jcHighPathLayer.opacity = 1
            jcHighPathLayer.lineCap = .round
            jcHighPathLayer.strokeColor = csp.chartD.jcHighColor.cgColor

            if self.jcHighPathLayer == nil {
                self.jcHighPathLayer = jcHighPathLayer
            }
            rootLayer.addSublayer(jcHighPathLayer)
            
            
            jcLowPathLayer.path = jcLowPath.cgPath
            jcLowPathLayer.opacity = 1
            jcLowPathLayer.lineCap = .round
            jcLowPathLayer.strokeColor = csp.chartD.jcLowColor.cgColor
            
            if self.jcLowPathLayer == nil {
                self.jcLowPathLayer = jcLowPathLayer
            }
            rootLayer.addSublayer(jcLowPathLayer)

            jcHighBodyPathLayer.path = jcHighBodyPath.cgPath
            jcHighBodyPathLayer.opacity = 1
            jcHighBodyPathLayer.lineCap = .round
            jcHighBodyPathLayer.fillColor = csp.chartD.jcHighColor.cgColor
           
            if self.jcHighBodyPathLayer == nil {
                self.jcHighBodyPathLayer = jcHighBodyPathLayer
            }
            rootLayer.addSublayer(jcHighBodyPathLayer)
            
            jcLowBodyPathLayer.path = jcLowBodyPath.cgPath
            jcLowBodyPathLayer.opacity = 1
            jcLowBodyPathLayer.lineCap = .round
            jcLowBodyPathLayer.fillColor = csp.chartD.jcLowColor.cgColor
            
            if self.jcLowBodyPathLayer == nil {
                self.jcLowBodyPathLayer = jcLowBodyPathLayer
            }
            rootLayer.addSublayer(jcLowBodyPathLayer)
        }

    // MARK: - **.**.**.**.**.** Paint Header  **.**.**.**.**.**
    private func paintHeader(rootLayer: CALayer) {

        let hx: CGFloat = pw0 + 2
        var hy: CGFloat = ph1 + ChartDefaultValue.fontHeight + 2
            
        text = "\(csp.stockId) : \(csp.stockName), from : \(CDate.formatDate(csp.dateFrom, "dd-MMM-yy")) to : \(CDate.formatDate(csp.dateTo, "dd-MMM-yy")) : \(csp.chartD.period) - Frequency \(csp.dayFrequency) \(csp.chartD.type) Atr = \(Calculate.formatNumber(1, csp.atrValue / csp.lastQuote.close * 100)) %"
            
        var width = ChartDefaultValue.textBoldWidth(text: text) * 1.1
        headerLayer.frame = NSMakeRect(hx, hy, width, 15)
        headerLayer.string = text
        rootLayer.addSublayer(headerLayer)
            
        var res: Double = 0.0
        text = Calculate.formatNumber(csp.roundDec, (csp.lastQuote.close))

            // Line2
        hy = hy - ChartDefaultValue.fontHeight + 2
            
        res = csp.lastVar
        if res == 0 {
            headerQuoteLayer.backgroundColor = ChartDefaultValue.backWhiteColor.cgColor
            quoteLayer.backgroundColor = ChartDefaultValue.backWhiteColor.cgColor
        } else if res > 0 {
            headerQuoteLayer.backgroundColor = ChartDefaultValue.greenColor.cgColor
            quoteLayer.backgroundColor = ChartDefaultValue.greenColor.cgColor
        } else {
            headerQuoteLayer.backgroundColor = ChartDefaultValue.redColor.cgColor
            quoteLayer.backgroundColor = ChartDefaultValue.redColor.cgColor
        }
            
        width = ChartDefaultValue.textWidth(text: text) * 1.2
        quoteLayer.string = text
        quoteLayer.frame = NSMakeRect(pw1 + 4, ph0 + quotePosition(csp.lastQuote.close), width, 15)
        rootLayer.addSublayer(quoteLayer)

        text = " \(text)  (\(Calculate.formatVar(2, res))) "
        width = ChartDefaultValue.textWidth(text: text)
        headerQuoteLayer.string = text
        headerQuoteLayer.frame = NSMakeRect(hx, hy, width, 15)
        rootLayer.addSublayer(headerQuoteLayer)
            
        _ = updateQuoteLabel(date: csp.dateArray.last!)
    }
        
    private func paintArrow(rootLayer: CALayer) {

        if csp.orderArrowArray.count < 1 {
            return
        }
        var yw: CGFloat = csp.firstPosition + 1.0
        var histIterator = csp.histQuoteArray.makeIterator()
        while let sQuote = histIterator.next() {
            if let arrowOrder = csp.orderArrowArray.first(where: { $0.date == sQuote.dateQuote }) {
                  
                if arrowOrder.type == "Long" && arrowOrder.action == "Open" {
                    if let arrow = NSImage(named: NSImage.Name("ArrowLongOpen")) {
                        let layer = CALayer()
                        rootLayer.addSublayer(layer)
                        layer.frame = NSMakeRect(yw - arrow.size.width/2 + 1 , ph0 + quotePosition(sQuote.low) - scaleLigneF * 2, arrow.size.width, arrow.size.height)
                        layer.contents = arrow
                    }
                } else if arrowOrder.type == "Long" && arrowOrder.action == "Close" {
                    if let arrow = NSImage(named: NSImage.Name("ArrowLongClose")) {
                        let layer = CALayer()
                        rootLayer.addSublayer(layer)
                        layer.frame = NSMakeRect(yw - arrow.size.width/2, ph0 + quotePosition(sQuote.high) + scaleLigneF + 1, arrow.size.width, arrow.size.height)
                            layer.contents = arrow
                    }
                } else if arrowOrder.type == "Short" && arrowOrder.action == "Open" {
                    if let arrow = NSImage(named: NSImage.Name("ArrowShortOpen")) {
                        let layer = CALayer()
                        rootLayer.addSublayer(layer)
                        layer.frame = NSMakeRect(yw - arrow.size.width/2, ph0 + quotePosition(sQuote.high) + scaleLigneF , arrow.size.width, arrow.size.height)
                        layer.contents = arrow
                    }
                } else if arrowOrder.type == "Short" && arrowOrder.action == "Close" {
                    if let arrow = NSImage(named: NSImage.Name("ArrowShortClose")) {
                        let layer = CALayer()
                        rootLayer.addSublayer(layer)
                        layer.frame = NSMakeRect(yw - arrow.size.width/2 + 2 , ph0 + quotePosition(sQuote.low) - scaleLigneF * 2, arrow.size.width, arrow.size.height)
                        layer.contents = arrow
                    }
                }
            }
            yw += csp.scaleColumnF
        }
    }
        
    // MARK: -- **.**.** paint AVERAGE Indicator **.**.**
    private func paintIndicChart(rootLayer: CALayer) {
        var avePosition: CGFloat = ChartDefaultValue.fontWidth + 110
        var yw2: CGFloat = 0
       
            // Line 2
        let hy =  ph1 + ChartDefaultValue.fontHeight + 2 - ChartDefaultValue.fontHeight + 2
            
        for indicD in csp.chartIndicArray {
            indicD.clearPath()
            yw2 = csp.firstPosition + 1
            
            if indicD.model == IndicatorModel.Point.rawValue {
                    
                for  lineDate in csp.dateArray {
                    if let indicValue = indicD.getValue(at: lineDate) {
                        if indicValue <= -1.0 {
                            indicD.pathColor2.appendRect(NSMakeRect(yw2 - (csp.scaleColumnF / 2) + 0.5 , ph0 + quotePosition(abs(indicValue)), csp.scaleColumnF - 0.5 , 2 ))
                        } else {
                            indicD.pathColor1.appendRect(NSMakeRect(yw2 - (csp.scaleColumnF / 2) + 0.5 , ph0 + quotePosition(abs(indicValue)), csp.scaleColumnF - 0.5 , 2 ))
                        }
                    }
                    yw2 += csp.scaleColumnF
                }
            } else {
                for  lineDate in csp.dateArray {
                    if let indicValue = indicD.getValue(at: lineDate) {
                            
                        if indicD.pathColor1.elementCount == 0 {
                            indicD.pathColor1.move(to: CGPoint(x: yw2, y: ph0 + quotePosition(indicValue)) )
                        } else {
                            indicD.pathColor1.line(to: CGPoint(x: yw2, y: ph0 + quotePosition(indicValue)) )
                            indicD.pathColor1.move(to: CGPoint(x: yw2, y: ph0 + quotePosition(indicValue)) )
                        }
                    }
                    yw2 += csp.scaleColumnF
                }
            }
                
            if indicD.pathColor1.elementCount > 0 {
                indicD.setPathColor1(model: indicD.model)
                rootLayer.addSublayer(indicD.pathColor1Layer)
            }
                
            if indicD.pathColor2.elementCount > 0 {
                indicD.setPathColor2(model: indicD.model)
                rootLayer.addSublayer(indicD.pathColor2Layer!)
            }
                
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.left
            
            text = "\(indicD.desc)  \(Calculate.formatNumber(csp.roundDec, indicD.getValue(at: csp.dateMax) ?? 0)) "
            rootLayer.addSublayer(indicD.textLayer(text: text, x: avePosition, y: hy, backColor: csp.chartD.backColor))
                
            widthText = ChartDefaultValue.textWidth(text: text) * 1.1
            avePosition += widthText
        }
    }
     
    func updateQuoteLabel(date: Date) -> String {
        if let stockQuote = csp.getStockQuote(at: date) {
            let layerText = " Date : " + CDate.formatDate(stockQuote.dateQuote, "dd-MM-yy") +
                "  O: " + Calculate.rightPad(value: (Calculate.formatNumber(csp.roundDec, stockQuote.open)), toLength: 10, withPad: " ") +
                "  H: " + Calculate.rightPad(value:(Calculate.formatNumber(csp.roundDec, stockQuote.high)), toLength: 10, withPad: " ") +
                "  L: " + Calculate.rightPad(value:(Calculate.formatNumber(csp.roundDec, stockQuote.low)), toLength: 10, withPad: " ") +
                "  C: " + Calculate.rightPad(value:(Calculate.formatNumber(csp.roundDec, stockQuote.close)), toLength: 10, withPad: " ")
            
            let toolTipText = "Date : " + CDate.formatDate(stockQuote.dateQuote, "dd-MM-yy") +
                "\nO: " + Calculate.formatNumber(csp.roundDec, stockQuote.open) +
                "\nH: " + Calculate.formatNumber(csp.roundDec, stockQuote.high) +
                "\nL: " + Calculate.formatNumber(csp.roundDec, stockQuote.low) +
                "\nC: " + Calculate.formatNumber(csp.roundDec, stockQuote.close)
            
            quoteTextLayer.string = layerText
            return toolTipText
        }
        return "..."
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
