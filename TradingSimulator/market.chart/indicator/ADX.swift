//
//  ADX.swift
//  Trading
//
//  Created by Maroun Achille on 26/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation


class ADX {
    
    static func diPlus(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var diPlusDict = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var high = 0.0, lastHigh = -1.0
        var low = 0.0, lastLow = -1.0
        var close = 0.0, lastClose = -1.0
        
        var dm = 0.0,  avgdm = 0.0
        var trueRange = 0.0, avgTrueRange = 0.0
        var di = 0.0
        
        for sQuote in cQuote {
            high = sQuote.high
            low = sQuote.low
            close = sQuote.close
            
            if lastHigh != -1.0  {
                dm = (high - lastHigh) > (lastLow - low) ? max((high - lastHigh), 0.0) : 0.0
                trueRange = max( max(abs(high - low),
                                     abs(high - lastClose) ),
                                     abs(low - lastClose) )
                
                if first {
                    avgdm += dm
                    avgTrueRange += trueRange
                    j = (j  + 1 ) % (avg  - 1)
                    if j == 0  {
                        di = (avgdm / avgTrueRange ) * 100.0
                        diPlusDict[sQuote.dateQuote] = di
                        first = false
                    }
                } else {
                    avgdm = ( avgdm - (avgdm / Double(avg) ) ) + dm
                    avgTrueRange = ( avgTrueRange - (avgTrueRange / Double(avg) ) ) + trueRange
                    di = (avgdm / avgTrueRange ) * 100.0
                    diPlusDict[sQuote.dateQuote] = di
                }
            }
            lastHigh = high
            lastLow = low
            lastClose = close
        }
        return diPlusDict
    }
    
    static func diMinus(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var diMinusDict = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var high = 0.0, lastHigh = -1.0
        var low = 0.0, lastLow = -1.0
        var close = 0.0, lastClose = -1.0
        
        var dm = 0.0,  avgdm = 0.0
        var trueRange = 0.0, avgTrueRange = 0.0
        var di = 0.0
        
        for sQuote in cQuote {
            high = sQuote.high
            low = sQuote.low
            close = sQuote.close
            
            if lastLow != -1.0  {
                dm = (lastLow - low) > (high - lastHigh) ? max((lastLow - low), 0.0) : 0.0
                trueRange = max( max(abs(high - low),
                                     abs(high - lastClose) ),
                                     abs(low - lastClose) )
                if (first) {
                    avgdm += dm
                    avgTrueRange += trueRange
                    j = (j  + 1 ) % (avg  - 1)
                    if j == 0  {
                        di = (avgdm / avgTrueRange ) * 100.0
                        diMinusDict[sQuote.dateQuote] = di
                        first = false
                    }
                } else {
                    avgdm = ( avgdm - (avgdm / Double(avg) ) ) + dm
                    avgTrueRange = ( avgTrueRange - (avgTrueRange / Double(avg) ) ) + trueRange
                    di = (avgdm / avgTrueRange ) * 100.0
                    diMinusDict[sQuote.dateQuote] = di
                }
            }
            lastHigh = high
            lastLow = low
            lastClose = close
        }
        return diMinusDict
    }
    
    static func adx(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        return ADX.adx(avg: avg, diPlus: diPlus(avg: avg, cQuote: cQuote), diMinus: diMinus(avg: avg, cQuote: cQuote))
    }
    
    static func adx(avg: Int, diPlus: [Date: Double], diMinus: [Date: Double]) -> [Date : Double] {

        var adxDict = [Date: Double] ()
        
        var firstdx = Array(repeating: 0, count: avg)
        var idx: Int = 0
        var j: Int = 0
        var first = true
        var dip = 0.0, dim = 0.0, avgdx = 0.0, dx = 0.0
        
        let tempDict = diPlus.sorted{ $0.key < $1.key }
        
        for (key, element) in tempDict {
            if let value = diMinus[key] {
                dip = element
                dim = value
                dx =  (abs(dip - dim) / (dip + dim) ) * 100
                idx = Int(dx)
                //print ("\(dateFormatter2.string(from: key)) dip \(dip) dim \(dim)  iDX  \(idx) DX \(dx) ")
                
                if first {
                    firstdx [j] = idx
                    j = (j  + 1 ) % avg;
                    if  j == 0  {
                        for firstdxValue in firstdx {
                            avgdx +=  Double(firstdxValue)
                        }
                        avgdx = avgdx / Double(avg)
                        
                        adxDict[key] = avgdx
                        first = false
                    }
                } else {
                    avgdx = ( (avgdx * Double(avg - 1) ) + Double(idx) ) / Double(avg)
                    adxDict[key] = avgdx
                }
            }
        }
        return adxDict
    }
            
    
    static func adxr (avg: Int, adxDict: [Date : Double] ) -> [Date : Double] {
        
        var adxrDict = [Date: Double] ()
        var arAdx = Array(repeating: 0.0, count: avg)
        var j: Int = 1
        var first = true
        var adxr = 0.0
        
        let tempDict = adxDict.sorted{ $0.key < $1.key }
        
        for (key, adx) in tempDict {
            if first {
                arAdx[j] = adx
                j = (j  + 1 ) % avg
                if  (j == 0) {
                    first = false
                }
            } else {
                arAdx[0...avg-1] = arAdx[1...arAdx.count-1]
                arAdx.append(adx)
                adxr = (arAdx[0] + arAdx[avg-1]) / 2
                adxrDict[key] = adxr
            }
        }
        return adxrDict
    }
    
}
