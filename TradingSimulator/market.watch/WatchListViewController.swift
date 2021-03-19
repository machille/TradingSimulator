//
//  WatchListViewController.swift
//  Trading
//
//  Created by Maroun Achille on 13/05/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class WatchListViewController: NSViewController {

    let question = "Setup Watch List"
    var wldb = WatchListDB.instance
    var dataArray : [WatchList]?
    var iDataArray : [WatchListIndex]?
    var sortOrder = ""
    var iSortOrder = ""
    var sortAscending = true
    
    
    fileprivate enum CellIdentifiers: String {
        case watchListNameCell = "watchListNameCell"
        case watchListScreenerCell = "watchListScreenerCell"
        case watchListIndexSymbolCell = "watchListIndexSymbolCell"
        case watchListIndexNameCell = "watchListIndexNameCell"
    }
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var iTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        
        tableView.tableColumns[0].sortDescriptorPrototype = NSSortDescriptor(key: CellIdentifiers.watchListNameCell.rawValue , ascending: true)
        tableView.tableColumns[1].sortDescriptorPrototype = NSSortDescriptor(key: CellIdentifiers.watchListScreenerCell.rawValue , ascending: true)
        sortOrder = CellIdentifiers.watchListNameCell.rawValue
        
        
        iTableView.delegate = self
        iTableView.dataSource = self
        iTableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        iTableView.sizeToFit()
        
        iTableView.tableColumns[0].sortDescriptorPrototype = NSSortDescriptor(key: CellIdentifiers.watchListIndexSymbolCell.rawValue , ascending: true)
        iTableView.tableColumns[1].sortDescriptorPrototype = NSSortDescriptor(key: CellIdentifiers.watchListIndexNameCell.rawValue , ascending: true)
        
        iSortOrder = CellIdentifiers.watchListIndexSymbolCell.rawValue
        
        readWatchListTable()
        
        if (dataArray?.count ?? 0) > 0 {
            let indexSet = NSIndexSet(index: 0)
            tableView.selectRowIndexes(indexSet as IndexSet, byExtendingSelection: false)
        }
    }
    
    func readWatchListTable() {
        do {
            try dataArray = wldb.getWatchList()
             reloadWatchList()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func reloadWatchList() {
            
        if sortOrder == CellIdentifiers.watchListNameCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.id < s2.id) : (s1.id > s2.id)
            })
        } else if sortOrder == CellIdentifiers.watchListScreenerCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.name < s2.name) : (s1.name > s2.name)
            })
        }
        tableView.reloadData()
    }

    func reloadWatchListIndex() {
            
        if iSortOrder == CellIdentifiers.watchListIndexSymbolCell.rawValue {
            iDataArray = iDataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stockId < s2.stockId) : (s1.stockId > s2.stockId)
            })
        } else if iSortOrder == CellIdentifiers.watchListIndexNameCell.rawValue {
            iDataArray = iDataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stockName < s2.stockName) : (s1.stockName > s2.stockName)
            })
        }
         
        iTableView.reloadData()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
         let identifier: NSStoryboardSegue.Identifier = "updateWatchList"
         performSegue(withIdentifier: identifier, sender: nil)
     }
    

    @IBAction func deleteWatchList(_ sender: Any) {
        guard tableView.selectedRow >= 0,
            let item = dataArray?[tableView.selectedRow] else {
                return
        }
        let answer = dialogOKCancel(question: "Confirm Delete Watch List?", text: item.description)
        if answer {
            do {
                try wldb.watchListDelete(watchList: item)
                dataArray = dataArray?.filter() { $0.id != item.id }
                iDataArray?.removeAll()
                reloadWatchList()
                reloadWatchListIndex()
            } catch let error as SQLiteError {
                dspAlert(text: error.description)
            } catch let error {
                dspAlert(text: "Other Error \(error)")
            }
        }
    }

    @IBAction func addWatchListIndex(_ sender: NSButton) {
        guard tableView.selectedRow >= 0,
            let wlItem = dataArray?[tableView.selectedRow] else {
                return
        }
        let storyboardMain = NSStoryboard(name: "Files", bundle: nil)
        let stocksSearchWindowsController = storyboardMain.instantiateController(withIdentifier: "stocksSearchWindowsController") as! NSWindowController
           
        if let stocksSearchWindows = stocksSearchWindowsController.window {
               
            let stocksSearchViewController = stocksSearchWindows.contentViewController as! StocksSearchViewController
               
            let application = NSApplication.shared
            application.runModal(for: stocksSearchWindows)
               
            if let stock = stocksSearchViewController.stock {
                 
                do {
                    let wlIndex = WatchListIndex()
                    wlIndex.stockId = stock.id
                    wlIndex.stockName = stock.name
                    wlIndex.watchListId = wlItem.id
                    try wldb.watchListIndexInsert(watchListIndex: wlIndex)
                
                    iDataArray?.append(wlIndex)
                    wlItem.stockArray = iDataArray!
                    reloadWatchListIndex()
                    
                } catch let error as SQLiteError {
                    dspAlert(text: error.description)
                } catch let error {
                    dspAlert(text: "Other Error \(error)")
                }
            }
            stocksSearchWindows.close()
        }
    }
       
    @IBAction func deleteWatchListIndex(_ sender: Any) {
        guard tableView.selectedRow >= 0,
            let wlItem = dataArray?[tableView.selectedRow] else {
                return
        }

        guard iTableView.selectedRow >= 0,
            let item = iDataArray?[iTableView.selectedRow] else {
                return
        }
        let answer = dialogOKCancel(question: "Confirm Delete Stock from Watch List?", text: item.description)
        if answer {
            do {
                try wldb.watchListIndexDelete(watchListIndex: item)
                iDataArray = iDataArray?.filter() { $0.stockId != item.stockId }
                wlItem.stockArray = iDataArray!
                reloadWatchListIndex()
            } catch let error as SQLiteError {
                dspAlert(text: error.description)
            } catch let error {
                dspAlert(text: "Other Error \(error)")
            }
        }
    }

    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        return Message.dialogOKCancel(question, text: text)
    }
}

