//
//  SimuWindow.swift
//  Trading
//
//  Created by Maroun Achille on 03/07/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class SimuWindow : NSObject {
    private let header = "Simulator Window"
    private let defaults = UserDefaults.standard
    private var window: NSWindow?
    private var windowController = NSWindowController()
    private var simuViewController: SimuViewController?
    var showArrow = "Yes"
    private var isSet = false
    
    override init() {
        super.init()
        
        var frame: NSRect
        if let s = UserDefaults.standard.string(forKey: "SimuWindow") {
            frame = NSRectFromString(s)
        } else {
            frame = NSRect(x: 200, y: 200, width: 1300, height: 900)
        }
        
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        window = NSWindow(contentRect: frame, styleMask: styleMask, backing: .buffered, defer: false)
        window?.delegate = self
        windowController.contentViewController = window?.contentViewController
        windowController.window = window
    }
    
    func setSimuPos(simuPos: SimuPosition) {
        let storyboard = NSStoryboard(name: "Simulator", bundle: nil)
        guard let simuViewController = storyboard.instantiateController(withIdentifier: "simuViewController") as? SimuViewController
            else {
                Message.messageAlert(header, text: "Cannot load simuViewController")
                return
            }
          
        self.simuViewController = simuViewController
        self.simuViewController?.showArrow = showArrow
        
        window?.contentView?.addSubview(simuViewController.view)
        simuViewController.view.translatesAutoresizingMaskIntoConstraints = false
             
        NSLayoutConstraint(item: simuViewController.view, attribute: .top, relatedBy: .equal, toItem:  window?.contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: simuViewController.view, attribute: .left, relatedBy: .equal, toItem:  window?.contentView, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: simuViewController.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 282).isActive = true
        NSLayoutConstraint(item: simuViewController.view, attribute: .bottom, relatedBy: .equal, toItem:  window?.contentView, attribute: .bottom, multiplier: 1, constant: 0 ).isActive = true
        
        if simuPos.indexId != "NA" {
            let chartTV = simuViewController.chartTV
            chartTV.setFlagSimul()
            
            let chartTVIndex = ChartTabView()
            simuViewController.chartTVIndex = chartTVIndex
            chartTVIndex.setFlagSimul()
            
            let tabView = NSTabView()
            tabView.tabViewType = .topTabsBezelBorder
            
            let tabItem1: NSTabViewItem = NSTabViewItem(identifier: "item1")
            tabItem1.label = simuPos.stockId
            tabItem1.toolTip = simuPos.stockName
            tabItem1.view = chartTV
            tabView.addTabViewItem(tabItem1)
            
            let tabItem2: NSTabViewItem = NSTabViewItem(identifier: "item2")
            tabItem2.label = simuPos.indexId
            tabItem2.view = chartTVIndex
            tabView.addTabViewItem(tabItem2)
            
            window?.contentView?.addSubview(tabView)
            tabView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: tabView, attribute: .top, relatedBy: .equal, toItem:  window?.contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: tabView, attribute: .left, relatedBy: .equal, toItem:  simuViewController.view, attribute: .right, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: tabView, attribute: .right, relatedBy: .equal, toItem:  window?.contentView, attribute: .right, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: tabView, attribute: .bottom, relatedBy: .equal, toItem:  window?.contentView, attribute: .bottom, multiplier: 1, constant: 0 ).isActive = true
        
        } else {
            let chartTV = simuViewController.chartTV
            chartTV.setFlagSimul()
            window?.contentView?.addSubview(chartTV)
            chartTV.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: chartTV, attribute: .top, relatedBy: .equal, toItem:  window?.contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: chartTV, attribute: .left, relatedBy: .equal, toItem:  simuViewController.view, attribute: .right, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: chartTV, attribute: .right, relatedBy: .equal, toItem:  window?.contentView, attribute: .right, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: chartTV, attribute: .bottom, relatedBy: .equal, toItem:  window?.contentView, attribute: .bottom, multiplier: 1, constant: 0 ).isActive = true

        }
    
        isSet = simuViewController.setSimuPos(simuPos: simuPos)
    }
    
    func show() {
        if isSet {
            windowController.showWindow(self)
        }
    }
}

extension SimuWindow : NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let contentRect = window?.frame {
            UserDefaults.standard.set(NSStringFromRect(contentRect), forKey: "SimuWindow")
        }
    }
}
