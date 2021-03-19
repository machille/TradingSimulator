//
//  StockQuoteHist.swift
//  Trading
//
//  Created by Maroun Achille on 31/12/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Foundation

class StockQuoteHist: StockQuote {
    
    var stockId: String
    
    init (stockId: String, dateQuote: Date, close: Double, open: Double, high: Double, low: Double, volume: Double) {
        self.stockId = stockId
        super.init(dateQuote: dateQuote, close: close, open: open, high: high, low: low, volume: volume)
    }
    
    public override var description: String {
        return "stockId \(stockId) dateQuote: \(dateQuote) Close: \(close) open: \(open) high: \(high) low: \(low) volume \(volume)"
    }
}
