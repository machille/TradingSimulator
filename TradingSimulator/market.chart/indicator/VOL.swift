//
//  VOL.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class VOL {
    static func vol(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {

        var hvolDict = [Date: Double] ()
        
        var lastClose = -1.0, vol = 0.0, smaVol = 0.0 , mdvol = 0.0, devVol = 0.0, hvol = 0.0
        var j = 0
        var first = true
        let avgD = Double(avg - 1)
        
        let year = 365.0, week = 7.0
        let variant = sqrt(year / week)

        var arVol = Array(repeating: 0.0, count: avg-1)
        
        for sQuote in cQuote {
            if lastClose > -1.0 {
                vol = log(sQuote.close / lastClose)
                
                arVol[j] = vol
                j = (j  + 1) % (avg - 1)
                
                if j == 0 && first {
                    first = false
                }
                
                if !first {
                    
                    for arVolValue in arVol {
                        smaVol += arVolValue
                    }
                    smaVol = smaVol / Double(avgD)
                    
                    for arVolValue in arVol {
                        mdvol +=  pow( (arVolValue - smaVol), 2.0)
                    }
                    devVol = sqrt(mdvol / avgD)
                    hvol = devVol * variant * 100.0
    
                    hvolDict[sQuote.dateQuote] = hvol
                    smaVol  = 0.0
                    mdvol = 0.0
                }
            }
            lastClose = sQuote.close
        }
        return Bollinger.bollingerDev(avg: avg, dev: 1.0, dict: hvolDict)
    }
    
    static func rVol(hvolc: Int, hvoll: Int, cQuote: [StockQuote]) -> [Date : Double] {
        return CQuote.divDict(dict1: vol(avg: hvolc, cQuote: cQuote), dict2: vol(avg: hvoll, cQuote: cQuote))
    }
}
