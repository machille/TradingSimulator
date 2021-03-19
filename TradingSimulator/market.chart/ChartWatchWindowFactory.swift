//
//  CharWatchFactory.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartWatchWindowFactory : NSObject {
    
    static let instance = ChartWatchWindowFactory()
    fileprivate var wcChartWatch: NSWindowController?
    
    private override init() {
        super.init()
        
        let idf = "chart2WindowsController"
        let storyboard = NSStoryboard(name: "Market", bundle: nil)
        wcChartWatch = storyboard.instantiateController(withIdentifier: idf) as? NSWindowController

        wcChartWatch?.window?.delegate = self // func cancel that close on ESC
    }
    
    func show() {
        guard let controller = wcChartWatch else {
            return
        }
        controller.showWindow(self)
    }
    
    @objc func cancel(_ sender: Any?) {
        wcChartWatch?.window?.close()
    }
    
    
    func setStocksDayQuote(_ sdqArray: [StockDayQuote]) {
        guard let controller = wcChartWatch else {
            return
        }
        
        if let viewController = controller.contentViewController as? ChartWatchViewController  {
            viewController.stockArray = sdqArray
        }
    }
    
    func setTextLabel(text: String) {
        guard let controller = wcChartWatch else {
            return
        }
        
        if let viewController = controller.contentViewController as? ChartWatchViewController  {
            viewController.setTextLabel(text: text)
        }
    }
}

extension ChartWatchWindowFactory : NSWindowDelegate {
 
}
