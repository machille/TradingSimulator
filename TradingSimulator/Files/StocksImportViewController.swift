//
//  StockImportViewController.swift
//  Trading
//
//  Created by Maroun Achille on 30/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class StocksImportViewController: NSViewController {

    let question = "Import Stocks References"
    var sdb = StockDB.instance
    var hqdb = StockQuoteDB.instance
    var wldb = WatchListDB.instance
    var stocksArray, saveStocksArray: [StockImport]?
    var sortOrder = ""
    var sortAscending = true
    var typeTable, currencyTable, marketPlaceTable, dailyReferenceTable, histReferenceTable: TableComboDB!
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case stockIdCell = "stockIdCell"
        case stockNameCell = "stockNameCell"
        case stockIndexIdCell = "stockIndexIdCell"
        case stockTypeCell = "stockTypeCell"
        case stockCurrencyCell = "stockCurrencyCell"
        case stockActionCell = "stockActionCell"
    
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
    @IBOutlet weak var fileName: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stocksArray = [StockImport]()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        
        searchStock.delegate = self
        createMenuForSearchField()
        
        for (index, element) in CellIdentifiers.allValues.enumerated() {
            let descriptor = NSSortDescriptor(key: element, ascending: true)
            tableView.tableColumns[index].sortDescriptorPrototype = descriptor
        }
        
        sortOrder = CellIdentifiers.stockIdCell.rawValue
        
        do {
            try typeTable = TableComboDB.init(tableName: "STKTYP")
            try currencyTable = TableComboDB.init(tableName: "CURCY")
            try marketPlaceTable = TableComboDB.init(tableName: "MRKPLC")
            try dailyReferenceTable = TableComboDB.init(tableName: "QOTREF")
            try histReferenceTable = TableComboDB.init(tableName: "QOTHST")
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        
    }
    
    func reloadStockList() {
        if sortOrder == CellIdentifiers.stockIdCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stock.id < s2.stock.id) : (s1.stock.id > s2.stock.id)
            })
        } else if sortOrder == CellIdentifiers.stockNameCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stock.name < s2.stock.name) : (s1.stock.name > s2.stock.name)
            })
        } else if sortOrder == CellIdentifiers.stockIndexIdCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.indexId < s2.indexId) : (s1.indexId > s2.indexId)
            })
        } else if sortOrder == CellIdentifiers.stockTypeCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (typeTable.comboBox(keyValueForItemAt: s1.stock.type)! < typeTable.comboBox(keyValueForItemAt: s2.stock.type)!) : (typeTable.comboBox(keyValueForItemAt: s1.stock.type)! > typeTable.comboBox(keyValueForItemAt: s2.stock.type)!)
            })
        } else if sortOrder == CellIdentifiers.stockCurrencyCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (currencyTable.comboBox(keyValueForItemAt: s1.stock.currency)! < currencyTable.comboBox(keyValueForItemAt: s2.stock.currency)!) : (currencyTable.comboBox(keyValueForItemAt: s1.stock.currency)! > currencyTable.comboBox(keyValueForItemAt: s2.stock.currency)!)
            })
        } else if sortOrder == CellIdentifiers.stockActionCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.action < s2.action) : (s1.action > s2.action)
            })
        }
        
        tableView.reloadData()
    }
    
    @IBAction func selectFile(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.title = "Select CSV file"
        openPanel.allowedFileTypes = ["csv"]
        
        openPanel.beginSheetModal(for:self.view.window!) { (response) in
            if response == .OK {
                let selectedPath = openPanel.url!.path
                let file = openPanel.url!.lastPathComponent
                self.fileName.stringValue = selectedPath
                
                let srcURL = URL(fileURLWithPath: selectedPath)
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                let documentUrl = directory.appendingPathComponent(file)
                
                do {
                    // Delete if already exists
                    if FileManager.default.fileExists(atPath: documentUrl.path) {
                        try FileManager.default.removeItem(atPath: documentUrl.path)
                    }
                    
                    try FileManager.default.copyItem(at: srcURL, to: documentUrl)
                } catch {
                    self.dspAlert(text:"copy failed:" + error.localizedDescription)
                }
                self.stocksArray?.removeAll()
                self.processFile(path: file)
            } else {
                return
            }
        }
    }
    
    @IBAction func importStock(_ sender: NSButton) {
        var cpt = 0
        for stockImp in saveStocksArray! {
            do {
                if stockImp.stock.type == "Index" {
                    if stockImp.action == "RELOAD" {
                        cpt += 1
                        if (findStock(id: stockImp.stock.id)) {
                            try sdb.indexMemberDelete(indexId: stockImp.stock.id)
                            try sdb.stockUpdate(stock: stockImp.stock)
                        } else {
                            try sdb.stockInsert(stock: stockImp.stock)
                        }
                        try wldb.insertWatchList(watchListName: stockImp.watchListName, stockId: stockImp.stock.id)
                    } else if stockImp.action  == "DELETE" {
                        cpt += 1
                        if (findStock(id: stockImp.stock.id)) {
                            try sdb.indexMemberDelete(indexId: stockImp.stock.id)
                            try sdb.stockDelete(stock: stockImp.stock)
                            try hqdb.histQuoteDelete(stockId: stockImp.stock.id)
                            try wldb.watchListDeleteStock(stockId: stockImp.stock.id)
                        }
                    }
                } else  if stockImp.stock.type == "Stock" {
                    cpt += 1
                    if stockImp.action  == "UPDATE" {
                        if (findStock(id: stockImp.stock.id)) {
                            try sdb.stockUpdate(stock: stockImp.stock)
                            if !stockImp.indexId.isEmpty {
                                try sdb.indexMemberDelete(indexId: stockImp.indexId, stockId:stockImp.stock.id)
                                try sdb.indexMemberInsert(indexId: stockImp.indexId, stockId:stockImp.stock.id, weight: 0)
                            }
                        } else {
                            try sdb.stockInsert(stock: stockImp.stock)
                            if !stockImp.indexId.isEmpty {
                                try sdb.indexMemberInsert(indexId: stockImp.indexId, stockId:stockImp.stock.id, weight: 0)
                            }
                        }
                        try wldb.insertWatchList(watchListName: stockImp.watchListName, stockId: stockImp.stock.id)
                    } else if stockImp.action  == "DELETE" {
                        cpt += 1
                        if (findStock(id: stockImp.stock.id)) {
                            try sdb.indexMemberDelete(stockId: stockImp.stock.id)
                            try sdb.stockDelete(stock: stockImp.stock)
                            try hqdb.histQuoteDelete(stockId: stockImp.stock.id)
                            try wldb.watchListDeleteStock(stockId: stockImp.stock.id)
                        }
                    }
                } else  if stockImp.stock.type == "Currency" {
                    cpt += 1
                    if stockImp.action  == "UPDATE" {
                        if (findStock(id: stockImp.stock.id)) {
                            try sdb.stockUpdate(stock: stockImp.stock)
                        } else {
                            try sdb.stockInsert(stock: stockImp.stock)
                        }
                        try wldb.insertWatchList(watchListName: stockImp.watchListName, stockId: stockImp.stock.id)
                    } else if stockImp.action  == "DELETE" {
                        cpt += 1
                        if (findStock(id: stockImp.stock.id)) {
                            try sdb.stockDelete(stock: stockImp.stock)
                            try hqdb.histQuoteDelete(stockId: stockImp.stock.id)
                            try wldb.watchListDeleteStock(stockId: stockImp.stock.id)
                        }
                    }
                }

            } catch let error as SQLiteError {
                dspAlert(text: error.description + " " + stockImp.stock.description)
            } catch let error {
                dspAlert(text: "Other Error \(error)")
            }
        }
        dspAlert(text: "Stock(s) loaded \(cpt) /  \(saveStocksArray?.count ?? 0)")
    }
    
    func processFile(path: String) {
        var data: String
        var category, indexSymbol, stockId, companyName, industry, currency, marketPlace : String
        var dailyRef, dailySymbol, historicRef, historicSymbol, action : String, watchListName: String
        var check: Bool
        var cpt: Int = 0
        
        // file must be exported with excel in utf8
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(path)
        
        do {
            data  = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            dspAlert(text: "error Read File : \(fileURL): \(error)")
            return
        }
        
        data = data.replacingOccurrences(of: "\r", with: "\n")
        data = data.replacingOccurrences(of: "\n\n", with: "\n")
        
        let lines = data.split(separator: "\n", omittingEmptySubsequences: false)
        check = true
        
        for line in lines {
            let str = line.components(separatedBy: ";")
            cpt += 1
            
            //print("----")
            //print(line)
            if line.count < 5 {
                continue
            }
            if str.count < 13 {
                dspAlert(text: "Error formt line at \(cpt)")
                return
            }
            
            category = str[0]; indexSymbol = str[1]; stockId = str[2]; companyName = str[3]; industry = str[4]; currency = str[5]; marketPlace = str[6];
            dailyRef = str[7]; dailySymbol = str[8]; historicRef = str[9]; historicSymbol = str[10]; watchListName = str[11];
            action = str[12];
            //print("category \(category) indexSymbol \(indexSymbol) stockId \(stockId) companyName \(companyName) watchListName \(watchListName)")
            if category == "Category" {
                continue
            }
            
            let stockImp: StockImport = StockImport()
            
            if !stockId.isEmpty {
                stockImp.stock.id = stockId
            } else {
                check = false
                stockImp.action = "ERROR Stock Id is empty"
            }
            
            if !companyName.isEmpty {
                 stockImp.stock.name = companyName
            } else {
                check = false
                stockImp.action = "ERROR Stock Name is empty"
            }
            
            if typeTable.comboBox(keyCheckForItem: category) {
                stockImp.stock.type = category
            } else {
                check = false
                stockImp.action = "ERROR Type value \(category)"
            }
            
            stockImp.indexId = indexSymbol
            
            stockImp.stock.industry = industry
            
            if currencyTable.comboBox(keyCheckForItem: currency) {
                stockImp.stock.currency = currency
            } else {
                check = false
                stockImp.action = "ERROR Currency value \(currency)"
            }

            if marketPlaceTable.comboBox(keyCheckForItem: marketPlace) {
                 stockImp.stock.marketPlace = marketPlace
            } else {
                check = false
                stockImp.action = "ERROR Market Place value \(marketPlace)"
            }
            
            if dailyReferenceTable.comboBox(keyCheckForItem: dailyRef) {
                stockImp.stock.dailyReference = dailyRef
            } else {
                check = false
                stockImp.action = "ERROR Daily Reference value \(dailyRef)"
            }
            
            if !dailySymbol.isEmpty {
                stockImp.stock.dailyCode = dailySymbol
            } else {
                check = false
                stockImp.action = "ERROR Daily Code is empty"
            }
            
            if histReferenceTable.comboBox(keyCheckForItem: historicRef) {
                stockImp.stock.historicReference = historicRef
            } else {
                check = false
                stockImp.action = "ERROR Historic Reference value \(historicSymbol)"
            }
            
            if !historicSymbol.isEmpty {
                stockImp.stock.historicCode = historicSymbol
            } else {
                check = false
                stockImp.action = "ERROR Historic Code is empty"
            }
            
            if check {
                stockImp.action = action
            }
            
            stockImp.watchListName = watchListName
            check = true
            
            stocksArray?.append(stockImp)
            //print(stockImp.description)
        }
        saveStocksArray = stocksArray
        reloadStockList()
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    func findStock(id: String) -> Bool {
        do {
            let _: Stock = try sdb.getStocksId (id: id)
            return true
        } catch SQLiteError.NotFound {
            return false
        } catch {
            return false
        }
    }
}

