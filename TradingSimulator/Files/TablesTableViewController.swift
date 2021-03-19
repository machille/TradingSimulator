//
//  tablesTableViewController.swift
//  Trading
//
//  Created by Maroun Achille on 20/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class TablesTableViewController: NSViewController {
    
    let storyboardMain = NSStoryboard(name: "Files", bundle: nil)
    let question = "Setup Tables"
    
    var tables: Ttables = Ttables()
    var ttables: [Ttables]?
    var masterTables: Array<Ttables>!
    var ttablesDB: TtablesDB = TtablesDB.instance
    var tableName: String!
    var tableDesc: String!
    
    var sortOrder = ""
    var sortAscending = true
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case tableIdCell = "tableIdCell"
        case descCell = "descCell"
        case value1Cell = "value1Cell"
        
        static var allValues: [String] {
            var values = [String]()
            self.allCases.forEach {
                values.append($0.rawValue)
            }
            return values
        }
    }
    
    
    @IBOutlet weak var masterTablesList: NSPopUpButton!
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        for (index, element) in CellIdentifiers.allValues.enumerated() {
            let descriptor = NSSortDescriptor(key: element, ascending: true)
            tableView.tableColumns[index].sortDescriptorPrototype = descriptor
        }
        
        sortOrder = CellIdentifiers.tableIdCell.rawValue
    
        
        readMasterTables ()
    }
    
    @IBAction func masterTablesPop(_ sender: NSPopUpButton) {
        for table in masterTables {
            if table.index == sender.indexOfSelectedItem as Int {
                tableName = table.id
                tableDesc = table.desc
                readTables ()
            }
        }
    }
    
    
    @IBAction func deleteTables(_ sender: NSButton) {
        deleteTable()
    }
    
    
    func readMasterTables () {
        do {
            try masterTables = ttablesDB.getMasterTablesList()
            masterTablesList.removeAllItems()
            for table in masterTables {
                masterTablesList.addItem(withTitle: table.desc)
                table.index = masterTablesList.indexOfItem(withTitle: table.desc)
            }
            
            masterTablesList.selectItem(at: 0)
            tableName = masterTables[0].id
            tableDesc = masterTables[0].desc
            readTables ()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func readTables () {
        do {
            try ttables = ttablesDB.getTablesList(name: tableName)
            reloadTableList()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let identifier: NSStoryboardSegue.Identifier = "updateTable"
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    func deleteTable() {
        guard tableView.selectedRow >= 0,
            let item = ttables?[tableView.selectedRow] else {
                return
        }
        let answer = dialogOKCancel(question: "Confirm Delete ?", text: item.description)
        if answer {
            do {
                try ttablesDB.tablesDelete(tables: item)
                ttables?.remove(at: tableView.selectedRow)
                reloadTableList()
            } catch let error as SQLiteError {
                dspAlert(text: error.description)
            } catch let error {
                dspAlert(text: "Other Error \(error)")
            }
        }
    }
    
    
    func reloadTableList() {
        if sortOrder == CellIdentifiers.tableIdCell.rawValue {
            ttables = ttables?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.id < s2.id) : (s1.id > s2.id)
            })
        } else if sortOrder == CellIdentifiers.descCell.rawValue {
            ttables = ttables?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.desc < s2.desc) : (s1.desc > s2.desc)
            })
        } else if sortOrder == CellIdentifiers.value1Cell.rawValue  {
            ttables = ttables?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.value1 < s2.value1) : (s1.value1 > s2.value1)
            })
        }
        
        tableView.reloadData()
    }

    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        return Message.dialogOKCancel(question, text: text)
    }
}

extension TablesTableViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ttables?.count ?? 0
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
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier! == "updateTable" {
            if let item = ttables?[tableView.selectedRow] {
                if let secondViewController = segue.destinationController as? TablesDetailViewController {
                    secondViewController.action = "Update"
                    secondViewController.tableDesc = "Table Name : " + tableDesc
                    secondViewController.tables = item
                }
            }
        }
        
        if segue.identifier! == "addTable" {
            if let secondViewController = segue.destinationController as? TablesDetailViewController {
                secondViewController.action = "Add"
                let addTable: Ttables = Ttables()
                addTable.name = tableName
                secondViewController.tableDesc = "Table Name : " + tableDesc
                secondViewController.tables = addTable
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == "updateTable" {
            guard tableView.selectedRow >= 0 else {
                return false
            }
        }
        return true
    }
    
    func passDataBack (action: String, tables: Ttables ) {
        if action == "Add" {
            ttables?.append(tables)
        }
        reloadTableList()
    }
}

extension TablesTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = ttables?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.id
            cellIdentifier = CellIdentifiers.tableIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.desc
            cellIdentifier = CellIdentifiers.descCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.value1
            cellIdentifier = CellIdentifiers.value1Cell.rawValue
            
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}
