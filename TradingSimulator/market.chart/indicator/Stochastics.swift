//
//  Stochastics.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class Stochastics {

    static func stochastics(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var kDict = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var high = 0.0, low = 0.0, close = 0.0, k = 0.0
        var arHigh = Array(repeating: 0.0, count: avg)
        var arLow = Array(repeating: 0.0, count: avg)
        
        for sQuote in cQuote {
            close = sQuote.close
            arHigh[j] = sQuote.high
            arLow[j] = sQuote.low
            
            j = (j  + 1 ) % avg
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                
                high = -9999999999.0
                low = 9999999999.0
                
                for index in 0..<avg {
                    high = max(high, arHigh[index])
                    low = min(low,  arLow[index])
                }
                
                k = 100.0 * ( ( close - low ) / (high - low) )
                kDict[sQuote.dateQuote] = k
            }
        }
        return kDict
    }
    
    static func stochastics(avg: Int, dict: [Date: Double]) -> [Date : Double] {
        
        var kDict = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var high = 0.0, low = 0.0, close = 0.0, k = 0.0
        var arHigh = Array(repeating: 0.0, count: avg)
        var arLow = Array(repeating: 0.0, count: avg)
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            close = element
            arHigh[j] = element
            arLow[j] = element
            
            j = (j  + 1 ) % avg
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                
                high = -9999999999.0
                low = 9999999999.0
                
                for index in 0..<avg {
                    high = max(high, arHigh[index])
                    low = min(low,  arLow[index])
                }
                
                k = 100.0 * ( ( close - low ) / (high - low) )
                kDict[key] = k
            }
        }
        return kDict
    }
    
}
