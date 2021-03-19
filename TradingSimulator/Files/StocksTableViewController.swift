//
//  StocksTableViewController.swift
//  Trading
//
//  Created by Maroun Achille on 14/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class StocksTableViewController: NSViewController {
    let question = "Setup Stocks"
    var sdb = StockDB.instance
    var hqdb = StockQuoteDB.instance
    var wldb = WatchListDB.instance
    var stocksArray, saveStocksArray: [Stock]?
    var typeTable, currencyTable, marketplaceTable: TableComboDB!
    var sortOrder = ""
    var sortAscending = true
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case stockIdCell = "stockIdCell"
        case stockNameCell = "stockNameCell"
        case stockTypeCell = "stockTypeCell"
        case stockIndusCell = "stockIndusCell"
        case stockCurrencyCell = "stockCurrencyCell"
        case stockMarketPlaceCell = "stockMarketPlaceCell"
    
        static var allValues: [String] {
            var values = [String]()
            self.allCases.forEach {
                values.append($0.rawValue)
            }
            return values
        }
    }
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var searchStock: NSSearchField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        
        searchStock.delegate = self
        createMenuForSearchField()
        
        for (index, element) in CellIdentifiers.allValues.enumerated() {
            let descriptor = NSSortDescriptor(key: element, ascending: true)
            tableView.tableColumns[index].sortDescriptorPrototype = descriptor
        }
        
        sortOrder = CellIdentifiers.stockIdCell.rawValue
    
        readStocksTable()
    }
    
    fileprivate func readStocksTable () {
        do {
            try stocksArray = sdb.getStocksList()
            saveStocksArray = stocksArray
            try typeTable = TableComboDB.init(tableName: "STKTYP")
            try currencyTable = TableComboDB.init(tableName: "CURCY")
            try marketplaceTable = TableComboDB.init(tableName: "MRKPLC")
             reloadStockList()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    fileprivate func reloadStockList() {
        
        if sortOrder == CellIdentifiers.stockIdCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.id < s2.id) : (s1.id > s2.id)
            })
        } else if sortOrder == CellIdentifiers.stockNameCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.name < s2.name) : (s1.name > s2.name)
            })
        } else if sortOrder == CellIdentifiers.stockIndusCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.industry < s2.industry) : (s1.industry > s2.industry)
            })
        } else if sortOrder == CellIdentifiers.stockTypeCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.type < s2.type) : (s1.type > s2.type)
            })
        } else if sortOrder == CellIdentifiers.stockCurrencyCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.currency < s2.currency) : (s1.currency > s2.currency)
            })
        } else if sortOrder == CellIdentifiers.stockMarketPlaceCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (marketplaceTable.comboBox(keyValueForItemAt: s1.marketPlace)! < marketplaceTable.comboBox(keyValueForItemAt: s2.marketPlace)!) : (marketplaceTable.comboBox(keyValueForItemAt: s1.marketPlace)! > marketplaceTable.comboBox(keyValueForItemAt: s2.marketPlace)!)
            })
        }
        
        tableView.reloadData()
    }
    
    @IBAction func delete(_ sender: Any) {
        deleteStock()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let identifier: NSStoryboardSegue.Identifier = "updateStock"
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    fileprivate func deleteStock() {
        guard tableView.selectedRow >= 0,
            let item = stocksArray?[tableView.selectedRow] else {
                return
        }
        let answer = dialogOKCancel(question: "confirm Delete ?", text: item.description)
        if answer {
            do {
                try sdb.stockDelete(stock: item)
                try sdb.indexMemberDelete (stockId: item.id)
                try hqdb.histQuoteDelete(stockId: item.id)
                try wldb.watchListDeleteStock(stockId: item.id)
                saveStocksArray = saveStocksArray?.filter() { $0.id != item.id }
                
                textFieldChanged()
            } catch let error as SQLiteError {
                dspAlert(text: error.description)
            } catch let error {
                dspAlert(text: "Other Error \(error)")
            }
        }
    }

    fileprivate func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    fileprivate func dialogOKCancel(question: String, text: String) -> Bool {
        return Message.dialogOKCancel(question, text: text)
    }
    
}

extension StocksTableViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return stocksArray?.count ?? 0
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
        if segue.identifier! == "updateStock" {
            if let item = stocksArray?[tableView.selectedRow] {
                if let secondViewController = segue.destinationController as? StocksDetailViewController {
                    secondViewController.action = "Update"
                    secondViewController.stock = item
                }
            }
        }
        
        if segue.identifier! == "addStock" {
            if let secondViewController = segue.destinationController as? StocksDetailViewController {
                secondViewController.action = "Add"
                let addStock: Stock = Stock()
                secondViewController.stock = addStock
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == "updateStock" {
            guard tableView.selectedRow >= 0 else {
                return false
            }
        }
        return true
    }
    
    func passDataBack (action: String, stock: Stock) {
        if action == "Add" {
            saveStocksArray?.append(stock)
        }
        textFieldChanged()
    }
}


extension StocksTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        

        guard let item = stocksArray?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.id
            cellIdentifier = CellIdentifiers.stockIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.name
            cellIdentifier = CellIdentifiers.stockNameCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.industry
            cellIdentifier = CellIdentifiers.stockIndusCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[3] {
            text = typeTable.comboBox(keyValueForItemAt: item.type)!
            cellIdentifier = CellIdentifiers.stockTypeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[4] {
            text = currencyTable.comboBox(keyValueForItemAt: item.currency)!
            cellIdentifier = CellIdentifiers.stockCurrencyCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[5] {
            text = marketplaceTable.comboBox(keyValueForItemAt: item.marketPlace)!
            cellIdentifier = CellIdentifiers.stockMarketPlaceCell.rawValue
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}


extension StocksTableViewController: NSSearchFieldDelegate {
    
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
        
        searchStock.searchMenuTemplate = menu
        self.changeSearchFieldItem(allMenuItem)
        
    }
    
    func searchFieldIsEmpty() -> Bool {
        return searchStock.stringValue.isEmpty
    }
    
    private func textFieldChanged() {
       if searchFieldIsEmpty() {
            stocksArray = saveStocksArray
            reloadStockList()
        } else {
            
            let searchText = searchStock.stringValue
            
            if searchStock.placeholderString  == "All" {
                stocksArray = saveStocksArray?.filter({( stock : Stock) -> Bool in
                    return stock.id.lowercased().contains(searchText.lowercased())
                        || stock.name.lowercased().contains(searchText.lowercased())
                        || typeTable.comboBox(keyValueForItemAt: stock.type)!.lowercased().contains(searchText.lowercased())
                        || marketplaceTable.comboBox(keyValueForItemAt: stock.marketPlace)!.lowercased().contains(searchText.lowercased())
                  })
            } else if searchStock.placeholderString  == "Stock Id" {
                stocksArray = saveStocksArray?.filter({( stock : Stock) -> Bool in
                    return stock.id.lowercased().contains(searchText.lowercased())
                })

            } else if searchStock.placeholderString  == "Stock Name" {
                stocksArray = saveStocksArray?.filter({( stock : Stock) -> Bool in
                    return stock.name.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Stock Type" {
                stocksArray = saveStocksArray?.filter({( stock : Stock) -> Bool in
                    return typeTable.comboBox(keyValueForItemAt: stock.type)!.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Market Place" {
                stocksArray = saveStocksArray?.filter({( stock : Stock) -> Bool in
                    return marketplaceTable.comboBox(keyValueForItemAt: stock.marketPlace)!.lowercased().contains(searchText.lowercased())
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
