//
//  CCI.swift
//  Trading
//
//  Created by Maroun Achille on 05/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class CCI {
    
    static func cci(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var dictCCI = [Date: Double] ()
        var j: Int = 0, l:Int = 0
        var first = true
        
        var trAvg  = 0.0, mdAvg = 0.0
        var arAvg = Array(repeating: 0.0, count: avg)
        let avgd = Double(avg)
        
        for sQuote in cQuote {
            
            arAvg[j] = (sQuote.close + sQuote.low + sQuote.high) / 3.0
            j = (j  + 1 ) % avg
            
            if (j == 0) && (first) {
                first = false
            }
            
            if !first {
                for arAvgValue in arAvg {
                    trAvg  +=  arAvgValue
                }
                trAvg = trAvg / avgd
                
                for arAvgValue in arAvg {
                    mdAvg  +=  abs(trAvg - arAvgValue)
                }
                mdAvg = mdAvg / avgd
                
                dictCCI[sQuote.dateQuote] = ( arAvg[l] - trAvg ) / (0.015 * mdAvg)
                trAvg = 0.0
                mdAvg = 0.0
            }
            l = (l  + 1 ) % avg
        }
        return dictCCI
    }
}