extension StocksImportViewController: NSTableViewDataSource {
    
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

extension StocksImportViewController: NSTableViewDelegate {
    
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
            text = item.stock.id
            cellIdentifier = CellIdentifiers.stockIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.stock.name
            cellIdentifier = CellIdentifiers.stockNameCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.indexId
            cellIdentifier = CellIdentifiers.stockIndexIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[3] {
            text = typeTable.comboBox(keyValueForItemAt: item.stock.type)!
            cellIdentifier = CellIdentifiers.stockTypeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[4] {
            text = currencyTable.comboBox(keyValueForItemAt: item.stock.currency)!
            cellIdentifier = CellIdentifiers.stockCurrencyCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[5] {
            text = item.action
            cellIdentifier = CellIdentifiers.stockActionCell.rawValue
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}


extension StocksImportViewController: NSSearchFieldDelegate {
    
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
        menu.addItem(NSMenuItem(title: "Action", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        
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
                stocksArray = saveStocksArray?.filter({( stockImp : StockImport) -> Bool in
                    return stockImp.stock.id.lowercased().contains(searchText.lowercased())
                        || stockImp.stock.name.lowercased().contains(searchText.lowercased())
                        || typeTable.comboBox(keyValueForItemAt: stockImp.stock.type)!.lowercased().contains(searchText.lowercased())
                        || stockImp.action.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Stock Id" {
                stocksArray = saveStocksArray?.filter({(stockImp : StockImport) -> Bool in
                    return stockImp.stock.id.lowercased().contains(searchText.lowercased())
                })
                
            } else if searchStock.placeholderString  == "Stock Name" {
                stocksArray = saveStocksArray?.filter({( stockImp : StockImport) -> Bool in
                    return stockImp.stock.name.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Stock Type" {
                stocksArray = saveStocksArray?.filter({(stockImp : StockImport) -> Bool in
                    return typeTable.comboBox(keyValueForItemAt: stockImp.stock.type)!.lowercased().contains(searchText.lowercased())
                    //return stock.type.lowercased().contains(searchText.lowercased())
                })
            } else if searchStock.placeholderString  == "Action" {
                stocksArray = saveStocksArray?.filter({(stockImp : StockImport) -> Bool in
                    return stockImp.action.lowercased().contains(searchText.lowercased())
                })
            }
            reloadStockList()
        }
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        //print("controlTextDidChange \(searchStock.stringValue)  \(searchFieldIsEmpty())   Menu \(searchStock.placeholderString ?? "XXX")")
        textFieldChanged()
    }
    
    @objc func changeSearchFieldItem (_ sender: AnyObject) {
        searchStock.placeholderString = sender.title
        if !searchFieldIsEmpty() {
            textFieldChanged()
        }
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        //        print("didStart \(searchStock.placeholderString ?? "XXX" )")
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        //       print("didEnd")
    }
}
