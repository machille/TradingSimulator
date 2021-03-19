//
//  ChartController.swift
//  Trading
//
//  Created by Maroun Achille on 30/11/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa


class ChartControllerView: NSView {
        
    var chartD = ChartDrawing()
    
    var chartLabel: String {
        return chartD.id
    }
    
    private var w: CGFloat = 0, h: CGFloat = 0
    
    var indicViewArray: [ChartIndicatorLayer]?
    
    var histQuote : HistoricQuote?
    var histQuoteArray = [StockQuote]()
    var chartIndicArray = [IndicatorDraw]()
    var orderArrowArray = [OrderArrow]()
    
    var priceMax: Double = -1.0, priceMin: Double = 9999999.0
    var ppriceMax: Double = 0.0, ppriceMin: Double = 0.0
    
    var dateMax: Date!, dateMin: Date!
    var dateTo: Date!, dateFrom: Date!
    var dateSimul: Date?
    
    var dayFrequency: Int = 1
    var roundDec: Int = 2
    var perLine: Double = 2

    var scaleColumnF: CGFloat = 0.0
    var firstPosition: CGFloat = 0.0
    var monthCount: Int = 1
    var dateArray = [Date]()
    var columnPoint = [CGFloat]()
    
    var indicNumber: Int = 0
    var chartH: CGFloat = 1, indicH: CGFloat = 0
    
    var stockId = "..."
    var atrValue: Double = 0
    
    var stockName: String {
        if let histQuote = histQuote {
            return histQuote.name
        } else {
            return "..."
        }
    }
    
    var lastQuote: StockQuote {
        if let stockQ = histQuoteArray.last {
            return stockQ
        } else {
            return StockQuote()
        }
    }
    
    var lastVar: Double {
        if numberOfRows() > 2 {
            let lastQuote = histQuoteArray[numberOfRows() - 1].close
            let beforeLastQuote = histQuoteArray[numberOfRows() - 2].close
            return (lastQuote - beforeLastQuote) / beforeLastQuote
        } else {
            return 0.0
        }
    }
    
    var chartQuote: ChartQuoteLayer!
    
    private var rect2d = NSMakeRect(5 ,5 , 20, 20)
    
    /// ************* DRAW LINE **********************
    private var ph0: CGFloat = 0, pw0: CGFloat = 0
    private var ph1: CGFloat = 0, pw1: CGFloat = 0
    
    private var drawingTools = DrawToolsModel.Line
    private let lineWeight: CGFloat = 2
    private let strokeColor: NSColor = .white
    private var currentLine: ChartLine?
    private var currentFib: FibPosition?
    private var currentTP: TPosition?
    private var currentPath: NSBezierPath?
    private var currentShape: CAShapeLayer?
   
    private var popupMenu: NSMenu!
    
    private let beginPeriodButton = NSPopUpButton(frame: .zero, pullsDown: false)
    private let nextDateButton = NSButton(frame: .zero)
    private let menuButton = NSButton(frame: .zero)
    
    var isSimu: Bool = false {
        didSet {
            if isSimu {
                beginPeriodButton.isHidden = true
                nextDateButton.isHidden = true
            } else {
                beginPeriodButton.isHidden = false
                nextDateButton.isHidden = false
            }
        }
    }
    
    // MARK: - Initializers
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        chartQuote = ChartQuoteLayer(csp: self)
        
        popupMenu = NSMenu(title: "Popup")
        popupMenu.delegate = self
        self.wantsLayer = true
        
        beginPeriodButton.addItems(withTitles: ChartDefaultValue.beginPeriod)
        beginPeriodButton.isBordered = true
        beginPeriodButton.isTransparent = false
        beginPeriodButton.target = self
        beginPeriodButton.action = #selector(changeBeginPeriod(_:))

        nextDateButton.title = "Next"
        nextDateButton.isBordered = true
        nextDateButton.target = self
        nextDateButton.action = #selector(nextDate(_:))
        
