//
//  TablesDetailWindowsController.swift
//  Trading
//
//  Created by Maroun Achille on 20/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class TablesDetailViewController: NSViewController {

    @IBOutlet weak var id: NSTextField!
    @IBOutlet weak var desc: NSTextField!
    @IBOutlet weak var value1: NSTextField!
    @IBOutlet weak var value2: NSTextField!
    @IBOutlet weak var value3: NSTextField!
    @IBOutlet weak var flag1: NSButton!
    @IBOutlet weak var flag2: NSButton!
    
    @IBOutlet weak var tableName: NSTextField!
    @IBOutlet weak var actionButton: NSButton!
    
    var ttablesDB: TtablesDB = TtablesDB.instance
    var tableDesc: String!
    
    let question = "Setup Tables"
    var action: String = "Add"
    
    var tables: Ttables? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }
    
    func updateUI() {
        if !isViewLoaded {
            return
        }
        tableName.stringValue = tableDesc
        
        if action == "Add" {
            id.isEditable = true
        } else {
            id.isEditable = false
        }
        actionButton.title = action
        
        if let table = tables {
            id.stringValue = table.id
            desc.stringValue = table.desc
            value1.stringValue = table.value1
            value2.stringValue = table.value2
            value3.doubleValue = table.value3
            
            if let flagState = table.flag1 {
                if flagState == "1" {
                    flag1.state = NSControl.StateValue.on
                } else {
                    flag1.state = NSControl.StateValue.off
                }
            }
            if let flagState = table.flag2 {
                if flagState == "1" {
                    flag2.state = NSControl.StateValue.on
                } else {
                    flag2.state = NSControl.StateValue.off
                }
            }
        }
    }
    
    func validate() ->Bool {
        guard !id.stringValue.isEmpty  else {
            dspAlert(text: "Id Table Is required")
            return false
        }
        tables?.id = id.stringValue
        
        guard !desc.stringValue.isEmpty  else {
            dspAlert(text: "Description Is required")
            return false
        }
        tables?.desc = desc.stringValue
        
        tables?.value1 = value1.stringValue
        tables?.value2 = value2.stringValue
        tables?.value3 = value3.doubleValue
        
        if flag1.state == NSControl.StateValue.on {
            tables?.flag1 = "1"
        } else {
            tables?.flag1 = "0"
        }
        
        if flag2.state == NSControl.StateValue.on {
            tables?.flag2 = "1"
        } else {
            tables?.flag2 = "0"
        }
     
        do {
            if action == "Add" {
                try ttablesDB.tablesInsert(tables: tables!)
            } else {
                try ttablesDB.tablesUpdate(tables: tables!)
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
            let firstViewController = presentingViewController as! TablesTableViewController
            firstViewController.passDataBack(action: action, tables: tables!)
            self.dismiss(self)
        }
        
    }
    
    @IBAction func dismissWindow(_ sender: NSButton) {
        self.dismiss(self)
    }
    
}
