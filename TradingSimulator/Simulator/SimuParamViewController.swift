//
//  SimuParamViewController.swift
//  Trading
//
//  Created by Maroun Achille on 27/06/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class SimuParamViewController: NSViewController {

    private let question = "Setup Simulator"

    private var dataArray, saveDataArray: [SimuPosition]?
    private var typeTable: TableComboDB!
    private var sortOrder = ""
    private var sortAscending = true
    private var tableItem1: Ttables?, tableItem2: Ttables?, tableItem3: Ttables?, tableItem4: Ttables?
    
    private var simuWindow: SimuWindow?
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var searchField: NSSearchField!
    
    @IBOutlet weak var clearButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    
    private var showArrow = "Yes"
    
    fileprivate enum CellIdentifiers: String, CaseIterable {
        case stockIdCell = "simuStockIdCell"
        case stockNameCell = "simuStockNameCell"
        case stockTypeCell = "simuStockIndusCell"
        case simuStartingDate = "simuStartingDateCell"
        case simuStartingBalance = "simuStartingBalanceCell"
        case simuActualBalance = "simuActualBalanceCell"
        case simuVar = "simuVarCell"
        case simuAction = "simuActionCell"
        
        static var allValues: [String] {
            var values = [String]()
            self.allCases.forEach {
                values.append($0.rawValue)
            }
            return values
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        
        searchField.delegate = self
        createMenuForSearchField()
        
        for (index, element) in CellIdentifiers.allValues.enumerated() {
            let descriptor = NSSortDescriptor(key: element, ascending: true)
            tableView.tableColumns[index].sortDescriptorPrototype = descriptor
        }
        
        sortOrder = CellIdentifiers.stockIdCell.rawValue
        clearButton.isHidden = true
        readTable()
        
    }
    
    func readTable () {
        do {
            try dataArray = SimulatorDB.instance.getSimuList()
            saveDataArray = dataArray
            try typeTable = TableComboDB.init(tableName: "STKTYP")
    
            reloadDataList()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func reloadDataList() {
        
        if sortOrder == CellIdentifiers.stockIdCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stockId < s2.stockId) : (s1.stockId > s2.stockId)
            })
        } else if sortOrder == CellIdentifiers.stockNameCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stockName < s2.stockName) : (s1.stockName > s2.stockName)
            })
        } else if sortOrder == CellIdentifiers.stockTypeCell.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.stockType < s2.stockType) : (s1.stockType > s2.stockType)
            })
        } else if sortOrder == CellIdentifiers.simuStartingDate.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.startDate < s2.startDate) : (s1.startDate > s2.startDate)
            })
        } else if sortOrder == CellIdentifiers.simuStartingBalance.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.startBalance < s2.startBalance) : (s1.startBalance > s2.startBalance)
            })
        } else if sortOrder == CellIdentifiers.simuActualBalance.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.actualBalance < s2.actualBalance) : (s1.actualBalance > s2.actualBalance)
            })
        } else if sortOrder == CellIdentifiers.simuVar.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.totalVar < s2.totalVar) : (s1.totalVar > s2.totalVar)
            })
        } else if sortOrder == CellIdentifiers.simuAction.rawValue {
            dataArray = dataArray?.sorted(by: { (s1 , s2) -> Bool in
                return sortAscending ? (s1.action < s2.action) : (s1.action > s2.action)
            })
        }
        
        tableView.reloadData()
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        launshSimu()
    }
    
    private func launshSimu() {
        guard tableView.selectedRow >= 0,
            let item = dataArray?[tableView.selectedRow] else {
                return
        }

        do {
            tableItem4 = try TtablesDB.instance.getTableItem(name: "SIMU", id: "SHOARW")
            if let defValue = tableItem4 {
                showArrow = defValue.value1
            } else {
                showArrow = "Yes"
            }
            
            if item.action == "Continue" {
                let simuPos = try SimulatorDB.instance.getSimuPosId(simuPos: item)
                showSimulator(simuPos: simuPos)
            } else {
                tableItem1 = try TtablesDB.instance.getTableItem(name: "SIMU", id: "BALANCE")
                if let defValue = tableItem1 {
                    item.startBalance = defValue.value3
                } else {
                    item.startBalance = 30000.0
                }
               
                item.actualBalance = item.startBalance
                
                tableItem2 = try TtablesDB.instance.getTableItem(name: "SIMU", id: "TURBCK")
                if let defValue = tableItem2 {
                    item.startDate = CDate.subDate(Date(), defValue.value1)
                } else {
                    item.startDate = NSCalendar.current.date(byAdding: .year, value: -7,  to: Date())!
                }
                
                if item.stockType == "Currency" {
                    item.indexId = "NA"
                } else {
                    tableItem3 = try TtablesDB.instance.getTableItem(name: "SIMU", id: "INDEX")
                    if let defValue = tableItem3 {
                        item.indexId = defValue.value1
                    } else {
                        item.indexId  = "DOWJONES"
                    }
                }
                
                item.action = "Continue"
                item.setSimuId()
                try SimulatorDB.instance.simuPosInsert(simuPos: item)
                tableView.reloadData()
                showSimulator(simuPos: item)
            }
                
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }

    private func showSimulator(simuPos: SimuPosition) {
        simuWindow = SimuWindow()
        simuWindow?.showArrow = showArrow
        simuWindow?.setSimuPos(simuPos: simuPos)
        simuWindow?.show()
    }
    
    @IBAction func clearSimu(_ sender: NSButton) {
        guard tableView.selectedRow >= 0,
            let item = dataArray?[tableView.selectedRow] else {
                return
        }
        
        do {
            try SimulatorDB.instance.simuOrderDelete(simuPos: item)
            try SimulatorDB.instance.simuPosDelete(simuPos: item)
            readTable()
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    
    @IBAction func startSimu(_ sender: NSButton) {
        launshSimu()
    }
    
    
    @IBAction func closeSimu(_ sender: NSButton) {
         self.view.window?.close()
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        return Message.dialogOKCancel(question, text: text)
    }
}

extension SimuParamViewController: NSTableViewDataSource {
    
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

extension SimuParamViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
         guard let item = dataArray?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.stockId
            cellIdentifier = CellIdentifiers.stockIdCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.stockName
            cellIdentifier = CellIdentifiers.stockNameCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[2] {
            text = typeTable.comboBox(keyValueForItemAt: item.stockType)!
            cellIdentifier = CellIdentifiers.stockTypeCell.rawValue
            
        } else if tableColumn == tableView.tableColumns[3] {
            text = CDate.formatDate(item.lastDate, "dd/MM/YYYY")
            cellIdentifier = CellIdentifiers.simuStartingDate.rawValue
            
        } else if tableColumn == tableView.tableColumns[4] {
            text = Calculate.formatNumber(2, item.startBalance)
            cellIdentifier = CellIdentifiers.simuStartingBalance.rawValue
            
        } else if tableColumn == tableView.tableColumns[5] {
            text = Calculate.formatNumber(2, item.actualBalance)
            cellIdentifier = CellIdentifiers.simuActualBalance.rawValue
            
        } else if tableColumn == tableView.tableColumns[6] {
            text = Calculate.formatNumber(2, item.totalVar * 100)
            cellIdentifier = CellIdentifiers.simuVar.rawValue
            
        } else if tableColumn == tableView.tableColumns[7] {
            text = item.action
            cellIdentifier = CellIdentifiers.simuAction.rawValue
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let item = dataArray?[tableView.selectedRow] {
            startButton.title = item.action
            clearButton.isHidden = (item.action == "Start")
        }
    }
}

extension SimuParamViewController: NSSearchFieldDelegate {
    
    func createMenuForSearchField() {
        let menu = NSMenu()
        menu.title = "Menu"
        
        let allMenuItem = NSMenuItem()
        allMenuItem.title = "All"
        allMenuItem.target = self
        allMenuItem.action = #selector(changeSearchFieldItem(_:))
        menu.addItem(allMenuItem)
        
        menu.addItem(NSMenuItem(title: "Id", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Name", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Type", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Action", action: #selector(changeSearchFieldItem(_:)), keyEquivalent: ""))
        
        searchField.searchMenuTemplate = menu
        self.changeSearchFieldItem(allMenuItem)
    }
    
    func searchFieldIsEmpty() -> Bool {
        return searchField.stringValue.isEmpty
    }
    
    private func textFieldChanged() {
        if searchFieldIsEmpty() {
            dataArray = saveDataArray
        } else {
            
            let searchText = searchField.stringValue
            
            if searchField.placeholderString  == "All" {
                dataArray = saveDataArray?.filter({( item : SimuPosition) -> Bool in
                    return item.stockId.lowercased().contains(searchText.lowercased())
                        || item.stockName.lowercased().contains(searchText.lowercased())
                        || item.stockType.lowercased().contains(searchText.lowercased())
                    
                })
            } else if searchField.placeholderString  == "Id" {
                dataArray = saveDataArray?.filter({( item : SimuPosition) -> Bool in
                    return item.stockId.lowercased().contains(searchText.lowercased())
                })
                
            } else if searchField.placeholderString  == "Name" {
                dataArray = saveDataArray?.filter({( item : SimuPosition) -> Bool in
                    return item.stockName.lowercased().contains(searchText.lowercased())
                })
            } else if searchField.placeholderString  == "Type" {
                dataArray = saveDataArray?.filter({( item : SimuPosition) -> Bool in
                    return item.stockType.lowercased().contains(searchText.lowercased())
                })
            } else if searchField.placeholderString  == "Action" {
                dataArray = saveDataArray?.filter({( item : SimuPosition) -> Bool in
                    return item.action.lowercased().contains(searchText.lowercased())
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
        searchField.placeholderString = sender.title
        if !searchFieldIsEmpty() {
            textFieldChanged()
        }
    }
}

