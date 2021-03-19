//
//  DINAPOLI.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class DINAPOLI {
    /************************ Detrended Oscillatotr ***************************/
    static func detOsc(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let sma = AVG.sma(avg: avg, cQuote: cQuote)
        let close = CQuote.getClose(cQuote: cQuote)
        return CQuote.subDict(dict1: close, dict2: sma)
    }
    
    static func dMACD(avg1: Double, avg2: Double, cQuote: [StockQuote]) -> [Date : Double] {
        let ema1 = AVG.ema2(avg: avg1, dict: CQuote.getClose(cQuote: cQuote))
        let ema2 = AVG.ema2(avg: avg2, dict: CQuote.getClose(cQuote: cQuote))
        return CQuote.subDict(dict1: ema1, dict2: ema2)
    }
    
    static func mSTOC(avg1: Int, avg2: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let fastK = Stochastics.stochastics(avg: avg1, cQuote: cQuote)
        return AVG.mma(avg: avg2, dict: fastK)
    }
}
