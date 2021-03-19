//
//  StocksSearchViewController.swift
//  Trading
//
//  Created by Maroun Achille on 26/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class StocksSearchViewController: NSViewController {

    let question = "Search Stocks"
    var sdb: StockDB = StockDB.instance
    var stocksArray, saveStocksArray: [Stock]?
    var typeTable, currencyTable, marketplaceTable: TableComboDB!
    var sortOrder = ""
    var sortAscending = true
    var stock: Stock?
    
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
    
    func readStocksTable () {
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
    
    
    func reloadStockList() {
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
                return sortAscending ? (typeTable.comboBox(keyValueForItemAt: s1.type)! < typeTable.comboBox(keyValueForItemAt: s2.type)!) : (typeTable.comboBox(keyValueForItemAt: s1.type)! > typeTable.comboBox(keyValueForItemAt: s2.type)!)
            })
        } else if sortOrder == CellIdentifiers.stockCurrencyCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (currencyTable.comboBox(keyValueForItemAt: s1.currency)! < currencyTable.comboBox(keyValueForItemAt: s2.currency)!) : (currencyTable.comboBox(keyValueForItemAt: s1.currency)! > currencyTable.comboBox(keyValueForItemAt: s2.currency)!)
            })
        } else if sortOrder == CellIdentifiers.stockMarketPlaceCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (marketplaceTable.comboBox(keyValueForItemAt: s1.marketPlace)! < marketplaceTable.comboBox(keyValueForItemAt: s2.marketPlace)!) : (marketplaceTable.comboBox(keyValueForItemAt: s1.marketPlace)! > marketplaceTable.comboBox(keyValueForItemAt: s2.marketPlace)!)
            })
        }
        
        tableView.reloadData()
    }
    
    @IBAction func select(_ sender: Any) {
        selectStock()
    }
    
    @IBAction func close(_ sender: NSButton) {
        stock = nil
        let application = NSApplication.shared
        application.stopModal()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        selectStock() 
    }
    
    func selectStock() {
        guard tableView.selectedRow >= 0,
            let item = stocksArray?[tableView.selectedRow] else {
                return
        }
        stock = item
        let application = NSApplication.shared
        application.stopModal()
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
}

extension StocksSearchViewController: NSTableViewDataSource {
    
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
}

extension StocksSearchViewController: NSTableViewDelegate {
    
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

extension StocksSearchViewController: NSSearchFieldDelegate {
    
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
                    //return stock.type.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Market Place" {
                stocksArray = saveStocksArray?.filter({( stock : Stock) -> Bool in
                    return marketplaceTable.comboBox(keyValueForItemAt: stock.marketPlace)!.lowercased().contains(searchText.lowercased())
                    //return stock.marketPlace.lowercased().contains(searchText.lowercased())
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
}
