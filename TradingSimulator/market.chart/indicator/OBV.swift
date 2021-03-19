//
//  OBV.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class OBV {
/**
 <h1>Calculation </h1>
 *
 OBV is calculated by adding the day's volume to a running cumulative total when the security's price closes up, and subtracts the volume when it closes down.
 For example,
 * if today the closing price is greater than yesterday's closing price, then the new
 OBV = Yesterday's OBV + Today's Volume
 
 If today the closing price is less than yesterday's closing price, then the new
 OBV = Yesterday's OBV - Today's Volume
 
 If today the closing price is equal to yesterday's closing price, then the new
 OBV = Yesterday's OBV
 *
 * Use
 The idea behind the OBV indicator is that changes in the OBV will precede price
 changes. A rising volume can indicate the presence of smart money flowing into a
 security. Then once the public follows suit, the security's price will likewise rise.
 Like other indicators, the OBV indicator will take a direction. A rising (bullish)
 OBV line indicates that the volume is heavier on up days. If the price is likewise
 rising, then the OBV can serve as a confirmation of the price uptrend. In such a
 case, the rising price is the result of an increased demand for the security, which
 is a requirement of a healthy uptrend. However, if prices are moving higher while
 the volume line is dropping, a negative divergence is present. This divergence
 suggests that the uptrend is not healthy and should be taken as a warning signal
 that the trend will not persist. The numerical value of OBV is not important,
 but rather the direction of the line. A user should concentrate on the OBV trend
 and its relationship with the security's price.
 **/

    static func obv(cQuote: [StockQuote]) -> [Date : Double] {
        var obvDict = [Date: Double] ()
        var obvValue = 0.0, lastClose = -1.0
    
        for sQuote in cQuote {
            if lastClose != -1.0 {
                if sQuote.close >  lastClose {
                    obvValue += sQuote.volume
                } else if sQuote.close <  lastClose {
                    obvValue -= sQuote.volume
                }
                obvDict[sQuote.dateQuote] = obvValue
            }
            lastClose = sQuote.close
        }
        
        return obvDict
    }
}
