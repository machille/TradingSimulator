//
//  QuoteStockViewController.swift
//  Trading
//
//  Created by Maroun Achille on 22/09/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class QuoteStockViewController: NSViewController {

    private let question = "Stock Quote"

    private var textColor: NSColor = NSColor.green
    private var backColor: NSColor = NSColor.black
    
    private let idqDB = IndexDailyQuoteDB.instance
    var stocksArray: [StockDayQuote]?
    private var sortOrder = ""
    private var sortAscending = true
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case stockIdCell = "stockIdCell"
        case stockNameCell = "stockNameCell"
        case stockTimeCell = "stockTimeCell"
        case stockChangeCell = "stockChangeCell"
        case stockLastCell = "stockLastCell"
        case stock52ChangeCell = "stock52ChangeCell"
        case stockVolumeCell = "stockVolumeCell"
    
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
        tableView.backgroundColor = NSColor.black
        tableView.sizeToFit()
        
        searchStock.delegate = self
        searchStock.sendsSearchStringImmediately = false
        searchStock.sendsWholeSearchString = true
        
        for (index, element) in CellIdentifiers.allValues.enumerated() {
            let descriptor = NSSortDescriptor(key: element, ascending: true)
            tableView.tableColumns[index].sortDescriptorPrototype = descriptor
        }
        
        sortOrder = CellIdentifiers.stockIdCell.rawValue
        if let firstIndex = idqDB.firstIndex {
            setIndex(indexId: firstIndex)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        InternetStreamQuote.instance.addActionDelegate(name: "STOCK", controller: self)
        MarketWatchActionDelegate.instance.addActionDelegate(name: "STOCK", controller: self)
    }
 
    override func viewDidDisappear() {
        super.viewDidDisappear()
        InternetStreamQuote.instance.removeActionDelegate(name: "STOCK")
        MarketWatchActionDelegate.instance.removeActionDelegate(name: "STOCK")
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
        } else if sortOrder == CellIdentifiers.stockTimeCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.dateQuote < s2.dateQuote) : (s1.dateQuote > s2.dateQuote)
            })
        } else if sortOrder == CellIdentifiers.stockChangeCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.varChange < s2.varChange) : (s1.varChange > s2.varChange)
            })
        } else if sortOrder == CellIdentifiers.stockLastCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.close < s2.close) : (s1.close > s2.close)
            })
        } else if sortOrder == CellIdentifiers.stock52ChangeCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.yearRange < s2.yearRange) : (s1.yearRange > s2.yearRange)
            })
        } else if sortOrder == CellIdentifiers.stockVolumeCell.rawValue {
            stocksArray = stocksArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.volume < s2.volume) : (s1.volume > s2.volume)
            })
        }
        
        if !isViewLoaded {
            return
        }
        
        tableView.reloadData()
    }
    
    fileprivate func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        guard tableView.selectedRow >= 0,
        let item = stocksArray?[tableView.selectedRow] else {
            return
        }
        let chartF = ChartWindowFactory.instance
        chartF.setStockId(id: item.id)
        chartF.show()
    }
}

extension QuoteStockViewController: QuoteDelegate {
    func reloadQuote() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension QuoteStockViewController: MarketWatchDelegate {
    func setIndex(indexId: String) {
        stocksArray = idqDB.getStockIndex(indexId: indexId)
        searchStock.stringValue = ""
        reloadStockList()
    }
    
    func setWatchList(watchListId: Int) {
        stocksArray = idqDB.getWatchListStock(id: watchListId)
        searchStock.stringValue = ""
        reloadStockList()
    }
    
    func watchAllChart() {
        guard let stockArray = stocksArray else {
            return
        }
        let cwf = ChartWatchWindowFactory.instance
        cwf.setStocksDayQuote(stockArray)
        cwf.setTextLabel(text: "")
        cwf.show()
    }
}


extension QuoteStockViewController: NSTableViewDataSource {
    
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

extension QuoteStockViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var textValue: String = ""
        var numberValue: Double = 0.0
        
        var cellIdentifier: String = ""
        
        guard let item = stocksArray?[row] else {
            return nil
        }
        
        if item.varChange < 0 {
            textColor = ChartDefaultValue.redColor
        } else if item.varChange > 0 {
            textColor = ChartDefaultValue.greenColor
        } else {
            textColor = ChartDefaultValue.whiteColor
        }

        if item.status == 0 {
            backColor = textColor
            textColor = NSColor.black
        } else if item.status == 1 {
            backColor = textColor
            textColor = NSColor.black
        } else {
            backColor = NSColor.black
        }

        if tableColumn == tableView.tableColumns[0] {
            textValue = item.id
            cellIdentifier = CellIdentifiers.stockIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            textValue = item.name
            cellIdentifier = CellIdentifiers.stockTimeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[2] {
//            textValue = dateFormatter.string(from: item.dateQuote)
            textValue = CDate.dateQuoteTime(item.dateQuote)
            cellIdentifier = CellIdentifiers.stockTimeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[3] {
            textValue = Calculate.formatNumber(2, item.varChange) + " %"
            cellIdentifier = CellIdentifiers.stockChangeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[4] {
            textValue = Calculate.formatNumber(2, item.close)
            cellIdentifier = CellIdentifiers.stockLastCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[5] {
//            textValue = Calculate.formatNumber(2, item.yearVarChange) + " %"
            textValue = Calculate.formatNumber(2, item.yearRange) + " %"
            cellIdentifier = CellIdentifiers.stock52ChangeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[6] {
            textValue = "number"
            numberValue = item.volume
            cellIdentifier = CellIdentifiers.stockVolumeCell.rawValue
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            if textValue == "number" {
                cell.textField?.doubleValue = numberValue
            } else {
                cell.textField?.stringValue = textValue
            }
            cell.textField?.textColor = textColor
            
            let tmpRow : NSTableRowView = tableView.rowView(atRow: row, makeIfNecessary: false)!
            tmpRow.backgroundColor = backColor
//            tmpRow.selectionHighlightStyle = .none
            
            return cell
        }
        return nil
    }
}
// MARK: - NSSearchFieldDelegate
extension QuoteStockViewController: NSSearchFieldDelegate {
    
//    private func searchFieldIsEmpty() -> Bool {
//        return searchStock.stringValue.isEmpty
//    }
    
    private func textFieldChanged() {
        let searchText = searchStock.stringValue
        stocksArray = StockDayQuoteDB.instance.stockDayQuoteArra.filter({(stock: StockDayQuote) -> Bool in
                    return stock.id.lowercased().contains(searchText.lowercased())
                        || stock.name.lowercased().contains(searchText.lowercased())
                })
            
        self.reloadStockList()
    }
    
    
    func controlTextDidChange(_ obj: Notification) {
        if searchStock === obj.object as! NSSearchField {
            textFieldChanged()
        }
    }
}

