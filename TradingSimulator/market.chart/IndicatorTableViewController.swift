//
//  IndicatorTableViewController.swift
//  Trading
//
//  Created by Maroun Achille on 05/03/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class IndicatorTableViewController: NSViewController {

    let question = "Indicator Setting"
    var cdb = ChartSettingDB.instance
    var dataArray, saveDataArray: [IndicatorSetting]?
    
    var sortOrder = ""
    var sortAscending = true
    
    fileprivate enum CellIdentifiers: String, CaseIterable  {
        case indicIdCell = "indicatorIdCell"
        case indicDescCell = "indicatorDescCell"
        case indicModelCell = "indicatorModelCell"
        case indicTypeCell = "indicatorTypeCell"
        case indicValue1Cell = "indicatorValue1Cell"
        case indicValue2Cell = "indicatorValue2Cell"
        
        static var allValues: [String] {
            var values = [String]()
            self.allCases.forEach {
                values.append($0.rawValue)
            }
            return values
        }
    }
    
    
    var formatter = NumberFormatter()
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var searchTable: NSSearchField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        searchTable.delegate = self
        createMenuForSearchField()
        
        for (index, element) in CellIdentifiers.allValues.enumerated() {
            let descriptor = NSSortDescriptor(key: element, ascending: true)
            tableView.tableColumns[index].sortDescriptorPrototype = descriptor
        }
        
        sortOrder = CellIdentifiers.indicIdCell.rawValue
        
        formatter.maximumFractionDigits = 4
        formatter.numberStyle = .decimal
        
        readDataTable()
    }
    
    func readDataTable () {
        do {
            try dataArray = cdb.getIndicatorList()
            saveDataArray = dataArray
            reloadDataList()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func reloadDataList() {
        if sortOrder == CellIdentifiers.indicIdCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.id < s2.id) : (s1.id > s2.id)
            })
        } else if sortOrder == CellIdentifiers.indicDescCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.desc < s2.desc) : (s1.desc > s2.desc)
            })
        } else if sortOrder == CellIdentifiers.indicModelCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.model < s2.model) : (s1.model > s2.model)
            })
        } else if sortOrder == CellIdentifiers.indicTypeCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.type < s2.type) : (s1.type > s2.type)
            })
        } else if sortOrder == CellIdentifiers.indicValue1Cell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.value1 < s2.value1) : (s1.value1 > s2.value1)
            })
        } else if sortOrder == CellIdentifiers.indicValue2Cell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.value2 < s2.value2) : (s1.value2 > s2.value2)
            })
        }
        
        tableView.reloadData()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let identifier: NSStoryboardSegue.Identifier = "updateIndicator"
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    @IBAction func delete(_ sender: Any) {
        deleteIndicator()
    }
    
    func deleteIndicator() {
        guard tableView.selectedRow >= 0,
            let item = dataArray?[tableView.selectedRow] else {
                return
        }
        let answer = dialogOKCancel(question: "Confirm Delete ?", text: item.description)
        if answer {
            do {
                try cdb.indicatorDelete(indicator: item)
                saveDataArray = saveDataArray?.filter() { $0.id != item.id }
                textFieldChanged()
                
            } catch let error as SQLiteError {
                dspAlert(text: error.description)
            } catch let error {
                dspAlert(text: "Other Error \(error)")
            }
        }
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question,text: text)
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        return Message.dialogOKCancel(question, text: text)
    }
}

extension IndicatorTableViewController: NSTableViewDataSource {
    
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
            reloadDataList()
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier! == "updateIndicator" {
            if let item = dataArray?[tableView.selectedRow] {
                if let secondViewController = segue.destinationController as? IndicatorDetailViewController {
                    secondViewController.action = "Update"
                    secondViewController.indic = item
                }
            }
        }
        
