//
//  AppDelegate.swift
//  Trading
//
//  Created by Maroun Achille on 08/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var mainmenu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if #available(OSX 10.12.1, *) {
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
// MARK: -- Menu
    
    func openWindow(storyBord: String, idf: String) {
        let storyboard = NSStoryboard(name: storyBord, bundle: nil)
        let windowsController: NSWindowController? = storyboard.instantiateController(withIdentifier: idf) as? NSWindowController
            
        if let controller = windowsController {
            if let title = controller.window?.title {
                if let openWin = checkWindow(title: title) {
                    openWin.makeKeyAndOrderFront(self)
                    return
                }
            }
            controller.showWindow(self)
        }
    }
        
    func checkWindow(title: String) -> NSWindow? {
        for win in NSApp.windows {
            if win.title == title {
                return win
            }
        }
        return nil
    }
    
    
    @IBAction func openStockTables(sender: NSMenuItem) {
        openWindow(storyBord: "Files", idf: "stockTableWindowsController")
    }
      
    @IBAction func openTablesTables(sender: NSMenuItem) {
        openWindow(storyBord: "Files", idf: "tablesTableWindowsController")
    }
    
    @IBAction func openIndexTables(sender: NSMenuItem) {
        openWindow(storyBord: "Files", idf: "indexTableWindowsController")
    }
    
    @IBAction func openImportStocks(sender: NSMenuItem) {
        openWindow(storyBord: "Files", idf: "stocksImportWindowsController")
    }
      
    @IBAction func openHistoricQuote(_ sender: Any) {
        openWindow(storyBord: "Files", idf: "historicQuoteWindowsController")
    }

    
    @IBAction func openSimulator(_ sender: Any) {
        openWindow(storyBord: "Main", idf: "simulator2WindowsController")
    }
    
    @IBAction func openChartSetting(sender: NSMenuItem) {
        openWindow(storyBord: "Market", idf: "chartTableWindowsController")
     }
     
     @IBAction func openIndicatorSetting(sender: NSMenuItem) {
        openWindow(storyBord: "Market", idf: "indicatorTableWindowsController")
     }

    @IBAction func openWatchListSetting(sender: NSMenuItem) {
        openWindow(storyBord: "Market", idf: "watchListWindowsController")
    }
    
    @IBAction func openMarketWatch(_ sender: Any) {
        openWindow(storyBord: "Main", idf: "marketWatchWindowsController")
    }
    
    @IBAction func showPerfs (_ sender: Any) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("prefsWindowController")) as! NSWindowController
        
        if let perfWindow = windowController.window {
            let application = NSApplication.shared
            application.runModal(for: perfWindow)
            perfWindow.close()
        }
    }
    
    @IBAction func startInternetStreamQuote(_ sender: Any) {
        let isq = InternetStreamQuote.instance
        isq.startRead()
        let irss = InternetRSS.instance
        irss.startReader()
    }
    
    @IBAction func stopInternetStreamQuote(_ sender: Any) {
        let isq = InternetStreamQuote.instance
        isq.stopRead()
        let irss = InternetRSS.instance
        irss.stopReader()
    }
 }