        menuButton.title = ""
        menuButton.target = self
        menuButton.image = NSImage(named: "NSTouchBarListViewTemplate")
        menuButton.setButtonType(.pushOnPushOff)
        menuButton.isBordered = true
        menuButton.action = #selector(showMenu(_:))
 
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -- Chart Parameters
    func initChartD(chartD: ChartDrawing) {
        self.chartD = chartD
      
        var i = 0
        indicViewArray = [ChartIndicatorLayer]()
        for indic in chartD.chartIndic.filter({ $0.type != "Chart" }) {
            let indicView = ChartIndicatorLayer(indicSet: indic, csp: self)
            indicViewArray!.append(indicView)
            i = i + 1
            if i > 2 {
                break
            }
        }
        
        indicNumber = i
        if i == 0 {
            chartH = 1
            indicH = 0
        } else if i == 1 {
            chartH = 0.75
            indicH = 0.25
        } else if i == 2 {
            chartH = 0.74
            indicH = 0.13
        } else if i == 3 {
            chartH =  0.64
            indicH = 0.12
        }
    }
   
    // MARK: -- Historic Quote
    func setStockHist(histQuote: HistoricQuote?, stockId: String) {
        self.histQuote = histQuote
        self.stockId = stockId
        clearOrderArrow()
    }
    
    func numberOfRows() -> Int {
        return histQuoteArray.count
    }
    
    func getStockQuote (at: Date) -> StockQuote? {
        if let sq = histQuoteArray.first(where: {$0.dateQuote == at}) {
            return sq
        } else {
            return nil
        }
    }
    
    func nextDate() -> Date? {
        if let hist = histQuote, let dateM = dateMax {
            if hist.maxDate == dateM {
                return nil
            }
            return hist.nextDate(contain: chartD.type, nDate: dateM)
        } else {
            return nil
        }
    }
    
    func quotePosition (_ quote: Double) -> CGFloat {
        return chartQuote.quotePosition(quote)
    }
    
    func positionQuote (_ position: CGFloat) -> Double {
        return chartQuote.positionQuote(position)
    }
    
    @objc func changeBeginPeriod(_ sender: NSPopUpButton) {
        guard let histQuote = histQuote else {
            return
        }
        
        if let period = sender.selectedItem?.title, let maxDate = histQuote.maxDate, let minDate = histQuote.minDate {
            let newDateSimul = CDate.subDate(maxDate, period)
            var ninDateSimul: Date
            if chartD.type == ChartType.Weekly.rawValue {
                ninDateSimul = CDate.addDate(minDate, "6 Months")
            } else {
                ninDateSimul = CDate.addDate(minDate, "3 Months")
            }
                       
            if newDateSimul >= ninDateSimul  {
                dateSimul = newDateSimul
            } else {
                dateSimul = ninDateSimul
            }
            refresh()
        }
    }
    
    @objc func nextDate(_ sender: NSButton) {
        let index = beginPeriodButton.indexOfSelectedItem
        if let hist = histQuote, let currentDateMax = dateMax {
            if hist.maxDate == currentDateMax {
                beginPeriodButton.selectItem(at: 0)
            } else {
               
                if index != 0 {
                    dateSimul = nextDate()
                    refresh()
                }
            }
        }
    }
    
    @objc func showMenu(_ sender: NSButton) {
        if let event = NSApplication.shared.currentEvent {
            NSMenu.popUpContextMenu(popupMenu, with: event, for: sender)
        }
    }
 
    func refresh() {
        guard let histQuote = histQuote else {
            return
        }
       
        dateMax = histQuote.maxDate
        
        if dateSimul != nil {
            dateTo = dateSimul
        } else {
            dateTo = CDate.subDate(dateMax, chartD.beginPeriod)
        }
       
        dateFrom = CDate.subDate(dateTo , chartD.period)
    
        if histQuote.type == "Currency" {
            roundDec = 5
            perLine = 0.5
        } else {
            roundDec = 2
            perLine = 2
        }
        
        histQuoteArray = histQuote.getHist(contain: chartD.type, from: dateFrom, to: dateTo)
        guard histQuoteArray.count > 10 else {
            return
        }
       
        chartIndicArray.removeAll()
        for indic in chartD.chartIndic.filter({ $0.type == IndicatorType.Chart.rawValue }) {
            chartIndicArray.append(contentsOf: Indicator.indicator(indic: indic, hist: histQuote.getHist(contain: chartD.type)))
        }
       
        dateMin = histQuoteArray.first?.dateQuote
        dateMax = histQuoteArray.last?.dateQuote
       
        priceMax = histQuoteArray.map { $0.close }.max()!
        priceMin = histQuoteArray.map { $0.close }.min()!
       
        ppriceMax = priceMax + ( priceMax * perLine / 100.0)
        ppriceMin = priceMin - ( priceMin * perLine / 100.0)

        let atrArray = ATR.atr(avg: 14, cQuote: histQuoteArray)
        atrValue = atrArray[dateMax] ?? 0.0
        
        if let indicViewArray = indicViewArray {
            for indicView in indicViewArray {
                indicView.refresh()
            }
        }

        needsDisplay = true
    }
  
