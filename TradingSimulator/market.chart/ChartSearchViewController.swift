//
//  ChartSearchViewController.swift
//  Trading
//
//  Created by Maroun Achille on 09/12/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartSearchViewController: NSViewController {

    let question = "Search Chart"
    var dataArray, saveDataArray: [ChartSetting]?
    var chartD: ChartDrawing?
    var sortOrder = ""
    var sortAscending = true
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case chartIdCell = "chartIdCell"
        case chartDescCell = "chartDescCell"
        case chartModelCell = "chartModelCell"
        case chartTypeCell = "chartTypeCell"
        case chartPeriodCell = "chartPeriodCell"
        case chartSelectedCell = "chartSelectedCell"
     
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
        
        sortOrder = CellIdentifiers.chartIdCell.rawValue
        
        readDataTable()
    }
    
    func readDataTable () {
        do {
            try dataArray = ChartSettingDB.instance.getChartList()
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
        }
    
        tableView.reloadData()
    }
    
    @IBAction func select(_ sender: Any) {
        selectChart()
    }
    
    @IBAction func close(_ sender: NSButton) {
        chartD = nil
        let application = NSApplication.shared
        application.stopModal()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        selectChart()
    }
    
    func selectChart() {
        chartD = nil
        guard tableView.selectedRow >= 0,
            let item = dataArray?[tableView.selectedRow] else {
                return
        }
        do {
            try chartD = ChartSettingDB.instance.getChartDraw(id: item.id)
            let application = NSApplication.shared
            application.stopModal()

        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
}

extension ChartSearchViewController: NSTableViewDataSource {
    
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
}

extension ChartSearchViewController: NSTableViewDelegate {
    
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

extension ChartSearchViewController: NSSearchFieldDelegate {
    
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
}

