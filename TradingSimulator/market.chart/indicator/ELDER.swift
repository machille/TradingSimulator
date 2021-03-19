//
//  ELDER.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class ELDER {

/************* FORCE INDEX  *************/
    static func forceIndex(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var fdxDict = [Date: Double] ()
        var lastClose = -1.0, forceIndex = 0.0
        
        for sQuote in cQuote {
            if lastClose != -1.0 {
                forceIndex = (sQuote.close - lastClose) * sQuote.volume
                fdxDict[sQuote.dateQuote] = forceIndex
            }
            lastClose = sQuote.close
        }
        return AVG.ema(avg: avg, dict: fdxDict)
    }
    
/*** bull power = Hight - EMA ***/
    static func bullPower(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let ema = AVG.ema(avg: avg, cQuote: cQuote)
        let high = CQuote.getHigh (cQuote: cQuote)
        return CQuote.subDict(dict1: high, dict2: ema)
    }
    
/*** Bear Power = Low - EMA ***/
    static func bearPower(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let ema = AVG.ema(avg: avg, cQuote: cQuote)
        let low = CQuote.getLow (cQuote: cQuote)
        return CQuote.subDict(dict1: low, dict2: ema)
    }
    
/*   EMA rising & MACD-Histogram rising (especially below zero) = Impulse is green, bullish.
     Shorting prohibited, buying or standing aside permitted.
     
     EMA falling & MACD-Histogram falling (especially above zero) = Impulse is red, bearish.
     Buying prohibited, shorting or standing aside permitted.
     
     EMA rising & MACD-Histogram falling = Impulse is blue, neutral. Nothing is prohibited.
     
     EMA falling & MACD-Histogram rising = Impulse is blue, neutral. Nothing is prohibited.
*/
    static func impulse(avg: Int, shortAvg: Int, longAvg: Int, histAvg: Int, dict: [Date: Double]) -> [Date : Double] {
    
        var impulseDict = [Date: Double] ()
        var macdhValue1 = 0.0 , macdhValue2 = 0.0, emaValue1 = 0.0, emaValue2 = 0.0, result = 0.0
        var first = true
        
        let macdh = MACD.macdH(shortAvg: shortAvg, longAvg: longAvg, histAvg: histAvg, dict: dict)
        let ema = AVG.ema(avg: avg,  dict: dict)
        
        let tempDict = macdh.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
         
            if first {
                macdhValue1 = element
                if let testValue = ema[key] {
                    emaValue1 = testValue
                    first = false
                }
            } else {
                macdhValue2 = element
                if let testValue = ema[key] {
                    emaValue2 = testValue
                    if  ( (macdhValue2 >  macdhValue1) && (emaValue2 > emaValue1)) {
                        result = 1.0;  // EMA rising & MACD-Histogram rising = Impulse is green, bullish.
                    } else if  ( (macdhValue2 <  macdhValue1) && (emaValue2 < emaValue1)) {
                        result = -1.0;  // EMA falling & MACD-Histogram falling = Impulse is red, bearish.
                    } else {
                        result = 0.0;  //  EMA rising & MACD-Histogram falling or EMA falling & MACD-Histogram rising = Impulse is blue, neutral. Nothing is prohibited.
                    }
                    impulseDict[key] = result
                    macdhValue1 = macdhValue2
                    emaValue1 = emaValue2
                }
            }
        }
        return impulseDict
    }
    
    static func impulse(avg: Int, shortAvg: Int, longAvg: Int, histAvg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        return impulse(avg: avg, shortAvg: shortAvg, longAvg: longAvg, histAvg: histAvg, dict: CQuote.getClose(cQuote: cQuote))
    }
    
}