    func getHist() -> [StockQuote]? {
        guard let histQuote = histQuote else {
            return nil
        }
        return histQuote.getHist(contain: chartD.type)
    }

    //MARK: -- Order Arrow
    func addOrderArrow(date: Date, action: String, type: String) {
        let oArrow = OrderArrow (date: date, action: action, type: type)
        orderArrowArray.append(oArrow)
    }
    
    func clearOrderArrow() {
        orderArrowArray.removeAll()
    }

    ///***.********************************************************
    private func removeLayer() {
        self.layer?.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        beginPeriodButton.removeFromSuperview()
        nextDateButton.removeFromSuperview()
        menuButton.removeFromSuperview()
    }
    //MARK: -- Draw Chart --
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        removeLayer()
        
        guard histQuote != nil else {
            messageLayer(text: "Historic Quote Not Found for : \(stockId)")
            return
        }
        
        guard histQuoteArray.count > 10 else {
            messageLayer(text: "Not Enough Historic Quote for : \(stockId) -- \(histQuoteArray.count)")
            return
        }
        
        w = bounds.width
        h = bounds.height * chartH
        
        let x: CGFloat = 0
        let y: CGFloat = CGFloat(indicNumber) * indicH * bounds.height
        
        
        self.pw0 = ChartDefaultValue.ww
        self.ph0 =  y + ChartDefaultValue.hh
        self.pw1 = w - ChartDefaultValue.ww - ChartDefaultValue.fontWidth * 3 + 25
        self.ph1 = bounds.height - 2 * ChartDefaultValue.fontHeight
        let gw = pw1 - pw0 - ChartDefaultValue.wMargin
        let gh = ph1 - ph0
        
        dateArray.removeAll()
        self.layer?.opacity = 1
        
        chartQuote.buildChart(rootLayer: self.layer!,
                             w: w, h: h,
                             x: x, y: y,
                             pw0: pw0, pw1: pw1,
                             ph0: ph0, ph1: ph1)
        
        rect2d = NSMakeRect(pw0 ,ph0, gw + ChartDefaultValue.wMargin, gh)
        updateTrackingAreas()
        
        beginPeriodButton.frame = NSMakeRect(pw0, ph0 - ( ChartDefaultValue.hh + 18 ) / 2 , 100 , 18)
        nextDateButton.frame = NSMakeRect(pw1 + 6 , ph0 - ( ChartDefaultValue.hh + 18 ) / 2 , 60 , 18)
        menuButton.frame = NSMakeRect(w - 33 , bounds.height - 29 , 30 , 26)
        
        addSubview(beginPeriodButton)
        addSubview(nextDateButton)
        addSubview(menuButton)
        
        let ih: CGFloat = bounds.height * indicH
        var iy: CGFloat = y - ih

        guard let indicViewArray = indicViewArray else {
            return
        }

