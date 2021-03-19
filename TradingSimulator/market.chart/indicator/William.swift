//
//  William.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class William {
    
    static func williamAD(cQuote: [StockQuote]) -> [Date : Double] {
        var wADDict = [Date: Double] ()
        var lastClose = -1.0
        var trh = 0.0,  trl = 0.0
        var todayAD = 0.0, wad = 0.0

        for sQuote in cQuote {
            if lastClose != -1.0 {
                trh = max(lastClose, sQuote.high)
                trl = min(lastClose, sQuote.low)
                
                if sQuote.close == lastClose {
                    todayAD = 0.0
                }
                if sQuote.close > lastClose {
                    todayAD = sQuote.close - trl
                } else {
                    todayAD = sQuote.close - trh
                }
                wad += todayAD
                wADDict[sQuote.dateQuote] =  wad
            }
            lastClose = sQuote.close
        }
        return wADDict
    }
    
     static func williamR (avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var wrDict = [Date: Double] ()
        var first = true
        var j = 0
        var high = 0.0, low = 0.0
        var wr = 0.0
        
        var arHigh = Array(repeating: 0.0, count: avg)
        var arLow = Array(repeating: 0.0, count: avg)
        
        for sQuote in cQuote {
            arHigh[j] = sQuote.high
            arLow[j] = sQuote.low
            
            j = (j  + 1 ) % avg
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                high = -9999999999.0
                low = 9999999999.0
                
                for index in 0..<avg  {
                    high = max(high, arHigh[index])
                    low = min(low,  arLow[index])
                }
                wr = ((high - sQuote.close) / (high - low ) )  * -100.0
                wrDict[sQuote.dateQuote] =  wr
            }
        }
        return wrDict
    }
        
}
