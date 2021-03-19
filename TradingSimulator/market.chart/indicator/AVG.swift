//
//  AVG.swift
//  Trading
//
//  Created by Maroun Achille on 30/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class AVG {
    
    static func sma(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var average = [Date: Double] ()
        var j: Int = 0
        var first = true
        var trAvg  = 0.0
        var arAvg = Array(repeating: 0.0, count: avg)
        let avgd = Double(avg)
        
        for sQuote in cQuote {
            
            arAvg[j] = sQuote.close
            j = (j  + 1 ) % avg
            
            if (j == 0) && (first) {
                first = false
            }
            
            if !first {
                for arAvgValue in arAvg {
                    trAvg  +=  arAvgValue
                }
                trAvg = trAvg / avgd
                average[sQuote.dateQuote] = trAvg
                trAvg  = 0.0
            }
        }
        return average
    }
    
    static func sma(avg: Int, dict: [Date: Double]) -> [Date : Double] {
        
        var average = [Date: Double] ()
        var j: Int = 0
        var first = true
        var trAvg  = 0.0
        var arAvg =  Array(repeating: 0.0, count: avg)
        let avgd = Double(avg)
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            arAvg[j] = element
            j = (j  + 1 ) % avg
            
            if (j == 0) && (first) {
                first = false
            }
            
            if !first {
                for arAvgValue in arAvg {
                    trAvg  +=  arAvgValue
                }
                trAvg = trAvg / avgd
                average[key] = trAvg
                trAvg  = 0.0
            }
        }
        return average
    }
    
    static func ema(avg: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var average = [Date: Double] ()
        var j: Int = 0
        var first = true
        var trAvg  = 0.0
        var arAvg = Array(repeating: 0.0, count: avg)
        
        let alpha =  2.0 / (1.0 + Double(avg))
        
        for sQuote in cQuote {
            if first {
                arAvg[j] = sQuote.close
                j = (j  + 1 ) % avg
                
                if j == 0 {
                    for arAvgValue in arAvg {
                        trAvg  +=  arAvgValue
                    }
                    trAvg = trAvg / Double(avg)
                    //print ( "trAvg \(trAvg) alpha \(alpha) ")
                    first = false
                }
            } else {
                trAvg = (alpha * (sQuote.close - trAvg ) ) + trAvg
                average[sQuote.dateQuote] = trAvg
            }
        }
        return average
    }
    
    
    static func ema(avg: Int, dict: [Date: Double]) -> [Date : Double] {
        
        var average = [Date: Double] ()
        var j: Int = 0
        var first = true
        var trAvg  = 0.0
        var arAvg = Array(repeating: 0.0, count: avg)
        
        let alpha =  2.0 / (1.0 + Double(avg))
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            if first {
                arAvg[j] = element
                j = (j  + 1 ) % avg
                
                if j == 0 {
                    for arAvgValue in arAvg {
                        trAvg  +=  arAvgValue
                    }
                    trAvg = trAvg / Double(avg)
                    first = false
                }
            } else {
                trAvg = (alpha * (element - trAvg ) ) + trAvg
                average[key] = trAvg
            }
        }
        return average
    }
    /******************* EMA MAP SELON LE LIVRE A TO Z (mais trop ameliore par Dinapoli )******************/
    static func ema2(avg: Double, dict: [Date : Double]) -> [Date : Double] {
        
        var average = [Date: Double] ()
        var first = true
        var trAvg  = 0.0
        
        var alpha =  2.0 / (1.0 + avg)
        alpha = Double(round(1000 * alpha) / 1000)
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            if first {
                trAvg = element
                first = false
            } else {
                trAvg = trAvg + (alpha * (element - trAvg ) )
                average[key] = trAvg
            }
        }
        return average
    }
    
    static func channel(coefficient: Int, dict: [Date: Double]) -> [Date : Double] {
        
        var channel = [Date: Double] ()
        var trAvg = 0.0
        let coeff = Double(coefficient) / 100.0
        
        for (key, element) in dict {
            trAvg = element + (element * coeff )
            channel[key] = trAvg
        }
        return channel
    }
    
    /**************** DEPLACED MOVING AVERAGE ******************/
    static func dma(avg: Int, deplaced: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var average = [Date: Double] ()
        var j: Int = 0
        var first = true
        var deAvg = Array(repeating: 0.0, count: deplaced)
        
        let tempDict = AVG.sma(avg: avg, cQuote: cQuote).sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            if !first {
                average[key] = deAvg[j]
            }
            
            deAvg[j] = element
            j = (j  + 1 ) % deplaced
            
            if ( (j == 0) && (first) ) {
                first = false
            }
        }
        return average
    }
    
    /****************** Double Exponential Moving Average *****************/
    static func dema(avg: Int, multi: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var average = [Date: Double] ()
        let average1 = AVG.ema(avg: avg, cQuote: cQuote)
        let average2 = AVG.ema(avg: avg, dict: average1)
        let multid = Double (multi)
        
        for (key, element) in average2 {
            if let avgValue = average1[key] {
                average[key] = (multid * avgValue) - element
            }
        }
        return average
    }
    
    /****************** Modified Moving Average ************************/
    static func mma(avg: Int, dict: [Date: Double]) -> [Date : Double] {
        
        var average = [Date: Double] ()
        var j: Int = 0
        var first = true
        var trAvg  = 0.0
        var arAvg = Array(repeating: 0.0, count: avg)
        let avgd = Double(avg)
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            if (first) {
                arAvg[j] = element
                j = (j  + 1 ) % avg
                
                if j == 0  {
                    for arAvgValue in arAvg {
                        trAvg  +=  arAvgValue
                    }
                    trAvg = trAvg / Double(avg)
                    first = false
                }
            } else {
                trAvg = trAvg +  ((element - trAvg) / avgd)
                average[key] = trAvg
            }
        }
        return average
    }
}
