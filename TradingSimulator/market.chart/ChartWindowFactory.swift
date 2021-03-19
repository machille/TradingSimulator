//
//  ChartFactory.swift
//  Trading
//
//  Created by Maroun Achille on 31/05/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartWindowFactory : NSObject {
    static let instance = ChartWindowFactory()
    private let header = "ChartFactory Init Chart View"
    private let saveRect = "chart"
    private let defaults = UserDefaults.standard
   
    private let tabView = ChartTabView()
    private var window: NSWindow?
    private var windowController = NSWindowController()
    
    private override init() {
        super.init()
        
        var frame: NSRect
        if let s = UserDefaults.standard.string(forKey: saveRect) {
            frame = NSRectFromString(s)
        } else {
            frame = NSRect(x: 200, y: 200, width: 1300, height: 900)
        }
        
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        window = NSWindow(contentRect: frame, styleMask: styleMask, backing: .buffered, defer: false)
        window?.delegate = self
        windowController.contentViewController = window?.contentViewController
        windowController.window = window

        window?.contentView?.addSubview(tabView)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        window?.contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tabView]|", options: [], metrics: nil, views: ["tabView": tabView]))
        window?.contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tabView]|", options: [], metrics: nil, views: ["tabView": tabView]))
    }
    
    func setStockId(id: String) {
        let histQuote = HistoricQuoteDB.instance.getHistoricQuote(id: id)
        tabView.setStockHist(histQuote: histQuote, stockId: id)
    }
    
    func addOrderArrow(date: Date, action: String, type: String) {
        tabView.addOrderArrow(date: date, action: action, type: type)
    }

    func setDateSimul(date: Date) {
        tabView.setDateSimul(dateSimu: date)
        
    }
    
    func show() {
        windowController.showWindow(self)
    }
    
    @objc func cancel(_ sender: Any?) {
        window?.close()
    }
}

extension ChartWindowFactory : NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let contentRect = window?.frame {
            UserDefaults.standard.set(NSStringFromRect(contentRect), forKey: saveRect)
        }
    }
}

