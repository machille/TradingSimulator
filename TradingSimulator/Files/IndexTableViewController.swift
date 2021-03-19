//
//  IndexTableViewController.swift
//  Trading
//
//  Created by Maroun Achille on 21/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class IndexTableViewController: NSViewController {

    let storyboardMain = NSStoryboard(name: "Files", bundle: nil)
    let question = "Setup Index Member"
    var sdb: StockDB = StockDB.instance
    var indexMemberArray: [IndexMember]?
    var indexArray: [Stock]?
 
    var sortOrder = ""
    var sortAscending = true
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case stockIdCell = "stockIdCell"
        case stockNameCell = "stockNameCell"
        
        static var allValues: [String] {
            var values = [String]()
            self.allCases.forEach {
                values.append($0.rawValue)
            }
            return values
        }
    }
    
    @IBOutlet weak var indexCombo: NSPopUpButton!
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.target = self
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        
        for (index, element) in CellIdentifiers.allValues.enumerated() {
            let descriptor = NSSortDescriptor(key: element, ascending: true)
            tableView.tableColumns[index].sortDescriptorPrototype = descriptor
        }
        
        sortOrder = CellIdentifiers.stockIdCell.rawValue
        
        readIndex ()
    }
    
    @IBAction func indexPop(_ sender: NSPopUpButton) {
        readStocks ()
    }
    
    func readIndex () {
        do {
            try indexArray = sdb.getIndexList()
            indexCombo.removeAllItems()
            for stock in indexArray! {
                indexCombo.addItem(withTitle: stock.name)
            }
            indexCombo.selectItem(at: 0)
            readStocks ()
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func readStocks () {
        do {
            if indexArray?.count ?? 0 > 0 {
                try indexMemberArray = sdb.getIndexMember(indexId: indexArray![indexCombo.indexOfSelectedItem].id)
                reloadTableList()
            }
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func reloadTableList() {
        
        if sortOrder == CellIdentifiers.stockIdCell.rawValue {
            indexMemberArray = indexMemberArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stockId < s2.stockId) : (s1.stockId > s2.stockId)
            })
        } else if sortOrder == CellIdentifiers.stockNameCell.rawValue {
            indexMemberArray = indexMemberArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stockName < s2.stockName) : (s1.stockName > s2.stockName)
            })
        }
        tableView.reloadData()
    }
    
    @IBAction func add(_ sender: NSButton) {
        let stocksSearchWindowsController = storyboardMain.instantiateController(withIdentifier: "stocksSearchWindowsController") as! NSWindowController
        
        if let stocksSearchWindows = stocksSearchWindowsController.window {
            
            let stocksSearchViewController = stocksSearchWindows.contentViewController as! StocksSearchViewController
            
            let application = NSApplication.shared
            application.runModal(for: stocksSearchWindows)
            
            if let stock = stocksSearchViewController.stock {
        
                do {
                    let indexMember: IndexMember = IndexMember()
                    indexMember.stockId = stock.id
                    indexMember.stockName = stock.name
                    indexMember.indexId = indexArray![indexCombo.indexOfSelectedItem].id
                    
                    try sdb.indexMemberInsert(indexM: indexMember)
                    indexMemberArray?.append(indexMember)
                    reloadTableList()
                } catch let error as SQLiteError {
                    dspAlert(text: error.description)
                } catch let error {
                    dspAlert(text: "Other Error \(error)")
                }
            }
            stocksSearchWindows.close()
        }
    }
    
    @IBAction func delete(_ sender: NSButton) {
        guard tableView.selectedRow >= 0,
            let item = indexMemberArray?[tableView.selectedRow] else {
                return
        }
        let answer = dialogOKCancel(question: question, text: "confirm Delete Stock from Index " + item.description)
        if answer {
            do {
                try sdb.indexMemberDelete(indexM: item)
                indexMemberArray?.remove(at: tableView.selectedRow)
                reloadTableList()
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

extension IndexTableViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return indexMemberArray?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        
        if let order = sortDescriptor.key {
            sortOrder = order
            sortAscending = sortDescriptor.ascending
            reloadTableList()
        }
    }
}

extension IndexTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = indexMemberArray?[row] else {
            return nil
        }

        if tableColumn == tableView.tableColumns[0] {
            text = item.stockId
            cellIdentifier = CellIdentifiers.stockIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.stockName
            cellIdentifier = CellIdentifiers.stockNameCell.rawValue
            
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}
