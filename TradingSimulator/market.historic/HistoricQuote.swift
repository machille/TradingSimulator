//
//  HistoricQuote.swift
//  Trading
//
//  Created by Maroun Achille on 23/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class HistoricQuote {
    
    var id: String
    var name: String
    var type: String
    var marketPlace: String
    
    private var hist = [StockQuote]()
    private var histWeekly = [StockQuote]()
    
    var minDate: Date? {
        if hist.count > 0 {
            return  hist.first?.dateQuote
        } else {
            return nil
        }
    }
    
    var maxDate: Date? {
        if hist.count > 0 {
            return hist.last?.dateQuote
        } else {
            return nil
        }
    }
    
    var lastQuote: StockQuote? {
        if hist.count > 0 {
            return hist.last
        } else {
            return nil
        }
    }
    
    var lastVar: Double {
        if hist.count > 0 {
            let lastQuote = hist[hist.count-1].close
            let beforeLastQuote = hist[hist.count-2].close
            return Calculate.roundnumber( ((lastQuote - beforeLastQuote) /  lastQuote ) * 100.00, 2.0)
        } else {
            return 0.0
        }
    }
    
    init (id: String, name: String, type: String , marketPlace: String) {
        self.id = id
        self.name = name
        self.type = type
        self.marketPlace = marketPlace
    }
    
    func addQuote(dateQuote: Date, close: Double, open: Double, high: Double, low: Double, volume: Double) {
        let sQuote: StockQuote = StockQuote(dateQuote: dateQuote, close: close, open: open, high: high, low: low, volume: volume)
        hist.append(sQuote)
    }
    
    func addQuote(sQuote: StockQuote) {
        hist.append(sQuote)
    }
    
    func  getHist(contain: String) -> [StockQuote] {
        if contain == ChartType.Weekly.rawValue {
            return getHistWeekly()
        } else {
            return hist
        }
    }
    
    func getHist(contain: String, from: Date , to: Date)  -> [StockQuote] {
        if contain == ChartType.Weekly.rawValue {
            return getHistWeekly().filter { $0.dateQuote > from && $0.dateQuote <= to}
        } else {
            return hist.filter { $0.dateQuote > from && $0.dateQuote <= to}
        }
    }
    
    func nextDate(contain: String, nDate: Date ) -> Date? {
        let temp = getHist(contain: contain)
        var cpt = 0
        if let index = temp.firstIndex(where: { (item) -> Bool in item.dateQuote == nDate }) {
            cpt = index + 1
            if cpt < temp.count {
                return temp[cpt].dateQuote
            }
        }
        return nil
    }
    
    private func getHistWeekly() -> [StockQuote] {
        if histWeekly.count != 0 {
            return histWeekly
        }
        
        let calendar = Calendar.current
        var week: Int = 0
        var svweek: Int = 0
        var first = true
        
        var fpDateQuote: Date = Date()
        var fpClose : Double = 0.0
        var fpOpen  : Double = 0.0
        var fpHigh  : Double = -1.0
        var fpLow   : Double = 9999999999.0
        var fpVolume: Double = 0.0
        
        for sQuote in hist {
            week = calendar.component(.weekOfYear, from: sQuote.dateQuote)
            
            if (first) {
                fpOpen = sQuote.open
                fpDateQuote = sQuote.dateQuote
                svweek = week
                first = false
            }
            
            if week != svweek {
                let sQuoteWeek = StockQuote(dateQuote: fpDateQuote, close: fpClose, open: fpOpen, high: fpHigh, low: fpLow, volume: fpVolume)
                histWeekly.append(sQuoteWeek)
                
                fpOpen = sQuote.open
                fpDateQuote = sQuote.dateQuote
                svweek = week
                fpHigh = -1
                fpLow = 9999999999.0
                fpVolume = 0.0
            }
            
            fpDateQuote = sQuote.dateQuote
            fpClose = sQuote.close
            fpHigh = max(fpHigh, sQuote.high);
            fpLow = min(fpLow, sQuote.low);
            fpVolume += sQuote.volume
        }
        
        let sQuotelast = StockQuote(dateQuote: fpDateQuote, close: fpClose, open: fpOpen, high: fpHigh, low: fpLow, volume: fpVolume)
        histWeekly.append(sQuotelast)
        
        return histWeekly
    }
}
