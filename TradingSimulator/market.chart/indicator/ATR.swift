//
//  ATR.swift
//  Trading
//
//  Created by Maroun Achille on 26/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class ATR {
    
    static func atr(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var atrDict = [Date: Double] ()
        var first = true, firstAtr = true
        var j: Int = 0
        var dailyAtr = 0.0, last = 0.0, atrValue = 0.0
        
        for sQuote in cQuote {
            if (firstAtr) {
                dailyAtr = sQuote.high - sQuote.low
                firstAtr = false
            } else {
                dailyAtr = max(sQuote.high , last) - min(sQuote.low ,last)
            }
            if (first) {
                j = (j  + 1 ) % avg
                atrValue += dailyAtr
                
                if (j == 0) {
                    atrValue = atrValue / Double(avg)
                    atrDict[sQuote.dateQuote] = atrValue
                    first = false
                }
            } else {
                atrValue = ( atrValue * Double( (avg - 1) ) + dailyAtr ) / Double(avg)
                atrDict[sQuote.dateQuote] = atrValue
            }
            last = sQuote.close
        }
        return atrDict
    }
}
