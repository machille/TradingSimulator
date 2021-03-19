//
//  RSI.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class RSI {
    
    static func rsi(period: Int, cQuote: [StockQuote]) -> [Date : Double] {
       
        var rsiDict = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var lastClose  = 0.0 , oldClose = -1.0
        var gain  = 0.0 , loss = 0.0, diff = 0.0
        var avgGain1 = 0.0, avgLoss1 = 0.0
        var rs = 0.0 , rsi = 0.0
        
        let periodD = Double(period)
        
         for sQuote in cQuote {
            if oldClose == -1.0 {
                oldClose = sQuote.close
                continue
            }
            
            lastClose = sQuote.close
            diff = lastClose - oldClose
            gain = 0.0
            loss = 0.0
            if diff >= 0 {
                gain = diff
            } else {
                loss = diff * -1
            }
            
            oldClose = lastClose
            
            if first {
                avgGain1 += gain
                avgLoss1 += loss
                
                j = (j  + 1 ) % period
                
                if (j == 0)  {
                    first = false
                    avgGain1 = avgGain1 / periodD
                    avgLoss1 = avgLoss1 / periodD
                    rs = avgGain1 / avgLoss1
                    rsi = 100 - ( 100 / ( 1 + rs ) )
                    
                    rsiDict[sQuote.dateQuote] = rsi
                }
                
            } else {
                
                avgGain1 = (((avgGain1 * (periodD - 1.0)) + gain) / periodD)
                avgLoss1 = (((avgLoss1 * (periodD - 1.0)) + loss) / periodD)
                rs = avgGain1 / avgLoss1
                rsi = 100.0 - ( 100.0 / ( 1 + rs ) )
                
                rsiDict[sQuote.dateQuote] = rsi
             }
        }
        return rsiDict
    }
    
    static func rsi(period: Int, dict: [Date: Double]) -> [Date : Double] {
        
        var rsiDict = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var lastClose  = 0.0 , oldClose = -1.0
        var gain  = 0.0 , loss = 0.0, diff = 0.0
        var avgGain1 = 0.0, avgLoss1 = 0.0
        var rs = 0.0 , rsi = 0.0
        
        let periodD = Double(period)
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            if oldClose == -1.0 {
                oldClose = element
                continue
            }
            
            lastClose = element
            diff = lastClose - oldClose
            gain = 0.0
            loss = 0.0
            if diff >= 0 {
                gain = diff
            } else {
                loss = diff * -1
            }
            
            oldClose = lastClose
            
            if first {
                avgGain1 += gain
                avgLoss1 += loss
                
                j = (j  + 1 ) % period
                
                if (j == 0)  {
                    first = false
                    avgGain1 = avgGain1 / periodD
                    avgLoss1 = avgLoss1 / periodD
                    rs = avgGain1 / avgLoss1
                    rsi = 100 - ( 100 / ( 1 + rs ) )
                    
                    rsiDict[key] = rsi
                }
                
            } else {
                
                avgGain1 = (((avgGain1 * (periodD - 1.0)) + gain) / periodD)
                avgLoss1 = (((avgLoss1 * (periodD - 1.0)) + loss) / periodD)
                rs = avgGain1 / avgLoss1
                rsi = 100.0 - ( 100.0 / ( 1 + rs ) )
                
                rsiDict[key] = rsi
            }
        }
        return rsiDict
    }
    
    /*
     * Developed by Tushard Chande and Stanley Kroll, StochRSI is an oscillator that measures
     * the level of RSI relative to its high-low range over a set time period.
     * StochRSI applies the Stochastics formula to RSI values, instead of price values.
     * This makes it an indicator of an indicator. The result is an oscillator that fluctuates between 0 and 1.
     *
     * In their 1994 book, The New Technical Trader, Chande and Kroll explain that RSI can oscillate between 80 and 20
     * for extended periods without reaching extreme levels.
     *
     * Notice that 80 and 20 are used for overbought and oversold instead of the more traditional 70 and 30.
     * Traders looking to enter a stock based on an overbought or oversold reading in RSI might find themselves
     * continuously on the sidelines. Chande and Kroll developed StochRSI to increase sensitivity and generate
     *  more overbought/oversold signals.
     */
    static func stochRSI(period: Int, stoc: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let stochRsiDict = rsi(period: period, cQuote: cQuote)
        return Stochastics.stochastics(avg: stoc, dict: stochRsiDict)
     }
}
