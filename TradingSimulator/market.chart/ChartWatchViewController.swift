//
//  ChartWatchViewController.swift
//  Trading
//
//  Created by Maroun Achille on 23/09/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartWatchViewController: NSViewController {
    
    var actRow = 0
    var maxRow = 0
    private let header = "All ChartFactory Init Chart View"
    private let saveRect = "ChartMarketWatch"
    private let tabView = ChartTabView()
    
    var stockArray: [StockDayQuote]? {
        didSet {
            maxRow = stockArray?.count ?? 0
            chartFirstOne(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame: NSRect
        if let s = UserDefaults.standard.string(forKey: saveRect) {
            frame = NSRectFromString(s)
        } else {
            frame = NSRect(x: 100, y: 100, width: 1200, height: 900)
        }
        view.frame = frame
        
        
        view.addSubview(tabView)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tabView]|", options: [], metrics: nil, views: ["tabView": tabView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tabView]|", options: [], metrics: nil, views: ["tabView": tabView]))
    }
    
    override func viewWillDisappear() {
        if let contentRect = view.window?.frame {
            UserDefaults.standard.set(NSStringFromRect(contentRect), forKey: saveRect)
        }
    }
    
    func setCounter() {
        let counterLabel = self.view.window?.toolbar?.items.filter { $0.itemIdentifier.rawValue == "counterItem" }.first
        guard let label = counterLabel?.view as? NSTextField else { return }
        label.stringValue = " \(actRow)/\(maxRow) "
    }
    
    func setTextLabel(text: String) {
        let textLabel = self.view.window?.toolbar?.items.filter { $0.itemIdentifier.rawValue == "textItem" }.first
        guard let label = textLabel?.view as? NSTextField else { return }
        label.stringValue = text
    }
    
    @IBAction func chartFirstOne(_ sender: Any) {
        actRow = 1
        setDataRow()
    }
    
    @IBAction func chartNextOne(_ sender: Any) {
        if actRow + 1 <= maxRow  {
            actRow = actRow + 1
            setDataRow()
        }
    }
  
    
    @IBAction func chartPreviousOne(_ sender: Any) {
        if (actRow - 1 >= 1 ) {
            actRow = actRow - 1
            setDataRow()
        }
    }
    
    @IBAction func chartLastOne(_ sender: Any) {
        actRow = maxRow
        setDataRow()
    }
    
    private func setDataRow() {
        guard maxRow != 0 else {
            return
        }
        let item = stockArray![actRow-1]
        setCounter()
        let histQuote = HistoricQuoteDB.instance.getHistoricQuote(id: item.id)
        tabView.setStockHist(histQuote: histQuote, stockId: item.id)
    }
}
