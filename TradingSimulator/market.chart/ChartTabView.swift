//
//  ChartTabView.swift
//  Trading
//
//  Created by Maroun Achille on 18/06/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartTabView: NSTabView {

    private let header = "ChartTabView Init Chart View"
    private var chartCtrl: ChartControllerView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tabViewType = .rightTabsBezelBorder
        do {
            for chartD in try ChartSettingDB.instance.getChartSelect() {
                let tabChart = chartViewItem()
                tabChart.setChartDraw(chartD: chartD)
                addTabViewItem(tabChart)
            }
        } catch let error as SQLiteError {
            Message.messageAlert(header + " Chart Settings", text: error.description)
        } catch let error {
            Message.messageAlert(header + " Chart Settings", text: "Other Error \(error)")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func setStockHist(histQuote: HistoricQuote?, stockId: String) {
        for tabItem in tabViewItems {
            if let tabChart = tabItem as? chartViewItem {
                tabChart.setStockHist(histQuote: histQuote, stockId: stockId)
            }
        }
    }

    func addOrderArrow(date: Date, action: String, type: String) {
         for tabItem in tabViewItems {
            if let tabChart = tabItem as? chartViewItem {
                tabChart.addOrderArrow(date: date, action: action, type: type)
            }
        }
    }
    
    ///* is for simulation */
    func setDateSimul(dateSimu: Date) {
        for tabItem in tabViewItems {
            if let tabChart = tabItem as? chartViewItem {
                tabChart.setDateSimul(dateSimu: dateSimu)
            }
        }
    }
    
    func setFlagSimul() {
        for tabItem in tabViewItems {
            if let tabChart = tabItem as? chartViewItem {
                tabChart.setFlagSimul()
            }
        }
    }

    func initSimul() -> StockQuote? {
        for tabItem in tabViewItems {
            if let tabChart = tabItem as? chartViewItem {
                if let chartCtrl = tabChart.getChartParam() {
                    if chartCtrl.chartD.type == ChartType.Daily.rawValue {
                        self.chartCtrl = chartCtrl
                        if let dateMax = chartCtrl.dateMax {
                            return chartCtrl.getStockQuote(at: dateMax)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func  refresh() {
        for tabItem in tabViewItems {
            if let tabChart = tabItem as? chartViewItem {
                tabChart.refresh()
            }
        }
    }
    
    func nextDay() -> StockQuote? {
        if let chartCtrl = chartCtrl {
            if let dnextD = chartCtrl.nextDate() {
                for tabItem in tabViewItems {
                    if let tabChart = tabItem as? chartViewItem {
                        tabChart.setDateSimul(dateSimu: dnextD)
                        tabChart.refresh()
                    }
                }
                return chartCtrl.getStockQuote(at: dnextD)
            }
        }
        return nil
    }
    ///* end simulation */
}

class chartViewItem: NSTabViewItem {
    private var chartD: ChartDrawing?
    private var chartV: ChartControllerView?
    
    func setChartDraw(chartD: ChartDrawing) {
        self.label = chartD.id
        self.chartD = chartD
        self.toolTip = chartD.desc
        chartV = ChartControllerView()
        if let chartV = chartV {
            chartV.initChartD(chartD: chartD)
            view = chartV
        }
    }
    
    func setStockHist(histQuote: HistoricQuote?, stockId: String) {
        if let chartV = chartV {
            chartV.setStockHist(histQuote: histQuote, stockId: stockId)
            chartV.refresh()
        }
    }
    
    func setDateSimul(dateSimu: Date) {
        if let chartV = chartV {
            chartV.dateSimul = dateSimu
        }
    }
    
    func setFlagSimul() {
        if let chartV = chartV {
            chartV.isSimu = true
        }
    }
    
    func addOrderArrow(date: Date, action: String, type: String) {
        if let chartV = chartV {
            chartV.addOrderArrow(date: date, action: action, type: type)
        }
    }
    
    
    func refresh() {
        if let chartV = chartV {
            chartV.refresh()
        }
    }
    
    func getChartParam() -> ChartControllerView? {
        if let chartV = chartV {
            return chartV
        } else {
            return nil
        }
    }
}
