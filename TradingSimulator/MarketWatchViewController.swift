//
//  MarketWatchViewController.swift
//  Trading
//
//  Created by Maroun Achille on 20/11/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class MarketWatchViewController: NSViewController {

    private let saveRect = "MarketWatch"
    var width1: CGFloat = 0
    var width2: CGFloat = 0
    
    @IBOutlet weak var mainSplitview: NSSplitView!
    
    @IBOutlet weak var indexSplitView: NSSplitView!
    @IBOutlet weak var currSplitView: NSSplitView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        var frame: NSRect
        if let s = UserDefaults.standard.string(forKey: saveRect) {
            frame = NSRectFromString(s)
        } else {
            frame = NSRect(x: 100, y: 100, width: 1200, height: 800)
        }
        view.frame = frame
        title = "Market Watch"
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        width1 = view.frame.width * 0.25
        mainSplitview.setPosition(width1, ofDividerAt: 0)
        
        width2 = view.frame.width * 0.30
        mainSplitview.setPosition(view.frame.width - width2, ofDividerAt: 1)
    }
    
    override func viewDidDisappear() {
        super.viewWillDisappear()
        if let contentRect = view.window?.frame {
            UserDefaults.standard.set(NSStringFromRect(contentRect), forKey: saveRect)
        }
    }
    
    @IBAction func openChartWatch(_ sender: AnyObject) {
        MarketWatchActionDelegate.instance.watchAllChart(name: "STOCK")
    }
    
}

@available(OSX 10.12.1, *)
extension MarketWatchViewController: NSTouchBarDelegate {
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .quoteBar
        touchBar.defaultItemIdentifiers = [.startItem, .stopItem, .allChartItem, .flexibleSpace, .simuItem, .histQuoteItem, .flexibleSpace, .flexibleSpace]
    
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
        let appDelegate: AppDelegate? = NSApplication.shared.delegate as? AppDelegate

        switch identifier {            
        case NSTouchBarItem.Identifier.startItem:
            let startItem = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(image: NSImage(named: "start")! , target: appDelegate, action: #selector(appDelegate?.startInternetStreamQuote(_:)))
            startItem.view = button
            return startItem
            
        case NSTouchBarItem.Identifier.stopItem:
            let stopItem = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(image: NSImage(named: "stop")!, target: appDelegate, action: #selector(appDelegate?.stopInternetStreamQuote(_:)))
            stopItem.view = button
            return stopItem

        case NSTouchBarItem.Identifier.allChartItem:
            let allChartItem = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(image: NSImage(named: "chart")!, target: self, action: #selector(openChartWatch(_:)))
            allChartItem.view = button
            return allChartItem

        case NSTouchBarItem.Identifier.simuItem:
            let simuItem = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(image: NSImage(named: "simu")!, target: appDelegate, action: #selector(appDelegate?.openSimulator(_:)))
            simuItem.view = button
            return simuItem
            
        case NSTouchBarItem.Identifier.histQuoteItem:
            let histQuoteItem = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(image: NSImage(named: "download")!, target: appDelegate, action: #selector(appDelegate?.openHistoricQuote(_:)))
            histQuoteItem.view = button
            return histQuoteItem
            
        default:
          return nil
        }
    }

}
