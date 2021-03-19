//
//  CQuote.swift
//  Trading
//
//  Created by Maroun Achille on 23/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class CQuote {
    
    static func getClose(cQuote: [StockQuote]) -> [Date : Double] {
        return cQuote.reduce(into: [Date : Double] () ) {
            $0[$1.dateQuote] = $1.close
        }
    }

    static func getHigh(cQuote: [StockQuote]) -> [Date : Double] {
        return cQuote.reduce(into: [Date : Double] () ) {
            $0[$1.dateQuote] = $1.high
        }
    }

    static func getLow(cQuote: [StockQuote]) -> [Date : Double] {
        return cQuote.reduce(into: [Date : Double] () ) {
            $0[$1.dateQuote] = $1.low
        }
    }

    static func getOpen(cQuote: [StockQuote]) -> [Date : Double] {
        return cQuote.reduce(into: [Date : Double] () ) {
            $0[$1.dateQuote] = $1.open
        }
    }
    
    static func getVolume(cQuote: [StockQuote]) -> [Date : Double] {
        return cQuote.reduce(into: [Date : Double] () ) {
            $0[$1.dateQuote] = $1.volume
        }
    }
    
    static func addDict(dict1: [Date : Double] , dict2: [Date : Double]) -> [Date : Double]  {
        return calDict(oper: "ADD", dict1: dict1, dict2: dict2)
    }
    
    static func subDict(dict1: [Date : Double] , dict2: [Date : Double]) -> [Date : Double]  {
        return calDict(oper: "SUB", dict1: dict1, dict2: dict2)
    }
    
    static func mltDict(dict1: [Date : Double] , dict2: [Date : Double]) -> [Date : Double]  {
        return calDict(oper: "MLT", dict1: dict1, dict2: dict2)
    }
    
    static func divDict(dict1: [Date : Double] , dict2: [Date : Double]) -> [Date : Double]  {
        return calDict(oper: "DIV", dict1: dict1, dict2: dict2)
    }
    
    static func calDict (oper: String, dict1: [Date : Double] , dict2: [Date : Double]) -> [Date : Double] {
    
        var difDict = [Date: Double] ()
        for (date1, value1) in dict1 {
            if let value2 = dict2[date1] {
                switch oper {
                case "ADD" :
                    difDict[date1] = value1 + value2
                case "SUB" :
                    difDict[date1] = value1 - value2
                case "DIV" :
                    difDict[date1] = value1 / value2
                case "MLT" :
                    difDict[date1] = value1 * value2
                default:
                    difDict[date1] = 0.0
                }
            }
        }
        return difDict
    }
    
    static func calDict2 (oper: String, dict: [Date : Double], calcValue: Double) -> [Date : Double] {
        
        var difDict = [Date: Double] ()
        
        for (key, element) in dict {
            switch oper {
            case "ADD" :
                difDict[key] = element + calcValue
            case "SUB" :
                difDict[key] = element - calcValue
            case "DIV" :
                difDict[key] = element / calcValue
            case "MLT" :
                difDict[key] = element * calcValue
            default:
                difDict[key] = 0.0
            }
        }
        return difDict
    }
    
    static func typicalPrice (cQuote: [StockQuote]) -> [Date : Double] {
    
        var typicalPrice = [Date: Double] ()
        for sQuote in cQuote {
            typicalPrice[sQuote.dateQuote] = (sQuote.close + sQuote.high + sQuote.low + sQuote.open) / 4
        }
        return typicalPrice
    }
    
    static func typicalPrice3 (cQuote: [StockQuote]) -> [Date : Double] {
        
        var typicalPrice = [Date: Double] ()
        for sQuote in cQuote {
            typicalPrice[sQuote.dateQuote] = (sQuote.close + sQuote.high + sQuote.low ) / 3
        }
        return typicalPrice
    }
}
