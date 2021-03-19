//
//  ChartDetailViewController.swift
//  Trading
//
//  Created by Maroun Achille on 13/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartDetailViewController: NSViewController {

    @IBOutlet weak var chartId: NSTextField!
    @IBOutlet weak var chartDesc: NSTextField!
    
    @IBOutlet weak var chartModel: NSPopUpButton!
    @IBOutlet weak var chartType: NSPopUpButton!
    @IBOutlet weak var chartPeriod: NSPopUpButton!
    
    @IBOutlet weak var defaultColor: NSColorWell!
    @IBOutlet weak var lineColor: NSColorWell!
    
    @IBOutlet weak var columnColor: NSColorWell!
    @IBOutlet weak var jcHighColor: NSColorWell!
    @IBOutlet weak var jcLowColor: NSColorWell!
    @IBOutlet weak var backColor: NSColorWell!
    @IBOutlet weak var selected: NSButton!
    @IBOutlet weak var order: NSTextField!
    
    @IBOutlet weak var actionButton: NSButton!
    
    @IBOutlet weak var tableView: NSTableView!
    var cdb = ChartSettingDB.instance
    var removeDataArray: [ChartIndicator]?
    
    let question = "Setup Chart"
    var action: String = "Add"
    
    var formatter = NumberFormatter()
    
    var chart: ChartSetting?  {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        
        chartModel.removeAllItems()
        chartModel.addItems(withTitles: ChartModel.allValues)
        chartModel.selectItem(at: 0)
        
        chartType.removeAllItems()
        chartType.addItems(withTitles: ChartType.allValues)
        chartType.selectItem(at: 0)
        
        chartPeriod.removeAllItems()
        chartPeriod.addItems(withTitles: ChartDefaultValue.menuPeriod)
        chartPeriod.selectItem(at: 0)
        
        formatter.maximumFractionDigits = 4
        formatter.numberStyle = .decimal
        removeDataArray = [ChartIndicator]()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }
    
    func updateUI() {
       
        if !isViewLoaded {
            return
        }
        if action == "Add" {
            chartId.isEditable = true
        } else {
            chartId.isEditable = false
        }
        
        if let chart = chart {
            chartId.stringValue = chart.id
            chartDesc.stringValue = chart.desc
            
            chartModel.selectItem(withTitle: chart.model)
            chartType.selectItem(withTitle: chart.type)
            chartPeriod.selectItem(withTitle: chart.period)
            
            defaultColor.color = chart.defaultColor
            lineColor.color = chart.lineColor
            columnColor.color = chart.columnColor
             
            jcHighColor.color = chart.jcHighColor
            jcLowColor.color = chart.jcLowColor
            backColor.color = chart.backColor
                
            if chart.selected == "1" {
                selected.state = NSControl.StateValue.on
            } else {
                selected.state = NSControl.StateValue.off
            }
            order.intValue = chart.order
        }
        
        tableView.reloadData()
        actionButton.title = action
    }
    
    func validate() ->Bool {
        guard !chartId.stringValue.isEmpty  else {
            dspAlert(text: "Chart Id is required")
            return false
        }
        chart?.id = chartId.stringValue
        
        guard !chartDesc.stringValue.isEmpty  else {
            dspAlert(text: "Description is required")
            return false
        }
        chart?.desc = chartDesc.stringValue
        
        guard ChartModel.allValues.contains(chartModel.titleOfSelectedItem!) else {
            dspAlert(text: "Chart Model invalid Value")
            return false
        }
        chart?.model = chartModel.titleOfSelectedItem!
        
        guard ChartType.allValues.contains(chartType.titleOfSelectedItem!) else {
            dspAlert(text: "Chart Type invalid Value")
            return false
        }
        chart?.type = chartType.titleOfSelectedItem!
        
        guard ChartDefaultValue.menuPeriod.contains(chartPeriod.titleOfSelectedItem!) else {
            dspAlert(text: "Chart Period invalid Value")
            return false
        }
        chart?.period = chartPeriod.titleOfSelectedItem!
        
        chart?.defaultColor = defaultColor.color
        chart?.lineColor = lineColor.color
        chart?.columnColor = columnColor.color
        chart?.jcHighColor = jcHighColor.color
        chart?.jcLowColor = jcLowColor.color
        chart?.backColor = backColor.color
        
        if selected.state == NSControl.StateValue.on {
            chart?.selected = "1"
        } else {
            chart?.selected = "0"
        }
        
        chart?.order = order.intValue
        
        do {
            if action == "Add" {
                try cdb.chartInsert(chart: chart!)
            } else {
                try cdb.chartUpdate(chart: chart!)
            }
            
            if removeDataArray?.count ?? 0 > 0 {
                try cdb.chartIndicatorDelete(chartIndic: removeDataArray!)
            }
            
            return true
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        
        return false
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let identifier: NSStoryboardSegue.Identifier = "updateChartIndic"
        performSegue(withIdentifier: identifier, sender: nil)
    }

    
    @IBAction func delete(_ sender: Any) {
        deleteChartIndicator()
    }
    
    func deleteChartIndicator() {
        guard tableView.selectedRow >= 0,
            let item = chart?.chartIndic[tableView.selectedRow] else {
                return
        }
        let answer = dialogOKCancel(question: "Confirm Delete ?", text: item.description)
        if answer {
            chart?.chartIndic.remove(at: tableView.selectedRow)
            if item.id != "-1" {
                removeDataArray?.append(item)
            }
            tableView.reloadData()
        }
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        return Message.dialogOKCancel(question, text: text)
    }
    
    @IBAction func Save(_ sender: Any) {
        if validate() {
            let firstViewController = presentingViewController as! ChartTableViewController
            firstViewController.passDataBack(action: action, chart: chart!)
             self.dismiss(self)
        }
    }

    @IBAction func dismissWindow(_ sender: NSButton) {
        if chart?.chartIndic.count ?? 0 > 0 { // remove new item
            for (index, removeItem) in (chart?.chartIndic.enumerated())! {
                if removeItem.id == "-1" {
                    chart?.chartIndic.remove(at: index)
                }
            }
        }
        if removeDataArray?.count ?? 0 > 0 { // reinsert deleted item
            for removeItem in removeDataArray! {
                chart?.chartIndic.append(removeItem)
            }
        }
        
        self.dismiss(self)
    }
}

