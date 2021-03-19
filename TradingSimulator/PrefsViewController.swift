//
//  PerfsViewController.swift
//  Trading
//
//  Created by Maroun Achille on 23/07/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {

    @IBOutlet weak var startBalance: NSTextField!
    @IBOutlet weak var turnBack: NSPopUpButton!
    @IBOutlet weak var indexId: NSPopUpButton!
    @IBOutlet weak var showArrow: NSPopUpButton!
    
    
    let tdb = TtablesDB.instance
    let question = "Preference Window"
    var tableItem1: Ttables?, tableItem2: Ttables?, tableItem3: Ttables?, tableItem4: Ttables?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuPeriod = ["3 Years", "4 Years", "5 Years" , "7 Years" ]
        turnBack.removeAllItems()
        turnBack.addItems(withTitles: menuPeriod)
        turnBack.selectItem(at: menuPeriod.count-1)
        
        let menuArrow = ["Yes", "No"]
        showArrow.removeAllItems()
        showArrow.addItems(withTitles: menuArrow)
        showArrow.selectItem(at: 0)
        
        startBalance.doubleValue = 30000.0
        
        indexId.removeAllItems()
        do {
            let indexAll = try StockDB.instance.getIndexList()
                
            var indexArray = [String]()
            for index in indexAll {
                indexArray.append(index.id)
            }
            indexId.addItems(withTitles: indexArray)
            indexId.selectItem(at: indexArray.count-1)
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    override func viewWillAppear() {
        do {
            tableItem1 = try tdb.getTableItem(name: "SIMU", id: "BALANCE")
            if let item = tableItem1 {
                startBalance.doubleValue = item.value3
            }
            
            tableItem2 = try tdb.getTableItem(name: "SIMU", id: "TURBCK")
            if let item = tableItem2 {
                turnBack.selectItem(withTitle: item.value1)
            }
            
            tableItem3 = try tdb.getTableItem(name: "SIMU", id: "INDEX")
            if let item = tableItem3 {
                indexId.selectItem(withTitle: item.value1)
            }
            
            tableItem4 = try tdb.getTableItem(name: "SIMU", id: "SHOARW")
            if let item = tableItem4 {
                showArrow.selectItem(withTitle: item.value1)
            }
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    @IBAction func buttomOk(_ sender: NSButton) {
        do {
            if startBalance.doubleValue < 10000.0 {
                dspAlert(text: "Start Balance must be greater then 100000")
                return
            }
            
            if let item = tableItem1 {
                item.value3 = startBalance.doubleValue
                try tdb.tablesUpdate(tables: item)
            }
            
            if let item = tableItem2 {
                item.value1 = turnBack.titleOfSelectedItem
                try tdb.tablesUpdate(tables: item)
            }
            
            if let item = tableItem3 {
                item.value1 = indexId.titleOfSelectedItem
                try tdb.tablesUpdate(tables: item)
            }
            
            if let item = tableItem4 {
                item.value1 = showArrow.titleOfSelectedItem
                try tdb.tablesUpdate(tables: item)
            }
            
            let application = NSApplication.shared
            application.stopModal()
            //self.dismiss(self)
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
}
