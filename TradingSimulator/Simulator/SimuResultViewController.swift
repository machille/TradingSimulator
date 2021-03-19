//
//  SimuResultViewController.swift
//  Trading
//
//  Created by Maroun Achille on 01/05/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class SimuResultViewController: NSViewController {
    
    let question = "Simulator Results"
    
    @IBOutlet weak var stockName: NSTextField!
    
    @IBOutlet weak var startCapital: NSTextField!
    @IBOutlet weak var actualCapital: NSTextField!
    @IBOutlet weak var startDate: NSTextField!
    @IBOutlet weak var actualDate: NSTextField!

    @IBOutlet weak var longSum: NSTextField!
    @IBOutlet weak var longCount: NSTextField!
    @IBOutlet weak var shortSum: NSTextField!
    @IBOutlet weak var shortCount: NSTextField!

    @IBOutlet weak var winnersAvg: NSTextField!
    @IBOutlet weak var winnersMax: NSTextField!
    @IBOutlet weak var winnersSum: NSTextField!
    @IBOutlet weak var winnersCount: NSTextField!
    @IBOutlet weak var losersAvg: NSTextField!
    @IBOutlet weak var losersMax: NSTextField!
    @IBOutlet weak var losersSum: NSTextField!
    @IBOutlet weak var losersCount: NSTextField!

    @IBOutlet weak var maxHoldPeriod: NSTextField!
    @IBOutlet weak var tradeCount: NSTextField!
    @IBOutlet weak var winnerPer: NSTextField!
    @IBOutlet weak var minHoldPeriod: NSTextField!
    @IBOutlet weak var commission: NSTextField!
    @IBOutlet weak var netProfit: NSTextField!

    let selectStr = """
        TOTAL_RESULT, TOTAL_COM, TRADE_COUNT, MAX_PERIOD_HOLD, MIN_PERIOD_HOLD,
        LONG_RESULT, LONG_NB, SHORT_RESULT, SHORT_NB,
        WINNER_TOTAL, WINNER_MAX, WINNER_NB, WINNER_PER, WINNER_AVG,
        LOSERS_TOTAL, LOSERS_MAX, LOSERS_NB, LOSERS_AVG
    """

    let selectOpn = """
        OPERATION_TYPE, INVESTED_AMOUNT, ESTIMED_AMOUNT, SQUANTITY,
        GLQUANTITY, RESULT, COMMISSION, DAYS_NUMBER
    """
    
    private var trDB, opDB: TableRowDB!
    
    var simuPos: SimuPosition?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        trDB = TableRowDB(columns: (selectStr.components(separatedBy: ",")).map {($0.filter { !$0.isNewline }).trimmingCharacters(in: .whitespaces) }, tableName: "VSIMU3")
        opDB = TableRowDB(columns: (selectOpn.components(separatedBy: ",")).map {($0.filter { !$0.isNewline }).trimmingCharacters(in: .whitespaces) }, tableName: "VSIMU4")
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }
    
    private func updateUI() {
        if !isViewLoaded {
            return
        }
        guard let simuPos = simuPos else {
            dspAlert(text: "No Stock Id found")
            return
        }
        do {
           
            stockName.stringValue = simuPos.stockName
            trDB.setWhere(whereExpr: "SIMU_ID = \(simuPos.simuId)")
            try trDB.readTable()
            
            startCapital.doubleValue = simuPos.startBalance
            actualCapital.doubleValue = simuPos.actualBalance
            startDate.stringValue = CDate.formatDate(simuPos.startDate, "dd/MM/YYYY")
            actualDate.stringValue = CDate.formatDate(simuPos.lastDate, "dd/MM/YYYY")
            
            var longNB = 0.0, longResult = 0.0, shortNB = 0.0, shortResult = 0.0
            var winnerTotal = 0.0, winnerNB = 0.0, losersTotal = 0.0, losersNB = 0.0
            var openCom = 0.0, period = 0.0
          
            if simuPos.quantity != 0  {
                opDB.setWhere(whereExpr: "SIMU_ID = \(simuPos.simuId)")
                try opDB.readTable()
                
                if opDB.getStringValue("OPERATION_TYPE") == "Long" {
                    longNB = 1
                    longResult = opDB.getDoubleValue("RESULT")
                } else {
                    shortNB = 1
                    shortResult = opDB.getDoubleValue("RESULT")
                }
                
                if opDB.getDoubleValue("RESULT") > 0 {
                    winnerNB = 1
                    winnerTotal = opDB.getDoubleValue("RESULT")
                } else {
                    losersNB = 1
                    losersTotal = opDB.getDoubleValue("RESULT")
                }
                
                openCom = opDB.getDoubleValue("COMMISSION")
                period = opDB.getDoubleValue("DAYS_NUMBER")
                
            }
                
                
            if trDB.rowCount < 1 {
                longSum.doubleValue = longResult
                longCount.doubleValue = longNB
                shortSum.doubleValue = shortResult
                shortCount.doubleValue = shortNB
                
                winnersSum.doubleValue = winnerTotal
                winnersCount.doubleValue = winnerNB
                
                losersSum.doubleValue =  losersTotal
                losersCount.doubleValue = losersNB
                
                winnersAvg.doubleValue = 0.0
                winnersMax.doubleValue = winnerTotal
                winnersSum.doubleValue = winnerTotal
                winnersCount.doubleValue = winnerNB
                
                losersAvg.doubleValue = 0.0
                losersMax.doubleValue = losersTotal
                losersSum.doubleValue = losersTotal
                losersCount.doubleValue = losersNB
                
                commission.doubleValue = openCom
                maxHoldPeriod.doubleValue = period
                tradeCount.doubleValue = longNB + shortNB
                if winnerTotal > 0 {
                    winnerPer.doubleValue = 100.0
                } else {
                    winnerPer.doubleValue = 0.0
                }
                minHoldPeriod.doubleValue = period
                
                netProfit.doubleValue =  longResult + shortResult
                commission.doubleValue = openCom
            
            } else {
            
                longSum.doubleValue = trDB.getDoubleValue("LONG_RESULT") + longResult
                longCount.doubleValue = trDB.getDoubleValue("LONG_NB") + longNB
                shortSum.doubleValue = trDB.getDoubleValue("SHORT_RESULT") + shortResult
                shortCount.doubleValue = trDB.getDoubleValue("SHORT_NB") + shortNB
                
                winnersAvg.doubleValue = trDB.getDoubleValue("WINNER_AVG")
                winnersMax.doubleValue = max(trDB.getDoubleValue("WINNER_MAX"), winnerTotal)
                winnersSum.doubleValue = trDB.getDoubleValue("WINNER_TOTAL") + winnerTotal
                winnersCount.doubleValue = trDB.getDoubleValue("WINNER_NB") + winnerNB
                
                losersAvg.doubleValue = trDB.getDoubleValue("LOSERS_AVG")
                losersMax.doubleValue = min(trDB.getDoubleValue("LOSERS_MAX"), losersTotal)
                losersSum.doubleValue = trDB.getDoubleValue("LOSERS_TOTAL") + losersTotal
                losersCount.doubleValue = trDB.getDoubleValue("LOSERS_NB") + losersNB

                if period != 0.0 {
                    maxHoldPeriod.doubleValue = max(trDB.getDoubleValue("MAX_PERIOD_HOLD"), period)
                } else {
                    maxHoldPeriod.doubleValue = trDB.getDoubleValue("MAX_PERIOD_HOLD")
                }
                
                tradeCount.doubleValue = trDB.getDoubleValue("TRADE_COUNT") + longNB + shortNB
                winnerPer.doubleValue = trDB.getDoubleValue("WINNER_PER")
                
                if period != 0.0 {
                    minHoldPeriod.doubleValue = min(trDB.getDoubleValue("MIN_PERIOD_HOLD"), period)
                } else {
                    minHoldPeriod.doubleValue = trDB.getDoubleValue("MIN_PERIOD_HOLD")
                }
            
                netProfit.doubleValue = trDB.getDoubleValue("TOTAL_RESULT") + longResult + shortResult
                commission.doubleValue = trDB.getDoubleValue("TOTAL_COM") + openCom
            }
        
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }

    @IBAction func close(_ sender: NSButton) {
         self.dismiss(self)
     }
    
}
