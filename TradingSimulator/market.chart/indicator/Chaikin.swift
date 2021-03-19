//
//  Chaikin.swift
//  Trading
//
//  Created by Maroun Achille on 05/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class Chaikin {
    
    static func chaikinMF(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var dictMF = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var sumAd = 0.0, sumVolume = 0.0
        var arAd = Array(repeating: 0.0, count: avg)
        var arVolume = Array(repeating: 0.0, count: avg)
        
        for sQuote in cQuote {
            if sQuote.volume == 0 {
                continue
            }
            arAd[j] = ( ( (sQuote.close - sQuote.low) - (sQuote.high - sQuote.close) ) / (sQuote.high - sQuote.low) ) * sQuote.volume
            arVolume[j] = sQuote.volume
            j = (j  + 1 ) % avg
            
            if (j == 0) && (first) {
                first = false
            }
            
            if !first {
                
                for arAdValue in arAd {
                    sumAd += arAdValue
                }
                
                for arVolumeValue in arVolume {
                    sumVolume += arVolumeValue
                }
                
                dictMF[sQuote.dateQuote] = sumAd / sumVolume
                sumAd = 0.0
                sumVolume = 0.0
            }
        }
        return dictMF
    }
    /******************************** Chaikin Oscillator ************************************/
    
    static func chaikinOSC(avg1: Int, avg2: Int,  cQuote: [StockQuote]) -> [Date : Double] {
        
        let accuDist = AccuDist.accuDist(cQuote: cQuote)
        let ema3 = AVG.ema(avg: avg1, dict: accuDist )
        let ema10 = AVG.ema(avg: avg2 ,dict: accuDist )
        return CQuote.subDict(dict1: ema3 , dict2: ema10 )
    }
}
