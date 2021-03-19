//
//  WatchListDeatilViewController.swift
//  Trading
//
//  Created by Maroun Achille on 17/05/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class WatchListDetailViewController: NSViewController {

    @IBOutlet weak var wlName: NSTextField!
    @IBOutlet weak var screener: NSButton!
    
    @IBOutlet weak var actionButton: NSButton!

    let question = "Setup Watch List"
    var action: String = "Add"
    
    var wldb = WatchListDB.instance
    var watchList: WatchList?  {
        didSet {
            updateUI()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }
    
    func updateUI() {

        if !isViewLoaded {
            return
        }
            
        if let watchList = watchList {
            wlName.stringValue = watchList.name
        
            if watchList.screener == "Y" {
                screener.state = NSControl.StateValue.on
            } else {
                screener.state = NSControl.StateValue.off
            }
        }
        
        actionButton.title = action
    }
    
    func validate() ->Bool {
        guard let watchList = watchList else {
            dspAlert(text: "Watch List Class is required")
            return false
        }

        guard !wlName.stringValue.isEmpty  else {
            dspAlert(text: "Watch List Id is required")
            return false
        }
        watchList.name = wlName.stringValue
           
        if screener.state == NSControl.StateValue.on  {
            watchList.screener = "Y"
        } else {
            watchList.screener = "N"
        }
        
        do {
            if action == "Add" {
                watchList.setId()
                try wldb.watchListInsert(watchList: watchList)
            } else {
                try wldb.watchListUpdate(watchList: watchList)
            }
            return true
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
               
        return false
    }
    
    func dspAlert(text: String) {
         Message.messageAlert(question, text: text)
     }

     @IBAction func Save(_ sender: Any) {
         if validate() {
             let firstViewController = presentingViewController as! WatchListViewController
             firstViewController.passDataBack(action: action, watchList: watchList!)
             self.dismiss(self)
         }
     }
     
     @IBAction func dismissWindow(_ sender: NSButton) {
         self.dismiss(self)
     }
    
}
