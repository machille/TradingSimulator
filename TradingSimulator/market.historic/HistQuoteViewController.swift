//
//  HistQuoteViewController.swift
//  Trading
//
//  Created by Maroun Achille on 03/06/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class HistQuoteViewController: NSViewController {
    let question = "Historic Quote"
    
    var hqdb: StockQuoteDB = StockQuoteDB.instance
    var stockHistArray, saveStockHistArray: [StockHist]?
    var typeTable, histReferenceTable, marketplaceTable: TableComboDB!
    var sortOrder = ""
    var sortAscending = true
    var popupMenu: NSMenu!
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var searchStock: NSSearchField!
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case stockIdCell = "stockIdCell"
        case stockNameCell = "stockNameCell"
        case stockTypeCell = "stockTypeCell"
        case stockMarketPlaceCell = "stockMarketPlaceCell"
        case histReferenceCell = "histReferenceCell"
        case histCodeCell = "histCodeCell"
        case quoteDateCell = "quoteDateCell"
        case updatedCell = "updatedCell"
        
        static var allValues: [String] {
            var values = [String]()
            self.allCases.forEach {
                values.append($0.rawValue)
            }
            return values
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        
        searchStock.delegate = self
        createMenuForSearchField()
        
        popupMenu = NSMenu(title: "Item")
        popupMenu.addItem(NSMenuItem(title: "Refresh", action: #selector(readStocksTable), keyEquivalent: ""))
        tableView.menu = popupMenu
        
        for (index, element) in CellIdentifiers.allValues.enumerated() {
            let descriptor = NSSortDescriptor(key: element, ascending: true)
            tableView.tableColumns[index].sortDescriptorPrototype = descriptor
        }
        sortOrder = CellIdentifiers.stockIdCell.rawValue
        
        readStocksTable()
    }
    
    @objc fileprivate func readStocksTable () {
        do {
            try stockHistArray = hqdb.stockHistList()
            saveStockHistArray = stockHistArray
            try typeTable = TableComboDB.init(tableName: "STKTYP")
            try marketplaceTable = TableComboDB.init(tableName: "MRKPLC")
            try histReferenceTable = TableComboDB.init(tableName: "QOTHST")
            
            reloadStockList()
            textFieldChanged()
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    
    fileprivate func reloadStockList() {
        if sortOrder == CellIdentifiers.stockIdCell.rawValue {
            stockHistArray = stockHistArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.id < s2.id) : (s1.id > s2.id)
            })
        } else if sortOrder == CellIdentifiers.stockNameCell.rawValue {
            stockHistArray = stockHistArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.name < s2.name) : (s1.name > s2.name)
            })
        } else if sortOrder == CellIdentifiers.stockTypeCell.rawValue {
            stockHistArray = stockHistArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (typeTable.comboBox(keyValueForItemAt: s1.type)! < typeTable.comboBox(keyValueForItemAt: s2.type)!) : (typeTable.comboBox(keyValueForItemAt: s1.type)! > typeTable.comboBox(keyValueForItemAt: s2.type)!)
            })
        } else if sortOrder == CellIdentifiers.stockMarketPlaceCell.rawValue {
            stockHistArray = stockHistArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (marketplaceTable.comboBox(keyValueForItemAt: s1.marketPlace)! < marketplaceTable.comboBox(keyValueForItemAt: s2.marketPlace)!) : (marketplaceTable.comboBox(keyValueForItemAt: s1.marketPlace)! > marketplaceTable.comboBox(keyValueForItemAt: s2.marketPlace)!)
            })
        } else if sortOrder == CellIdentifiers.histReferenceCell.rawValue {
            stockHistArray = stockHistArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (histReferenceTable.comboBox(keyValueForItemAt: s1.historicReference)! < histReferenceTable.comboBox(keyValueForItemAt: s2.historicReference)!) : (histReferenceTable.comboBox(keyValueForItemAt: s1.historicReference)! > histReferenceTable.comboBox(keyValueForItemAt: s2.historicReference)!)
            })
        } else if sortOrder == CellIdentifiers.histCodeCell.rawValue {
            stockHistArray = stockHistArray?.sorted(by: { (s1 , s2) -> Bool in
            return sortAscending ? (s1.historicCode < s2.historicCode) : (s1.historicCode > s2.historicCode)
            })
        } else if sortOrder == CellIdentifiers.quoteDateCell.rawValue {
            stockHistArray = stockHistArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.quoteDate  < s2.quoteDate) : (s1.quoteDate > s2.quoteDate)
            })
        } else if sortOrder == CellIdentifiers.updatedCell.rawValue {
            stockHistArray = stockHistArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.upToDate  < s2.upToDate) : (s1.upToDate > s2.upToDate)
            })
        }
        tableView.reloadData()
    }
    
    @IBAction func updateQuoteDate(_ sender: NSButton) {
        do {

            try hqdb.truncateStockQuote()
            try hqdb.updateStockQuote()
            try hqdb.deleteOrphanQuote()
            
            try stockHistArray = hqdb.stockHistList()
            saveStockHistArray = stockHistArray
            try typeTable = TableComboDB.init(tableName: "STKTYP")
            try marketplaceTable = TableComboDB.init(tableName: "MRKPLC")
            try histReferenceTable = TableComboDB.init(tableName: "QOTHST")
            
            reloadStockList()
            textFieldChanged()
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
 
    fileprivate func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
}

extension HistQuoteViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return stockHistArray?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        
        if let order = sortDescriptor.key {
            sortOrder = order
            sortAscending = sortDescriptor.ascending
            reloadStockList()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier! == "reloadQuote" {
            if let secondViewController = segue.destinationController as? HistQuoteRunViewController {
                secondViewController.reload = true
                secondViewController.stockHistArray = stockHistArray
            }
        }
        
        if segue.identifier! == "updateQuote" {
             if let secondViewController = segue.destinationController as? HistQuoteRunViewController {
                secondViewController.reload = false
                secondViewController.stockHistArray = stockHistArray
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if stockHistArray?.count ?? 0 > 0 {
            return true
        } else {
            return false
        }
    }
    
    func passDataBack () {
       readStocksTable()
    }
}

extension HistQuoteViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
  
        guard let item = stockHistArray?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.id
            cellIdentifier = CellIdentifiers.stockIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.name
            cellIdentifier = CellIdentifiers.stockNameCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[2] {
            text = typeTable.comboBox(keyValueForItemAt: item.type)!
            cellIdentifier = CellIdentifiers.stockTypeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[3] {
            text = marketplaceTable.comboBox(keyValueForItemAt: item.marketPlace)!
            cellIdentifier = CellIdentifiers.stockMarketPlaceCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[4] {
            text = histReferenceTable.comboBox(keyValueForItemAt: item.historicReference)!
            cellIdentifier = CellIdentifiers.histReferenceCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[5] {
            text = item.historicCode
            cellIdentifier = CellIdentifiers.histCodeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[6] {
            if let checkValue = CDate.dateToDB(item.quoteDate)  {
                text = checkValue
            } else {
                text = " "
            }
            cellIdentifier = CellIdentifiers.quoteDateCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[7] {
            text = item.upToDate
            cellIdentifier = CellIdentifiers.updatedCell.rawValue
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return MyRowView()
    }
}

extension HistQuoteViewController: NSSearchFieldDelegate {
    
    func createMenuForSearchField() {
        let menu = NSMenu()
        menu.title = "Menu"
        
        let allMenuItem = NSMenuItem()
        allMenuItem.title = "All"
        allMenuItem.target = self
        allMenuItem.action = #selector(changeSearchFieldItem(_:))
        menu.addItem(allMenuItem)
        
        menu.addItem(NSMenuItem(title: "Stock Id", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Stock Name", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Stock Type", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Market Place", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Historic Reference", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Updated", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        
        searchStock.searchMenuTemplate = menu
        self.changeSearchFieldItem(allMenuItem)
        
    }
    
    func searchFieldIsEmpty() -> Bool {
        return searchStock.stringValue.isEmpty
    }
    
    private func textFieldChanged() {
        if searchFieldIsEmpty() {
            stockHistArray = saveStockHistArray
            reloadStockList()
        } else {
            
            let searchText = searchStock.stringValue
            
            if searchStock.placeholderString  == "All" {
                stockHistArray = saveStockHistArray?.filter({( stock : StockHist) -> Bool in
                    return stock.id.lowercased().contains(searchText.lowercased())
                        || stock.name.lowercased().contains(searchText.lowercased())
                        || typeTable.comboBox(keyValueForItemAt: stock.type)!.lowercased().contains(searchText.lowercased())
                        || marketplaceTable.comboBox(keyValueForItemAt: stock.marketPlace)!.lowercased().contains(searchText.lowercased())
                        || histReferenceTable.comboBox(keyValueForItemAt: stock.historicReference)!.lowercased().contains(searchText.lowercased())
                        || stock.historicCode.lowercased().contains(searchText.lowercased())
                        || stock.upToDate.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Stock Id" {
                stockHistArray = saveStockHistArray?.filter({( stock : StockHist) -> Bool in
                    return stock.id.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Stock Name" {
                stockHistArray = saveStockHistArray?.filter({( stock : StockHist) -> Bool in
                    return stock.name.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Stock Type" {
                stockHistArray = saveStockHistArray?.filter({( stock : StockHist) -> Bool in
                    return typeTable.comboBox(keyValueForItemAt: stock.type)!.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Market Place" {
                stockHistArray = saveStockHistArray?.filter({( stock : StockHist) -> Bool in
                    return marketplaceTable.comboBox(keyValueForItemAt: stock.marketPlace)!.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Historic Reference" {
                stockHistArray = saveStockHistArray?.filter({( stock : StockHist) -> Bool in
                    return histReferenceTable.comboBox(keyValueForItemAt: stock.historicReference)!.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Updated" {
                stockHistArray = saveStockHistArray?.filter({( stock : StockHist) -> Bool in
                    return stock.upToDate.lowercased().contains(searchText.lowercased())
                })
            }
            reloadStockList()
        }
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        textFieldChanged()
    }
    
    @objc func changeSearchFieldItem (_ sender: AnyObject) {
        searchStock.placeholderString = sender.title
        if !searchFieldIsEmpty() {
            textFieldChanged()
        }
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
    }
}

class MyRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        NSColor(hex: "#8db600")!.setFill()
        dirtyRect.fill()
    }
}
