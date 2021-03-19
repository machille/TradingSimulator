//
//  AROON.swift
//  Trading
//
//  Created by Maroun Achille on 24/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class AROON {
    
    static func aroonUp(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var aroonUpDict = [Date: Double] ()
        
        var j: Int = 1
        var first = true
        var maxPosition:  Int = 0
        var position: Int = 0
        
        var trQuote: Double = 0.0
        var maxQuote: Double = 0.0
        
        //       var arPrice = [Double]()
        var arQuote = Array(repeating: 0.0, count: avg + 1)
        
        for sQuote in cQuote {
            
            if (first) {
                arQuote[j] = sQuote.high
                j = (j  + 1 ) % (avg  + 1);
                if  j == 0 {
                    first = false
                }
            } else {
                arQuote[0...avg-1] = arQuote[1...arQuote.count - 1]
                //               System.arraycopy(arPrice, 1, arPrice, 0, arPrice.length-1);
                arQuote[avg] = sQuote.high
                
                maxQuote = 0.0
                for (index, element) in arQuote.enumerated() {
                    maxQuote = max(maxQuote , element)
                    if maxQuote == element {
                        maxPosition = index + 1
                    }
                }
                
                position = (avg + 1) - maxPosition
                trQuote =  Double(100 * (avg - position ) / avg)
                aroonUpDict[sQuote.dateQuote] = trQuote
            }
        }
        return aroonUpDict
    }
    
    static func aroonDown(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var aroonDownDict = [Date: Double] ()
        
        var j: Int = 1
        var first = true
        var minPosition: Int = 0
        var position: Int = 0
        
        var trQuote: Double = 0.0
        var minQuote: Double = 0.0
        
        var arQuote = Array(repeating: 0.0, count: avg + 1)
        
        for sQuote in cQuote {
            
            if (first) {
                arQuote[j] = sQuote.low
                j = (j  + 1 ) % (avg  + 1);
                if  j == 0 {
                    first = false
                }
            } else {
                arQuote[0...avg-1] = arQuote[1...arQuote.count - 1]
                arQuote[avg] = sQuote.low
                
                minQuote = 9999999999.0
                for (index, element) in arQuote.enumerated() {
                    minQuote = min(minQuote , element)
                    if minQuote == element {
                        minPosition = index + 1
                    }
                }
                
                position = (avg + 1) - minPosition
                trQuote =  Double(100 * (avg - position ) / avg)
                aroonDownDict[sQuote.dateQuote] = trQuote
            }
        }
        return aroonDownDict
    }
    
    
    static func aroonOsc(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        return CQuote.subDict(dict1: aroonUp(avg: avg, cQuote: cQuote), dict2: aroonDown(avg: avg, cQuote: cQuote) )
    }
    

}
