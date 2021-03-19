//
//  QuoteWatchListViewController.swift
//  Trading
//
//  Created by Maroun Achille on 18/05/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class QuoteWatchListViewController: NSViewController {

    let question = "Quote Watch List"
    var wldb = WatchListDB.instance
    var dataArray : [WatchList]?
    var sortOrder = "wlName"
    var sortAscending = true
    
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.action = #selector(onItemClicked)
        
        let descriptorWatchListName = NSSortDescriptor(key: "wlName", ascending: true)
        tableView.tableColumns[0].sortDescriptorPrototype = descriptorWatchListName
        
        readWatchListTable()
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
        if sortOrder == "wlName" {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.name < s2.name) : (s1.name > s2.name)
            })
        }
         
        tableView.reloadData()
    }

    @objc private func onItemClicked() {
        if tableView.clickedRow > -1 {
            guard let item = dataArray?[tableView.clickedRow] else {
                return
            }
            MarketWatchActionDelegate.instance.setWatchList(name: "STOCK", watchListId: item.id)
        }
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
}

extension QuoteWatchListViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataArray?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }

        if let order = sortDescriptor.key {
            sortOrder = order
            sortAscending = sortDescriptor.ascending
            reloadWatchList()
        }
    }
}

extension QuoteWatchListViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let quoteWatchListNameCell = "quoteWatchListNameCell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = dataArray?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.name
            cellIdentifier = CellIdentifiers.quoteWatchListNameCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
    
}


