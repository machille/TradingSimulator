//
//  StocksDetailViewController.swift
//  Trading
//
//  Created by Maroun Achille on 14/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class StocksDetailViewController: NSViewController {

    @IBOutlet weak var stockId: NSTextField!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var type: NSPopUpButton!
    @IBOutlet weak var currency: NSPopUpButton!
    @IBOutlet weak var status: NSPopUpButton!
    @IBOutlet weak var industry: NSTextField!
    @IBOutlet weak var marketplace: NSPopUpButton!
    @IBOutlet weak var createDate: NSDatePicker!
    @IBOutlet weak var closingDate: NSDatePicker!
    
    @IBOutlet weak var dailyReference: NSPopUpButton!
    @IBOutlet weak var dailyCode: NSTextField!
    @IBOutlet weak var histReference: NSPopUpButton!
    @IBOutlet weak var histCode: NSTextField!
    
    @IBOutlet weak var actionButton: NSButton!
    
    var sdb: StockDB = StockDB.instance
    
    var typeTable, currencyTable, statusTable, marketplaceTable, dailyReferenceTable, histReferenceTable: TableComboDB!
    
    let question = "Setup Stock"
    var action: String = "Add"
    
    var stock: Stock? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        do {
            try typeTable = TableComboDB.init(tableName: "STKTYP")
            try currencyTable = TableComboDB.init(tableName: "CURCY")
            try statusTable = TableComboDB.init(tableName: "STATUS")
            try marketplaceTable = TableComboDB.init(tableName: "MRKPLC")
            try dailyReferenceTable = TableComboDB.init(tableName: "QOTREF")
            try histReferenceTable = TableComboDB.init(tableName: "QOTHST")
         
            type.removeAllItems()
            if let dataTable = typeTable.tableArray {
                for (index, data) in dataTable.enumerated()  {
                    type.insertItem(withTitle: data.desc, at: index)
                }
            }
            
            currency.removeAllItems()
            if let dataTable = currencyTable.tableArray {
                for (index, data) in dataTable.enumerated()  {
                    currency.insertItem(withTitle: data.desc, at: index)
                }
            }

            status.removeAllItems()
            if let dataTable = statusTable.tableArray {
                for (index, data) in dataTable.enumerated()  {
                    status.insertItem(withTitle: data.desc, at: index)
                }
            }
            
            marketplace.removeAllItems()
            if let dataTable = marketplaceTable.tableArray {
                for (index, data) in dataTable.enumerated()  {
                    marketplace.insertItem(withTitle: data.desc, at: index)
                }
            }
            
            dailyReference.removeAllItems()
            if let dataTable = dailyReferenceTable.tableArray {
                for (index, data) in dataTable.enumerated()  {
                    dailyReference.insertItem(withTitle: data.desc, at: index)
                }
            }
            
            histReference.removeAllItems()
            if let dataTable = histReferenceTable.tableArray {
                for (index, data) in dataTable.enumerated() {
                    histReference.insertItem(withTitle: data.desc, at: index)
                }
            }
     
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }
    
    func updateUI() {
        if !isViewLoaded {
            return
        }
        actionButton.title = action
        
        guard let stock = stock else {
            return
        }
        if action == "Add" {
            stockId.isEditable = true

            type.selectItem(at: typeTable.comboBox(keyIndexForItem: (stock.type)))
            currency.selectItem(at: currencyTable.comboBox(keyIndexForItem: (stock.currency)))
               
            status.selectItem(at: statusTable.comboBox(keyIndexForItem: (stock.status)))

            marketplace.selectItem(at: marketplaceTable.comboBox(keyIndexForItem: (stock.marketPlace)))
            createDate.dateValue = stock.creationDate
            setClosingDate()
            
        } else {
            stockId.isEditable = false
            
            stockId.stringValue = stock.id
            name.stringValue = stock.name
            type.selectItem(at: typeTable.comboBox(keyIndexForItem: (stock.type)))
            currency.selectItem(at: currencyTable.comboBox(keyIndexForItem: (stock.currency)))
            status.selectItem(at: statusTable.comboBox(keyIndexForItem: (stock.status)))
            industry.stringValue = stock.industry
            marketplace.selectItem(at: marketplaceTable.comboBox(keyIndexForItem: (stock.marketPlace)))
            createDate.dateValue = stock.creationDate
            
            if let closingDateValue = stock.closingDate {
                closingDate.dateValue = closingDateValue
            } else {
                setClosingDate()
            }
                
            dailyReference.selectItem(at: dailyReferenceTable.comboBox(keyIndexForItem: (stock.dailyReference)))
            dailyCode.stringValue = stock.dailyCode
                
            histReference.selectItem(at: histReferenceTable.comboBox(keyIndexForItem: (stock.historicReference)))
            histCode.stringValue = stock.historicCode
        }
    }
    
    @IBAction func changeStatus(_ sender: NSPopUpButton) {
         if let value = statusTable.comboBox(keyValueForItemAt: sender.indexOfSelectedItem) {
            if value == "Active" {
                setClosingDate()
            } else {
                closingDate.dateValue = Date()
            }
        }
    }
    
    private func setClosingDate() {
        var components = DateComponents()
        components.year = 9999
        components.month = 12
        components.day = 31
        closingDate.dateValue = Calendar.current.date(from: components)!
    }
    
    func validate() ->Bool {
        guard !stockId.stringValue.isEmpty  else {
            dspAlert(text: "Stock Id Is required")
            return false
        }
        stock?.id = stockId.stringValue
        
        guard !name.stringValue.isEmpty  else {
            dspAlert(text: "Stock Name Is required")
            return false
        }
        stock?.name = name.stringValue
        
        if let value = typeTable.comboBox(keyValueForItemAt: type.indexOfSelectedItem) {
            stock?.type = value
        } else {
            dspAlert(text: "Stock Type Value : \(type.stringValue) in Invalid")
            return false
        }
        
        if let value = currencyTable.comboBox(keyValueForItemAt: currency.indexOfSelectedItem) {
            stock?.currency = value
        } else {
            dspAlert(text: "Stock Currency Value \(currency.stringValue) in Invalid")
            return false
        }
        
        if let value = statusTable.comboBox(keyValueForItemAt: status.indexOfSelectedItem) {
            stock?.status = value
        } else {
            dspAlert(text: "Stock Status \(status.stringValue) in Invalid")
            return false
        }
        
        guard !industry.stringValue.isEmpty  else {
            dspAlert(text: "Stock Industry Is required")
            return false;
        }
         stock?.industry = industry.stringValue
        
        if let value = marketplaceTable.comboBox(keyValueForItemAt: marketplace.indexOfSelectedItem) {
            stock?.marketPlace = value
        } else {
            dspAlert(text: "Stock Market Place  \(marketplace.stringValue) in Invalid")
            return false;
        }
 
        stock?.creationDate = createDate.dateValue
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: closingDate.dateValue)
        if components.year == 9999 {
            stock?.closingDate = nil
        } else {
            stock?.closingDate = closingDate.dateValue
        }
        
        if let value = dailyReferenceTable.comboBox(keyValueForItemAt: dailyReference.indexOfSelectedItem) {
            stock?.dailyReference = value
        } else {
            dspAlert(text: "Stock Daily Reference \(dailyReference.stringValue) in Invalid")
            return false;
        }
        
        guard !dailyCode.stringValue.isEmpty  else {
            dspAlert(text: "Stock Daily Code Place Is required")
            return false;
        }
        stock?.dailyCode = dailyCode.stringValue
        
        if let value = histReferenceTable.comboBox(keyValueForItemAt: histReference.indexOfSelectedItem) {
            stock?.historicReference = value
        } else {
            dspAlert(text: "Stock Historic Reference \(histReference.stringValue) in Invalid")
            return false;
        }

        guard !histCode.stringValue.isEmpty  else {
            dspAlert(text: "Stock Historic Code Place Is required")
            return false;
        }
        stock?.historicCode = histCode.stringValue
        
        do {
            if action == "Add" {
                try sdb.stockInsert(stock: stock!)
            } else {
                try sdb.stockUpdate(stock: stock!)
            }
            return true
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        
        return false
    }
    
    @IBAction func save(_ sender: Any) {
        if validate() {
            let firstViewController = presentingViewController as! StocksTableViewController
            firstViewController.passDataBack(action: action, stock: stock!)
            self.dismiss(self)
        }
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
    
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
}