        for indicView in indicViewArray {
            indicView.buildChart(rootLayer: self.layer!,
                                     w: w, h: ih,
                                     x: x, y: iy,
                                     pw0: pw0, pw1: pw1)
            iy = iy - ih
            if iy < 0 {
                iy = 0
            }
        }
    }
 
    
    func messageLayer(text: String) {
        let lineText = CATextLayer()
        lineText.foregroundColor = ChartDefaultValue.whiteColor.cgColor
        lineText.backgroundColor = ChartDefaultValue.blackColor.cgColor
        lineText.alignmentMode = CATextLayerAlignmentMode.center
        lineText.contentsScale = NSScreen.main!.backingScaleFactor
        lineText.font = ChartDefaultValue.headerFont
        lineText.fontSize = ChartDefaultValue.fontSize * 1.2
        let width:CGFloat = 400, height:CGFloat = 25
    
        lineText.frame = NSMakeRect(bounds.width / 2 - 200, bounds.height / 2 - 20, width, height)
        lineText.string = text
        self.layer!.addSublayer(lineText)
    }
 
    //MARK:  ---------- Mouse event ------------
    var trackingArea : NSTrackingArea?
 
    override func updateTrackingAreas() {
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }
        let options : NSTrackingArea.Options = [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow]
        let rect = convert(rect2d, to: self.window?.contentView)
        trackingArea = NSTrackingArea(rect: rect, options: options,  owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }
    
    deinit {
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        currentPath = NSBezierPath()
        currentShape = CAShapeLayer()
        
        switch drawingTools {
        case .Line:
            currentLine = ChartLine()
            currentLine?.fromPoint = convert(event.locationInWindow, from: self.window?.contentView)
            currentShape?.strokeColor = strokeColor.cgColor
            
        case .Fibonacci:
            currentFib = FibPosition(roundDec: roundDec)
            let point = convert(event.locationInWindow, from: self.window?.contentView)
            currentFib?.setPoint0(point, NSPoint(x: pw1, y: point.y), quote: positionQuote(point.y))
            for fibline in currentFib!.fibPoint {
                currentShape?.addSublayer(fibline.textLayer!)
            }
            currentShape?.strokeColor =  currentFib?.fibColorDraw.cgColor
            
        case .TPosition:
            currentTP = TPosition(roundDec: roundDec)
            let point = convert(event.locationInWindow, from: self.window?.contentView)
            currentTP?.setPoint0(point, quote: positionQuote(point.y))
            for tpline in currentTP!.tpPoint {
                currentShape?.addSublayer(tpline.textLayer!)
            }
            currentShape?.strokeColor =  currentTP?.tpColorDraw.cgColor
        }
        
        currentShape?.lineWidth = lineWeight
        currentShape?.path = currentPath?.cgPath
        
        self.layer?.addSublayer(currentShape!)
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        if let line = currentLine, let linePath = currentPath {
            linePath.removeAllPoints()
            line.toPoint = convert(event.locationInWindow, from: self.window?.contentView)
            linePath.move(to: currentLine!.fromPoint)
            linePath.line(to: currentLine!.toPoint)
        }
        
        if let fib = currentFib, let fibPath = currentPath {
            var fibQuote: Double = 0.0
            var fibY: CGFloat = 0
            fibPath.removeAllPoints()
            let point = convert(event.locationInWindow, from: self.window?.contentView)
            
            fib.setPoint100(point,
                            NSPoint(x: pw1, y: point.y),
                            quote: positionQuote(point.y))
            
            fibQuote = fib.varPoint(per: 0.38)
            fibY = ph0 + quotePosition (fibQuote)
            fib.setPoint38(NSPoint(x: point.x, y: fibY),
                           NSPoint(x: pw1, y: fibY),
                           quote: fibQuote)
            
            fibQuote = fib.varPoint(per: 0.50)
            fibY = ph0 + quotePosition (fibQuote)
            fib.setPoint50(NSPoint(x: point.x, y: fibY),
                           NSPoint(x: pw1, y: fibY),
                           quote: fibQuote)
            
            fibQuote = fib.varPoint(per: 0.62)
            fibY = ph0 + quotePosition (fibQuote)
            fib.setPoint62(NSPoint(x: point.x, y: fibY),
                           NSPoint(x: pw1, y: fibY),
                           quote: fibQuote)
            
            for fibline in fib.fibPoint {
                fibPath.move(to: fibline.fromPoint)
                fibPath.line(to: fibline.toPoint)
            }
        }
        
        if let tp = currentTP, let tpPath = currentPath {
            tpPath.removeAllPoints()
             let point = convert(event.locationInWindow, from: self.window?.contentView)
            tp.setPoint100(point, quote: positionQuote(point.y))
            
            for tpline in tp.tpPoint {
                tpPath.move(to: tpline.fromPoint)
                tpPath.line(to: tpline.toPoint)
            }
            
            tpPath.move(to: tp.tpPoint[0].toPoint)
            tpPath.line(to: tp.tpPoint[1].fromPoint)
        }
        
        if let shape = currentShape {
            shape.path = currentPath?.cgPath
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if let shape = currentShape {
            shape.path = currentPath?.cgPath
        }
        currentTP = nil
        currentFib = nil
        currentLine = nil
        currentPath = nil
        currentShape = nil
    }
    
    override func rightMouseDown(with event: NSEvent) {
        NSMenu.popUpContextMenu(popupMenu, with: event, for: self)
    }
    
    override func mouseEntered(with event: NSEvent) {
    }
    
    override func mouseExited(with event: NSEvent) {
    }
    
    override func mouseMoved(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: self.window?.contentView)
        quoteAtPrice(cpos: point.x)
    }
    
    func quoteAtPrice(cpos: CGFloat) {
        if dateArray.count == 0 {
            return
        }
        var i = 0
        
        for (index, value) in columnPoint.enumerated() {
            if cpos < value {
                i = index
                break
            }
        }
        
        if  (i - 1) >= dateArray.count {
            i = dateArray.count
        }
        
        if (i - 1) < 0 {
            i = dateArray.count
        }
        
        self.toolTip = chartQuote.updateQuoteLabel(date: dateArray[i-1])
    }
 
}