        if segue.identifier! == "addIndicator" {
            if let secondViewController = segue.destinationController as? IndicatorDetailViewController {
                secondViewController.action = "Add"
                let addIndicator: IndicatorSetting = IndicatorSetting()
                secondViewController.indic = addIndicator
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == "updateIndicator" {
            guard tableView.selectedRow >= 0 else {
                return false
            }
        }
        return true
    }
    
    func passDataBack (action: String, indicator: IndicatorSetting ) {
        if action == "Add" {
            saveDataArray?.append(indicator)
        }
        textFieldChanged()
    }
}

extension IndicatorTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = dataArray?[row] else {
            return nil
        }
        if tableColumn == tableView.tableColumns[0] {
            text = item.id
            cellIdentifier = CellIdentifiers.indicIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.desc
            cellIdentifier = CellIdentifiers.indicDescCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.model
            cellIdentifier = CellIdentifiers.indicModelCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.type
            cellIdentifier = CellIdentifiers.indicTypeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[4] {
            //text = String(format:"%.4f", item.value1)
            text = formatter.string(from: item.value1 as NSNumber)!
            cellIdentifier = CellIdentifiers.indicValue1Cell.rawValue
            
        } else if tableColumn == tableView.tableColumns[5] {
            //text = String(format:"%.4f", item.value2)
            text = formatter.string(from: item.value2 as NSNumber)!
            cellIdentifier = CellIdentifiers.indicValue2Cell.rawValue
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

extension IndicatorTableViewController: NSSearchFieldDelegate {
    
    func createMenuForSearchField() {
        let menu = NSMenu()
        menu.title = "Menu"
        
        let allMenuItem = NSMenuItem()
        allMenuItem.title = "All"
        allMenuItem.target = self
        allMenuItem.action = #selector(changeSearchFieldItem(_:))
        menu.addItem(allMenuItem)
        
        menu.addItem(NSMenuItem(title: "Id", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Desc", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Model", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Type", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        
        searchTable.searchMenuTemplate = menu
        self.changeSearchFieldItem(allMenuItem)
    }
    
    func searchFieldIsEmpty() -> Bool {
        return searchTable.stringValue.isEmpty
    }
    
    private func textFieldChanged() {

        if searchFieldIsEmpty() {
            dataArray = saveDataArray
        } else {
            
            let searchText = searchTable.stringValue
            
            if searchTable.placeholderString  == "All" {
                dataArray = saveDataArray?.filter({( item : IndicatorSetting) -> Bool in
                    return item.id.lowercased().contains(searchText.lowercased())
                        || item.desc.lowercased().contains(searchText.lowercased())
                        || item.model.lowercased().contains(searchText.lowercased())
                        || item.type.lowercased().contains(searchText.lowercased())
                    
                })
            } else if searchTable.placeholderString  == "Id" {
                dataArray = saveDataArray?.filter({( item : IndicatorSetting) -> Bool in
                    return item.id.lowercased().contains(searchText.lowercased())
                })
                
            } else if searchTable.placeholderString  == "Desc" {
                dataArray = saveDataArray?.filter({( item : IndicatorSetting) -> Bool in
                    return item.desc.lowercased().contains(searchText.lowercased())
                })
            } else if searchTable.placeholderString  == "Model" {
                dataArray = saveDataArray?.filter({( item : IndicatorSetting) -> Bool in
                    return item.model.lowercased().contains(searchText.lowercased())
                })
            } else if searchTable.placeholderString  == "Type" {
                dataArray = saveDataArray?.filter({( item : IndicatorSetting) -> Bool in
                    return item.type.lowercased().contains(searchText.lowercased())
                })
            }
        }
        reloadDataList()
    }
    
    // MARK: - NSSearchFieldDelegate
    
    func controlTextDidChange(_ obj: Notification) {
        textFieldChanged()
    }
    
    @objc func changeSearchFieldItem (_ sender: AnyObject) {
        searchTable.placeholderString = sender.title
        if !searchFieldIsEmpty() {
            textFieldChanged()
        }
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
    }
}
