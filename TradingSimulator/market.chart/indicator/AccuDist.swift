//
//  Indicator.swift
//  Trading
//
//  Created by Maroun Achille on 23/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class AccuDist  {
    
    static func accuDist(cQuote: [StockQuote]) -> [Date : Double] {
    
        var accuDistDict = [Date: Double] ()
        var accuDistVakue: Double = 0.0
        var accuDistLastVakue: Double = 0.0
        
        for sQuote in cQuote {
            if sQuote.volume == 0 {
                continue
            }
            accuDistVakue = ( ( (sQuote.close - sQuote.low) - (sQuote.high - sQuote.close) ) / (sQuote.high - sQuote.low) ) * sQuote.volume
    
            accuDistVakue += accuDistLastVakue
            accuDistDict[sQuote.dateQuote] = accuDistVakue
            accuDistLastVakue = accuDistVakue
        }
        return accuDistDict ;
    }
    
    
    
    
}