extension ChartControllerView: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        switch menu.title {
        case "Popup":
            
            if menu.items.count < 1 {
                let periodMenu = NSMenu(title: "Period")
                periodMenu.delegate = self
                let periodMenuItem = NSMenuItem(title: "Period", action: nil, keyEquivalent: "")
                menu.addItem(periodMenuItem)
                menu.setSubmenu(periodMenu, for: periodMenuItem)
                
                menu.addItem(NSMenuItem.separator())
                let modelMenu = NSMenu(title: "Chart Model")
                modelMenu.delegate = self
                let modelMenuItem = NSMenuItem(title: "Chart Model", action: nil, keyEquivalent: "")
                menu.addItem(modelMenuItem)
                menu.setSubmenu(modelMenu, for: modelMenuItem)
                
                menu.addItem(NSMenuItem.separator())
                let toolsMenu = NSMenu(title: "Drawing Tools")
                toolsMenu.delegate = self
                let toolsMenuItem = NSMenuItem(title: "Drawing Tools", action: nil, keyEquivalent: "")
                menu.addItem(toolsMenuItem)
                menu.setSubmenu(toolsMenu, for: toolsMenuItem)
                
                menu.addItem(NSMenuItem.separator())
                let stopMenu = NSMenu(title: "Trailing Stop")
                stopMenu.delegate = self
                let stopMenuItem = NSMenuItem(title: "Trailing Stop", action: nil, keyEquivalent: "")
                menu.addItem(stopMenuItem)
                menu.setSubmenu(stopMenu, for: stopMenuItem)
                
                let removeStopMenuItem = NSMenuItem(title: "Remove Stop", action: #selector(removeStop(_:)), keyEquivalent: "")
                menu.addItem(removeStopMenuItem)
                
                menu.addItem(NSMenuItem.separator())
                let removeChartIndicItem = NSMenuItem(title: "Remove Average", action: #selector(removeChartIndic(_:)), keyEquivalent: "")
                menu.addItem(removeChartIndicItem)
                
                menu.addItem(NSMenuItem.separator())
                let chartItem = NSMenuItem(title: "Change Chart", action: #selector(changeChart(_:)), keyEquivalent: "")
                menu.addItem(chartItem)
    
                let saveChartItem = NSMenuItem(title: "Save Chart Screeen", action: #selector(saveChart(_:)), keyEquivalent: "")
                menu.addItem(saveChartItem)
                
                menu.addItem(NSMenuItem.separator())
                let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshQuote(_:)), keyEquivalent: "")
                menu.addItem(refreshItem)
                
              
            }
            
        case "Period":
            
            if menu.items.count == 0 {
                for menuItem in ChartDefaultValue.menuPeriod {
                    menu.addItem(withTitle: menuItem, action: #selector(changeChartPeriod(_:)), keyEquivalent: "")
                }
            }
            
        case "Chart Model":
            
            if menu.items.count == 0 {
                for menuItem in ChartModel.allValues {
                    menu.addItem(withTitle: menuItem, action: #selector(changeChartModel(_:)), keyEquivalent: "")
                }
            }
            
        case "Drawing Tools":
            
            if menu.items.count == 0 {
                for menuItem in DrawToolsModel.allValues {
                    menu.addItem(withTitle: menuItem, action: #selector(changeDrawingTools(_:)), keyEquivalent: "")
                }
            }
            
        case "Trailing Stop":
            
            if menu.items.count == 0 {
                for menuItem in ChartDefaultValue.stopList {
                    menu.addItem(withTitle: menuItem, action: #selector(trailingStop(_:)), keyEquivalent: "")
                }
            }
            
        default: break
        }
    }
    
    @objc func changeChartPeriod(_ sender: AnyObject) {
        chartD.period = sender.title
        refresh ()
        
    }
    
    @objc func changeChartModel(_ sender: AnyObject) {
        chartD.model = sender.title
        needsDisplay = true
    }
    
    @objc func changeDrawingTools(_ sender: AnyObject) {
        if sender.title == DrawToolsModel.Fibonacci.rawValue {
            drawingTools = DrawToolsModel.Fibonacci
        } else if sender.title == DrawToolsModel.TPosition.rawValue {
            drawingTools = DrawToolsModel.TPosition
        } else {
            drawingTools = DrawToolsModel.Line
        }
    }
    
    @objc func trailingStop(_ sender: AnyObject) {
        if let stopIndic = ChartDefaultValue.stopDict[sender.title] {
            
            for stop in indicator (id: stopIndic) {
                chartIndicArray.append(stop)
            }
            needsDisplay = true
        }
    }
    
    @objc func removeStop(_ sender: AnyObject) {
        for indic in chartIndicArray where indic.stop {
            if let index = chartIndicArray.firstIndex(where: { $0 === indic }) {
                chartIndicArray.remove(at: index)
            }
        }
        needsDisplay = true
    }
    
    @objc func removeChartIndic(_ sender: AnyObject) {
        chartIndicArray.removeAll()
        needsDisplay = true
    }
    
    @objc func refreshQuote(_ sender: AnyObject) {
        let testHist = HistoricQuoteDB.instance.getHistoricQuote(id: stockId)
        histQuote = testHist
        refresh()
    }
    
    
    @objc func changeChart(_ sender: AnyObject) {
        let storyboardMain = NSStoryboard(name: "Market", bundle: nil)
       
        let chartsSearchWindowsController = storyboardMain.instantiateController(withIdentifier: "chartSearchWindowsController") as! NSWindowController
        
        if let chartSearchWindows = chartsSearchWindowsController.window {
            let chartSearchViewController = chartSearchWindows.contentViewController as! ChartSearchViewController
           
            let application = NSApplication.shared
            application.runModal(for: chartSearchWindows)
            
            if let chartD = chartSearchViewController.chartD {
                initChartD(chartD: chartD)
                refresh()
                if let tabView = self.superview as? ChartTabView {
                    if let selected = tabView.selectedTabViewItem {
                        selected.label = chartD.id
                    }
                }
            }
            chartSearchWindows.close()
        }
    }
    
    @objc func saveChart(_ sender: AnyObject) {
        //https://stackoverflow.com/questions/41386423/get-image-from-calayer-or-nsview-swift-3
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        let image = NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)

        let fileName = DirectoryFiles.chartFileName(id: stockId, chartType: chartD.type, quoteDate: dateMax)
        DirectoryFiles.imageSave(image: image, fileName: fileName)
    }
    
    func indicator(id: String) -> [IndicatorDraw] {
        var indicDrawArray = [IndicatorDraw]()
        if let hist = getHist() {
            do {
                let indicator = try ChartSettingDB.instance.getIndicator(id: id)
                indicDrawArray = Indicator.indicator(indic: indicator, hist: hist)
            } catch let error as SQLiteError {
                print(" Indicator : \(error.description)")
            } catch let error {
                print(" Indicator : Other Error \(error)")
            }
        }
        return indicDrawArray
    }
}