extension WatchListViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        var count = 0
        
        if tableView == self.tableView {
            count = dataArray?.count ?? 0
        }
        if tableView == self.iTableView {
            count = iDataArray?.count ?? 0
        }
        return count
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        if tableView == self.tableView {
        
            guard let sortDescriptor = tableView.sortDescriptors.first else {
                return
            }
    
            if let order = sortDescriptor.key {
                sortOrder = order
                sortAscending = sortDescriptor.ascending
                reloadWatchList()
            }
        }
        
        if tableView == self.iTableView {
            
            guard let sortDescriptor = iTableView.sortDescriptors.first else {
                return
            }
        
            if let order = sortDescriptor.key {
                iSortOrder = order
                sortAscending = sortDescriptor.ascending
                reloadWatchListIndex()
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let testTableView = notification.object as! NSTableView
        
        if  testTableView == self.tableView {
            let clickedRow = tableView.selectedRow
            
            if clickedRow > -1 {
                guard let item = dataArray?[clickedRow] else {
                    return
                }
                iDataArray = item.stockArray
                reloadWatchListIndex()
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier! == "updateWatchList" {
            if let item = dataArray?[tableView.selectedRow] {
                if let secondViewController = segue.destinationController as? WatchListDetailViewController {
                    secondViewController.action = "Update"
                    secondViewController.watchList = item
                }
            }
        }
            
        if segue.identifier! == "addWatchList" {
            if let secondViewController = segue.destinationController as? WatchListDetailViewController {
                secondViewController.action = "Add"
                let addWatchList = WatchList()
                secondViewController.watchList = addWatchList
                
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == "updateWatchList" {
            guard tableView.selectedRow >= 0 else {
                return false
            }
        }
        return true
    }
        
    func passDataBack (action: String, watchList: WatchList ) {
        if action == "Add" {
            dataArray?.append(watchList)
        }
        iDataArray = watchList.stockArray // or removeAll()
        reloadWatchList()
        reloadWatchListIndex()
    }
}

extension WatchListViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
       
        if tableView == self.tableView {
            guard let item = dataArray?[row] else {
                return nil
            }
        
            if tableColumn == tableView.tableColumns[0] {
                text = item.name
                cellIdentifier = CellIdentifiers.watchListNameCell.rawValue
            
            } else if tableColumn == tableView.tableColumns[1] {
                text = item.screener
                cellIdentifier = CellIdentifiers.watchListScreenerCell.rawValue
            }
        
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
        }

        if tableView == self.iTableView {
            guard let item = iDataArray?[row] else {
                return nil
            }
        
            if tableColumn == tableView.tableColumns[0] {
                text = item.stockId
                cellIdentifier = CellIdentifiers.watchListIndexSymbolCell.rawValue
            
            } else if tableColumn == tableView.tableColumns[1] {
                text = item.stockName
                cellIdentifier = CellIdentifiers.watchListIndexNameCell.rawValue
            }
        
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
        }

        return nil
    }
    
}


