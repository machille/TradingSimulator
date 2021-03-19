//
//  ChartTableViewController.swift
//  Trading
//
//  Created by Maroun Achille on 13/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartTableViewController: NSViewController {

    let question = "Chart Setting"
    var cdb = ChartSettingDB.instance
    var dataArray, saveDataArray: [ChartSetting]?
    
    var sortOrder = ""
    var sortAscending = true
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case chartIdCell = "chartIdCell"
        case chartDescCell = "chartDescCell"
        case chartModelCell = "chartModelCell"
        case chartTypeCell = "chartTypeCell"
        case chartPeriodCell = "chartPeriodCell"
        case chartSelectedCell = "chartSelectedCell"
        case chartOrderCell = "chartOrderCell"
     
        static var allValues: [String] {
            var values = [String]()
            self.allCases.forEach {
                values.append($0.rawValue)
            }
            return values
        }
    }
    
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
        
        sortOrder = CellIdentifiers.chartOrderCell.rawValue
        
        readDataTable()
    }
    
    func readDataTable () {
        do {
            try dataArray = cdb.getChartList()
            saveDataArray = dataArray
            reloadDataList()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func reloadDataList() {
        if sortOrder == CellIdentifiers.chartIdCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.id < s2.id) : (s1.id > s2.id)
            })
        } else if sortOrder == CellIdentifiers.chartDescCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.desc < s2.desc) : (s1.desc > s2.desc)
            })
        } else if sortOrder == CellIdentifiers.chartModelCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.model < s2.model) : (s1.model > s2.model)
            })
        } else if sortOrder == CellIdentifiers.chartTypeCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.type < s2.type) : (s1.type > s2.type)
            })
        } else if sortOrder == CellIdentifiers.chartPeriodCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.period < s2.period) : (s1.period > s2.period)
            })
        } else if sortOrder == CellIdentifiers.chartSelectedCell.rawValue {
             dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.selected < s2.selected) : (s1.selected > s2.selected)
            })
        } else if sortOrder == CellIdentifiers.chartOrderCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.order < s2.order) : (s1.order > s2.order)
            })
        }
        
        tableView.reloadData()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let identifier: NSStoryboardSegue.Identifier = "updateChart"
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    @IBAction func delete(_ sender: Any) {
        deleteChart()
    }
    
    func deleteChart() {
        guard tableView.selectedRow >= 0,
            let item = dataArray?[tableView.selectedRow] else {
                return
        }
        let answer = dialogOKCancel(question: "Confirm Delete ?", text: item.description)
        if answer {
            do {
                try cdb.chartDelete(chart: item)
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
        Message.messageAlert(question, text: text)
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        return Message.dialogOKCancel(question, text: text)
    }
}

extension ChartTableViewController: NSTableViewDataSource {
    
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
     
        if segue.identifier! == "updateChart" {
            if let item = dataArray?[tableView.selectedRow] {
                if let secondViewController = segue.destinationController as? ChartDetailViewController {
                    secondViewController.action = "Update"
                    secondViewController.chart = item
                }
            }
        }

        if segue.identifier! == "addChart" {
            if let secondViewController = segue.destinationController as? ChartDetailViewController {
                secondViewController.action = "Add"
                let addChart: ChartSetting = ChartSetting()
                secondViewController.chart = addChart
            }
        }
     }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == "updateChart" {
            guard tableView.selectedRow >= 0 else {
                return false
            }
        }
        return true
    }
    
    func passDataBack (action: String, chart: ChartSetting ) {
        if action == "Add" {
            saveDataArray?.append(chart)
        }
        textFieldChanged()
    }
}

extension ChartTableViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""

        guard let item = dataArray?[row] else {
            return nil
        }
        if tableColumn == tableView.tableColumns[0] {
            text = item.id
            cellIdentifier = CellIdentifiers.chartIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.desc
            cellIdentifier = CellIdentifiers.chartDescCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.model
            cellIdentifier = CellIdentifiers.chartModelCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.type
            cellIdentifier = CellIdentifiers.chartTypeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[4] {
            text = item.period
            cellIdentifier = CellIdentifiers.chartPeriodCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[5] {
            text = item.selected
            cellIdentifier = CellIdentifiers.chartSelectedCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[6] {
            text = String(item.order)
            cellIdentifier = CellIdentifiers.chartOrderCell.rawValue
        }
        
        if tableColumn == tableView.tableColumns[5] {
            let cell:NSButton = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSButton
            if text == "1" {
                cell.state = NSControl.StateValue.on
            } else {
                cell.state = NSControl.StateValue.off
            }
            return cell
        } else if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

extension ChartTableViewController: NSSearchFieldDelegate {
    
    func createMenuForSearchField() {
        let menu = NSMenu()
        menu.title = "Menu"
        
        let allMenuItem = NSMenuItem()
        allMenuItem.title = "All"
        allMenuItem.target = self
        allMenuItem.action = #selector(changeSearchFieldItem(_:))
        menu.addItem(allMenuItem)
        
        menu.addItem(NSMenuItem(title: "Chart Id", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Chart Desc", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Chart Model", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Chart Type", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        
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
                dataArray = saveDataArray?.filter({( item : ChartSetting) -> Bool in
                    return item.id.lowercased().contains(searchText.lowercased())
                        || item.desc.lowercased().contains(searchText.lowercased())
                        || item.model.lowercased().contains(searchText.lowercased())
                        || item.type.lowercased().contains(searchText.lowercased())
                    
                })
            } else if searchTable.placeholderString  == "Chart Id" {
                dataArray = saveDataArray?.filter({( item : ChartSetting) -> Bool in
                    return item.id.lowercased().contains(searchText.lowercased())
                })
                
            } else if searchTable.placeholderString  == "Chart Desc" {
                dataArray = saveDataArray?.filter({( item : ChartSetting) -> Bool in
                    return item.desc.lowercased().contains(searchText.lowercased())
                })
            } else if searchTable.placeholderString  == "Chart Model" {
                dataArray = saveDataArray?.filter({( item : ChartSetting) -> Bool in
                    return item.model.lowercased().contains(searchText.lowercased())
                })
            } else if searchTable.placeholderString  == "Chart Type" {
                dataArray = saveDataArray?.filter({( item : ChartSetting) -> Bool in
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