extension ChartDetailViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return chart?.chartIndic.count ?? 0
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier! == "updateChartIndic" {
            if let item = chart?.chartIndic[tableView.selectedRow] {
                if let secondViewController = segue.destinationController as? ChartIndicDetailViewController {
                    secondViewController.action = "Update"
                    secondViewController.chartIndic = item
                }
            }
        }
        
        if segue.identifier! == "addChartIndic" {
            if let secondViewController = segue.destinationController as? ChartIndicDetailViewController {
                secondViewController.action = "Add"
                let addChartIndic = ChartIndicator()
                secondViewController.chartIndic = addChartIndic
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == "updateChartIndic" {
            guard tableView.selectedRow >= 0 else {
                return false
            }
        }
        return true
    }
    
    func passDataBack (action: String, chartIndic: ChartIndicator ) {
        if action == "Add" {
            chart?.chartIndic.append(chartIndic)
        }
         tableView.reloadData()
    }
}

extension ChartDetailViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let chartindicIdCell = "chartindicIdCell"
        static let chartindicDescCell = "chartindicDescCell"
        static let chartindicDefaultCell = "chartindicDefaultCell"
        static let chartindicValue1Cell = "chartindicValue1Cell"
        //static let chartPeriodCell = "chartPeriodCell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = chart?.chartIndic[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.indicatorId
            cellIdentifier = CellIdentifiers.chartindicIdCell
            
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.indicatorDesc
            cellIdentifier = CellIdentifiers.chartindicDescCell
            
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.defaultValue
            cellIdentifier = CellIdentifiers.chartindicDefaultCell
            
        } else if tableColumn == tableView.tableColumns[3] {
            text = formatter.string(from: item.value1 as NSNumber)!
            cellIdentifier = CellIdentifiers.chartindicValue1Cell
        }
        
        if tableColumn == tableView.tableColumns[2] {
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
