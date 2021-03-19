//
//  MACD.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class MACD {

/*****************  MOVING AVERAGE CONVERGENCE DIVERGENCE (MACD) ****************/

    static func macd(shortAvg: Int, longAvg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let ema1 = AVG.ema(avg: shortAvg, cQuote: cQuote)
        let ema2 = AVG.ema(avg: longAvg, cQuote: cQuote)
        return CQuote.subDict(dict1: ema1, dict2: ema2)
    }
    
    static func macdS(shortAvg: Int, longAvg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let sma1 = AVG.sma(avg: shortAvg, cQuote: cQuote)
        let sma2 = AVG.sma(avg: longAvg, cQuote: cQuote)
        return CQuote.subDict(dict1: sma1, dict2: sma2)
    }
    
    static func macdH(shortAvg: Int, longAvg: Int, histAvg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let ema1 = AVG.ema(avg: shortAvg, cQuote: cQuote)
        let ema2 = AVG.ema(avg: longAvg, cQuote: cQuote)
        let macd = CQuote.subDict(dict1: ema1, dict2: ema2)
        let ema3 =  AVG.ema(avg: histAvg, dict: macd)
        return CQuote.subDict(dict1: macd, dict2: ema3)
    }
    
    static func macdE(shortAvg: Int, longAvg: Int, histAvg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let ema1 = AVG.ema(avg: shortAvg, cQuote: cQuote)
        let ema2 = AVG.ema(avg: longAvg, cQuote: cQuote)
        let macd = CQuote.subDict(dict1: ema1, dict2: ema2)
        return AVG.ema(avg: histAvg, dict: macd)
    }
    
    static func macdH(shortAvg: Int, longAvg: Int, histAvg: Int, dict: [Date: Double]) -> [Date : Double] {
        let ema1 = AVG.ema(avg: shortAvg, dict: dict)
        let ema2 = AVG.ema(avg: longAvg, dict: dict)
        let macd = CQuote.subDict(dict1: ema1, dict2: ema2)
        let ema3 =  AVG.ema(avg: histAvg, dict: macd)
        return CQuote.subDict(dict1: macd, dict2: ema3)
    }
    
}

