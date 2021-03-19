//
//  SimuViewController.swift
//  Trading
//
//  Created by Maroun Achille on 16/06/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class SimuViewController: NSViewController {

    let question = "Simulator"
    let simuDB = SimulatorDB.instance
    var chartTV = ChartTabView()
    var chartTVIndex: ChartTabView?
    
    private var dataArray: [SimuPerformance]?
    
    @IBOutlet weak var startBalance: NSTextField!
    @IBOutlet weak var startDate: NSTextField!
    @IBOutlet weak var totalCom: NSTextField!
    @IBOutlet weak var actualBalance: NSTextField!
    @IBOutlet weak var totalVar: NSTextField!
    @IBOutlet weak var profitLossAmt: NSTextField!
    
    @IBOutlet weak var position: NSTextField!
    @IBOutlet weak var quantity: NSTextField!
    @IBOutlet weak var averagePrice: NSTextField!
    @IBOutlet weak var investedAmount: NSTextField!
    @IBOutlet weak var estimatedAmounrt: NSTextField!
    @IBOutlet weak var variration: NSTextField!
    @IBOutlet weak var stopLoss: NSTextField!
    @IBOutlet weak var stopPL: NSTextField!
    @IBOutlet weak var exitOnStop: NSButton!
    @IBOutlet weak var lastQuote: NSTextField!
    @IBOutlet weak var quoteDate: NSTextField!
    
    @IBOutlet weak var openPosButton: NSButton!
    @IBOutlet weak var closePosButton: NSButton!
    
    @IBOutlet weak var stockName: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    
    var simuPos: SimuPosition?
    var showArrow = "Yes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.sizeToFit()
        
        stopLoss.delegate = self
        
        guard var headerViewFrame = tableView.headerView?.frame else {
            return
        }
        
        headerViewFrame.size.height = 28
        tableView.headerView?.frame = headerViewFrame
    }
    
    func setSimuPos(simuPos: SimuPosition) -> Bool {
        self.simuPos = simuPos
        stockName.stringValue = simuPos.stockName
        
        guard let histQuote = HistoricQuoteDB.instance.getHistoricQuote(id: simuPos.stockId)  else {
            dspAlert(text: "StocK id: \(simuPos.stockId) Not Found")
            return false
        }
        guard checkSimuDate(date: simuPos.lastDate, minDate: histQuote.minDate) else {
            dspAlert(text: "Start Date is too old for : \(simuPos.stockId) \n Start Date: \(CDate.defaultForamt(simuPos.lastDate)) < Min Date: \(CDate.defaultForamt(histQuote.minDate))")
            return false
        }
        
        chartTV.setDateSimul(dateSimu: simuPos.lastDate)
        chartTV.setStockHist(histQuote: histQuote, stockId: simuPos.stockId)
        
        if let sQuote = chartTV.initSimul() {
            simuPos.lastQuote = sQuote.close
            simuPos.lastDate = sQuote.dateQuote
        } else {
            dspAlert(text: "unable to init Simulator ")
            return false
        }
      
        if let chartTVIndex = chartTVIndex {
            guard let histQuoteIndex = HistoricQuoteDB.instance.getHistoricQuote(id: simuPos.indexId)  else {
                dspAlert(text: "Index id: \(simuPos.indexId) Not Found")
                return false
            }
            
            guard checkSimuDate(date: simuPos.lastDate, minDate: histQuoteIndex.minDate) else {
                dspAlert(text: "Start Date is too old for Index : \(simuPos.indexId) \n Start Date: \(CDate.defaultForamt(simuPos.lastDate)) < Min Date: \(CDate.defaultForamt(histQuote.minDate))")
     
                return false
            }
            
            chartTVIndex.setDateSimul(dateSimu: simuPos.lastDate)
            chartTVIndex.setStockHist(histQuote: histQuoteIndex, stockId: simuPos.indexId)
            _ = chartTVIndex.initSimul()
        }
            
        updateUI()
        loadPerfData()
        return true
    }
    
    private func checkSimuDate(date: Date, minDate:Date?) -> Bool {
        
        guard let minDate = minDate else {
            return false
        }
       
        guard date > minDate else {
            return false
        }
       
        let startDate = CDate.subDate(date, "6 Months")
        guard startDate > minDate else {
            return false
        }

        return true
    }
    
    private func loadPerfData() {
        guard let simuPos =  simuPos else {
            return
        }
         do {
            try dataArray = simuDB.getSimuPerformance(id: simuPos.simuId)
            tableView.reloadData()
            tableView.scrollRowToVisible(numberOfRows(in: tableView) - 1)
            
            if showArrow == "Yes" {
                let dataOrderArray = try simuDB.getOrderList(id: simuPos.simuId)
                for order in dataOrderArray {
                    chartTV.addOrderArrow(date: order.operationDate, action: order.operationAction, type: order.operationType)
                }
            }

         } catch let error as SQLiteError {
            dspAlert(text: error.description)
         } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
        
    private func updateUI() {
        guard let simuPos =  simuPos else {
            return
        }
        
        startBalance.doubleValue = simuPos.startBalance
        startDate.stringValue = CDate.formatDate(simuPos.startDate, "dd/MM/YYYY")
        totalCom.doubleValue = simuPos.totalComm
        actualBalance.doubleValue = simuPos.actualBalance
        totalVar.doubleValue = simuPos.totalVar
        if simuPos.totalVar > 0 {
            totalVar.backgroundColor = .systemGreen
            totalVar.textColor = .white
        } else if simuPos.totalVar < 0 {
            totalVar.backgroundColor = .red
            totalVar.textColor = .white
        } else {
            totalVar.backgroundColor = NSColor.controlBackgroundColor
            totalVar.textColor = NSColor.controlTextColor
        }
        profitLossAmt.doubleValue = simuPos.profitLossAmt
        profitLossAmt.backgroundColor = totalVar.backgroundColor
        profitLossAmt.textColor = totalVar.textColor
        
        position.stringValue = simuPos.positionType
        quantity.doubleValue = simuPos.quantity
        averagePrice.doubleValue = simuPos.averagePrice
        investedAmount.doubleValue = simuPos.investedAmount
        estimatedAmounrt.doubleValue = simuPos.estimatedAmount
        variration.doubleValue = simuPos.positionVar
        
        if simuPos.positionVar > 0 {
            variration.backgroundColor = .systemGreen
            variration.textColor = .white
        } else if simuPos.positionVar < 0 {
            variration.backgroundColor = .red
            variration.textColor = .white
        } else {
            variration.backgroundColor = NSColor.controlBackgroundColor
            variration.textColor = NSColor.controlTextColor
        }
        stopLoss.doubleValue = simuPos.stopLoss
        if stopLoss.doubleValue == 0.0 {
             stopLoss.backgroundColor = .white
        }
        
        let stopEst = simuPos.stopPL
        stopPL.doubleValue = stopEst
        if stopEst > 0 {
            stopPL.backgroundColor = .systemGreen
            stopPL.textColor = .white
        } else if stopEst < 0 {
            stopPL.backgroundColor = .red
            stopPL.textColor = .white
        } else {
            stopPL.backgroundColor = NSColor.controlBackgroundColor
            stopPL.textColor = NSColor.controlTextColor
        }
        
        lastQuote.doubleValue = simuPos.lastQuote
        quoteDate.stringValue = CDate.formatDate(simuPos.lastDate, "dd/MM/YYYY")
        
        if simuPos.quantity == 0 {
            openPosButton.title = "Open Position"
            closePosButton.isEnabled = false
        } else {
            openPosButton.title = "Add Position"
            closePosButton.isEnabled = true
        }
    }
    
    private func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        return Message.dialogOKCancel(question, text: text)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier! == "openPosition" {
            if let item = simuPos {
                if let secondViewController = segue.destinationController as? SimuOrderViewController {
                    secondViewController.action = "Open"
                    secondViewController.simuPos = item
                }
            }
        }
        
        if segue.identifier! == "closePosition" {
            if let item = simuPos {
                if let secondViewController = segue.destinationController as? SimuOrderViewController {
                    secondViewController.action = "Close"
                    secondViewController.simuPos = item
                }
            }
        }
        
        if segue.identifier! == "simuResult" {
            if let item = simuPos {
                if let secondViewController = segue.destinationController as? SimuResultViewController {
                    secondViewController.simuPos = item
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == "closePosition" {
            if let item = simuPos {
                if item.quantity == 0 {
                    return false
                }
            }
        }
         return true
    }
    
    func passDataBack (action: String, simuOrd: SimuOrder) {
        do {
            try simuDB.updatePosition(simuPos: simuPos!, simuOrd: simuOrd)
            updateUI()
            loadPerfData()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    @IBAction func nextDate(_ sender: NSButton) {
        if let sQuote = chartTV.nextDay() {
            do {
                simuPos?.stopLoss = stopLoss.doubleValue
                try simuDB.updatePosition(simuPos: simuPos!, sQuote: sQuote)
                updateUI()
                if simuDB.checkStop(simuPos: simuPos!, sQuote: sQuote) {
                    stopLoss.backgroundColor = .orange
                    if exitOnStop.state == NSControl.StateValue.on {
                        let msg = try simuDB.closePosition(simuPos: simuPos!, sQuote: sQuote)
                        dspAlert(text: msg)
                        updateUI()
                        loadPerfData()
                    }
                    
                } else {
                    stopLoss.backgroundColor = .white
                }
            } catch let error as SQLiteError {
                dspAlert(text: error.description)
            } catch let error {
                dspAlert(text: "Other Error \(error)")
            }
            
            if let chartTVIndex = chartTVIndex {
                _ = chartTVIndex.nextDay()
            }
        }

    }
}


extension SimuViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataArray?.count ?? 0
    }

    func tableView(tableView: NSTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 171.0
    }
}

extension SimuViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let perfPositionCell = "perfPositionCell"
        static let perfAmountCell = "perfAmountCell"
        static let perfPeriodCell = "perfPeriodCell"
        static let perfResultCell = "perfResultCell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellIdentifier: String = ""
        
        guard let item = dataArray?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = CellIdentifiers.perfPositionCell
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = item.operationType
                return cell
            }
            
        } else if tableColumn == tableView.tableColumns[1] {
            cellIdentifier = CellIdentifiers.perfAmountCell
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? AmountTableCellView {
                cell.investedAmt.stringValue = Calculate.formatNumber(2, item.investedAmount)
                cell.estimatedAmt.stringValue = Calculate.formatNumber(2, item.estimatedAmount)
                return cell
            }
            
        } else if tableColumn == tableView.tableColumns[2] {
            cellIdentifier = CellIdentifiers.perfPeriodCell
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? PeriodTableCellView {
                cell.dateFrom.stringValue = CDate.formatDate(item.dateFrom, "dd/MM/YY")
                cell.dateTo.stringValue = CDate.formatDate(item.dateTo, "dd/MM/YY")
                return cell
            }
            
        } else if tableColumn == tableView.tableColumns[3] {
            cellIdentifier = CellIdentifiers.perfResultCell
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? ResultTableCellView {
                cell.result.stringValue = Calculate.formatNumber(2, item.result)
                cell.varPer.stringValue = Calculate.formatNumber(2, item.varPer) + "%"
                if item.result > 0 {
                    cell.varPer.backgroundColor = .green
                    cell.varPer.textColor = .green
                } else if item.result < 0 {
                    cell.varPer.backgroundColor = .red
                    cell.varPer.textColor = .red
                } else {
                    cell.varPer.backgroundColor = .white
                    cell.varPer.textColor = .black
                }
                return cell
            }
        }
        return nil
    }
}

extension SimuViewController : NSTextFieldDelegate {

    func controlTextDidChange(_ notification: Notification) {

        if stopLoss.doubleValue != 0.0 {
        
            if simuPos?.positionType == "Long" && stopLoss.doubleValue > lastQuote.doubleValue {
                dspAlert(text: "Stop Loss must be less than last Quote")
                stopLoss.doubleValue = simuPos!.stopLoss
                return
            } else if simuPos?.positionType == "Short" && stopLoss.doubleValue < lastQuote.doubleValue {
                dspAlert(text: "Stop Loss must be greater than last Quote")
                stopLoss.doubleValue = simuPos!.stopLoss
                return
            }
        }
        
        do {
            simuPos?.stopLoss = stopLoss.doubleValue
            try simuDB.simuPosUpdate(simuPos: simuPos!)
            updateUI()
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
}
