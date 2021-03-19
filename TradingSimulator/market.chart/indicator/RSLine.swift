//
//  RSLine.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class RSLine {
    static func rsline(avg: Int, iQuote: [StockQuote], cQuote: [StockQuote]) -> [Date : Double] {
        var rsDict = [Date: Double] ()
        
       
        let iClose = iQuote.reduce(into: [Date : Double] () ) {
            $0[CDate.stripTime(from: $1.dateQuote)] = $1.close
        }
        
        let cClose = cQuote.reduce(into: [Date : Double] () ) {
            $0[$1.dateQuote] = $1.close
        }

        var difDict =  [Date : Double] ()
        
        for (date1, value1) in cClose {
            if let value2 = iClose[CDate.stripTime(from: date1)] {
                if value2 != 0 {
                    difDict[date1] = value1 / value2 * 100.0
                }
            }
        }
        
        let smaPrMap = AVG.sma(avg: avg, dict: difDict)
    
        for (key, element) in smaPrMap {
            if let testValue = difDict[key] {
                if element != 0 {
                    rsDict[key] = ((testValue / element) - 1.0 ) * 100.0
                }
            }
        }
        
        
//        var prDict = CQuote.divDict(dict1: CQuote.getClose(cQuote: cQuote), dict2: CQuote.getClose(cQuote: iQuote))
//
//        for (key, element) in prDict {
//            prDict[key] = element * 100.0
//        }
//
//        let smaPrMap = AVG.sma(avg: avg, dict: prDict)
//        for (key, element) in smaPrMap {
//            if let testValue = prDict[key] {
//                rsDict[key] = ((testValue / element) - 1.0 ) * 100.0
//            }
//        }
        return rsDict
    }
}
