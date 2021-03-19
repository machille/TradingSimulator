//
//  SafeZone.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class Stop {
    
    static func safeZoneUp(avg: Int, coef: Int, cQuote: [StockQuote]) -> [Date : Double] {
    
        var upSafeZone = [Date: Double] ()
    
        var j: Int = 0, k: Int = 0
        var first = true, write = true
        
        var low = 0.0, lastLow = -1.0
        var lastClose = 0.0
        var sumDnPen = 0.0
        var sumPenYN: Int = 0
        var stop = 0.0 , lastStop = -1.0
        var dnAvg = 0.0, lastDnAvg = -1.0
        
        var dnPen = Array(repeating: 0.0, count: avg)
        var penYN = Array(repeating: 0, count: avg)
        var shortStop = Array(repeating: 0.0, count: 3)

        let coefD = Double(coef)
        for sQuote in cQuote {
            low = sQuote.low
            if lastLow != -1.0 {
                dnPen[j] = lastLow > low ?  lastLow - low : 0.0
                penYN [j]  = low < lastLow ?  1 : 0
                
                j = (j  + 1 ) % avg
                if j == 0 && first {
                    first = false
                }
            }
            
            if !first {
                sumDnPen = 0.0
                sumPenYN = 0
                
                for index in 0..<avg {
                    sumDnPen += dnPen[index]
                    sumPenYN += penYN[index]
                }
                
                if sumPenYN == 0 {
                    sumPenYN = 1
                }
                
                dnAvg = sumDnPen / Double(sumPenYN)
                if lastDnAvg != -1 {
                    shortStop[k] = lastLow - (coefD * lastDnAvg)
                    k = (k  + 1 ) % 3
                    if k == 0 && write {
                        write = false
                    }
                    if !write  {
                        stop = 0.0
                         for shortStopValue in shortStop {
                            stop = max(stop, shortStopValue)
                        }
                        if lastStop !=  -1.0 {
                            stop = lastClose < lastStop ? stop : max(stop , lastStop)
                        }
                        upSafeZone[sQuote.dateQuote] = stop
                        lastStop = stop
                    }
                }
                lastDnAvg = dnAvg
            }
            
            lastLow = low
            lastClose = sQuote.close
        }
        return upSafeZone
    }
        
    static func safeZoneDown(avg: Int, coef: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var downSafeZone = [Date: Double] ()
        
        var j: Int = 0, k: Int = 0
        var first = true, write = true
        
        var high = 0.0, lastHigh = -1.0
        var lastClose = 0.0
        var sumDnPen = 0.0
        var sumPenYN: Int = 0
        var stop = 0.0 , lastStop = -1.0
        var dnAvg = 0.0, lastDnAvg = -1.0
        
        var dnPen = Array(repeating: 0.0, count: avg)
        var penYN = Array(repeating: 0, count: avg)
        var shortStop = Array(repeating: 0.0, count: 3)
        
        let coefD = Double(coef)
        
        for sQuote in cQuote {
            high = sQuote.high
            if lastHigh != -1.0 {
                dnPen[j] = high > lastHigh ?  high - lastHigh : 0.0
                penYN [j]  = high > lastHigh ?  1 : 0
                
                j = (j  + 1 ) % avg
                if j == 0 && first {
                    first = false
                }
            }
            
            if !first {
                sumDnPen = 0.0
                sumPenYN = 0
                
                for index in 0..<avg {
                    sumDnPen += dnPen[index]
                    sumPenYN += penYN[index]
                }
                
                if sumPenYN == 0 {
                    sumPenYN = 1
                }
                
                dnAvg = sumDnPen / Double(sumPenYN)
                if lastDnAvg != -1 {
                    shortStop[k] = lastHigh + (coefD * lastDnAvg)
                    k = (k  + 1 ) % 3
                    if k == 0 && write {
                        write = false
                    }
                    if !write  {
                        stop = 9999999999.0
                        for shortStopValue in shortStop {
                            stop = min(stop, shortStopValue)
                        }
                        if lastStop !=  -1.0 {
                            stop = lastClose > lastStop ? stop : min(stop , lastStop)
                        }
                        downSafeZone[sQuote.dateQuote] = stop
                        lastStop = stop
                    }
                }
                lastDnAvg = dnAvg
            }
            
            lastHigh = high
            lastClose = sQuote.close
        }
        return downSafeZone
    }
    
    /* when open profit reaches four ATRs, reduce Chandelier to two ATRs
     *  when open profit reaches six ATRs, reduce Chandelier to one ATRs
     
       Chandelier Exit (long) = 22-day High - ATR(22) x 3
     */
    static func chandelierExitUp(avg: Int, coef: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var upStopAtr = [Date: Double] ()
        
        let coefD = Double(coef)
        
        let atrDict = ATR.atr(avg: avg, cQuote: cQuote)
        let highDict = HighLow.highestHigh(period: avg, dict: CQuote.getHigh(cQuote: cQuote))
        
        let tempDict = atrDict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            if let testValue = highDict[key] {
                upStopAtr[key] = testValue - (coefD * element)
            }
        }
        return upStopAtr
    }
    
    /* Chandelier Exit (short) = 22-day Low + ATR(22) x 3 */
    static func chandelierExitDown(avg: Int, coef: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var downStopAtr = [Date: Double] ()
        
        let coefD = Double(coef)
        
        let atrDict = ATR.atr(avg: avg, cQuote: cQuote)
        let highDict = HighLow.lowestLow(period: avg, dict: CQuote.getLow(cQuote: cQuote))
        
        let tempDict = atrDict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            if let testValue = highDict[key] {
                downStopAtr[key] = testValue + (coefD * element)
            }
        }
        return downStopAtr
    }
    
    /*
     * AVTR:=Mov(HHV(H,2) - LLV(L,2),20, S);
     * SD:=Stdev(HHV(H,2) - LLV(L,2),20);
     * HHV(H-AVTR-3.6*SD, 20);
     * HHV(H-AVTR-2.2*SD,20);
     * HHV(H-AVTR-SD,20);
     * HHV(H-AVTR,20);
     */

    static func devStopHHLL(cQuote: [StockQuote]) -> [Date : Double] {
        
        var hhllDict = [Date: Double] ()
        var lastLow = -1.0, lastHigh = -1.0
        var HHV2 = 0.0, LLV2 = 0.0, HHLL = 0.0
        
        for sQuote in cQuote {
            if lastLow != -1.0 {
                HHV2 = max(lastHigh, sQuote.high)
                LLV2 = min(lastLow, sQuote.low)
                HHLL = HHV2 - LLV2
                hhllDict[sQuote.dateQuote] = HHLL
            }
            
            lastLow = sQuote.low
            lastHigh = sQuote.high
        }
        return hhllDict
    }
    
    static func kaseStopUp(avg: Int, coef: Double, cQuote: [StockQuote]) -> [Date : Double] {
        
        var upStopDict = [Date: Double] ()
        var upDevStop = 0.0
        var j:Int = 0
        
        var longStop = Array(repeating: 0.0, count: avg)
        
        let HHLLDict = devStopHHLL(cQuote: cQuote)
        let maHHLLDict = AVG.sma(avg: avg, dict: HHLLDict)
        let stdHHLLDict =  Bollinger.bollingerDev(avg: avg, dev: 1.0, dict: HHLLDict)
        
        for sQuote in cQuote {
            
            if let maHHLLValue = maHHLLDict[sQuote.dateQuote], let stdHHLLValue = stdHHLLDict[sQuote.dateQuote] {
                upDevStop = sQuote.high - maHHLLValue - (coef * stdHHLLValue)
                longStop[j] = upDevStop
                j = (j  + 1 ) % avg
                
               for longStopValue in longStop {
                    upDevStop = max(upDevStop, longStopValue)
                }
                upStopDict[sQuote.dateQuote] =  upDevStop
            }
        }
        return upStopDict
    }
            
    static func kaseStopDown(avg: Int, coef: Double, cQuote: [StockQuote]) -> [Date : Double] {
        
        var downStopDict = [Date: Double] ()
        var downDevStop = 0.0
        var j:Int = 0
        
        var shortStop = Array(repeating: 0.0, count: avg)
        
        let HHLLDict = devStopHHLL(cQuote: cQuote)
        let maHHLLDict = AVG.sma(avg: avg, dict: HHLLDict)
        let stdHHLLDict =  Bollinger.bollingerDev(avg: avg, dev: 1.0, dict: HHLLDict)
        
        for sQuote in cQuote {
            
            if let maHHLLValue = maHHLLDict[sQuote.dateQuote], let stdHHLLValue = stdHHLLDict[sQuote.dateQuote] {
                downDevStop = sQuote.low + maHHLLValue + (coef * stdHHLLValue)
                shortStop[j] = downDevStop
                j = (j  + 1 ) % avg
                
                for shortStopValue in shortStop {
                    downDevStop = min(downDevStop, shortStopValue)
                }
                downStopDict[sQuote.dateQuote] =  downDevStop
            }
        }
        return downStopDict
    }
    
    ///***      SAR                   */
    static func sar(accStep: Double, maxStep: Double, cQuote: [StockQuote]) -> [Date : Double] {
        
        var sarDict = [Date: Double] ()
        
        var accelerate = 0.0
        var position = 1, lastPosition = 0 // 1 = long et -1 = Short
        var first = true;
        
        var sar = 0.0, exterme = 0.0, lastExterme = 0.0
        
        for sQuote in cQuote {
            if first {
                position = 1 // long
                accelerate = accStep
//                exterme = (position == 1) ? sQuote.high : sQuote.low
//                sar = (position == 1) ? sQuote.low : sQuote.high
                exterme = sQuote.high
                sar = sQuote.low 
                
                first = false
            } else {
                if position == 1 {
                    if sQuote.low < sar  {
                        position = -1
                    } else {
                        position = 1
                    }
                } else { // position = -1 short
                    if sQuote.high > sar {
                        position = 1
                    } else {
                        position = -1
                    }
                }
                exterme = (position == 1) ? max(sQuote.high, exterme ) : min(sQuote.low, exterme )
                
                if lastPosition == position {
                    sar = sar + (Double(position)  * accelerate * abs(sar - lastExterme ))
                } else {
                    sar = lastExterme
                }
                
                if lastPosition == position {
                    if lastExterme != exterme {
                        accelerate = (accelerate + accStep) > maxStep ? maxStep : accelerate + accStep
                    }
                } else {
                    accelerate = accStep
                }
                sarDict[sQuote.dateQuote] = sar * Double(position)
            }
            lastPosition = position
            lastExterme = exterme
        }
        return sarDict
    }
    
    static func sarInd(accStep: Double, maxStep: Double, cQuote: [StockQuote]) -> [Date : Double] {
        let sarDict = sar(accStep: accStep, maxStep: maxStep, cQuote: cQuote)
        return CQuote.subDict(dict1: CQuote.getClose(cQuote: cQuote), dict2: sarDict)
    }
}
