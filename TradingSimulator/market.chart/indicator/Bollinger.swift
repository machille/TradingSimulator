//
//  Bollinger.swift
//  Trading
//
//  Created by Maroun Achille on 30/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class Bollinger {
    
    static func bollingerDev(avg: Int, dev: Double, cQuote: [StockQuote]) -> [Date : Double] {
        
        var bollingDev = [Date: Double] ()
        var j: Int = 0
        var first = true
        var trAvg  = 0.0, mdDev = 0.0, sdDev = 0.0
        var arDev = Array(repeating: 0.0, count: avg)
        
        let avgd = Double(avg)
        
        for sQuote in cQuote {
            arDev[j] = sQuote.close
            j = (j  + 1 ) % avg
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                for arDevValue in arDev {
                    trAvg  +=  arDevValue
                }
                trAvg = trAvg / avgd
                
                for arDevValue in arDev {
                    mdDev  +=  pow((trAvg - arDevValue), 2.0)
                }
                sdDev = sqrt(mdDev / avgd) * dev  //squareRoot()
                bollingDev[sQuote.dateQuote] = sdDev
                trAvg = 0.0
                mdDev = 0.0
            }
        }
        return bollingDev
    }
    
    static func bollingerDev(avg: Int, dev: Double,  dict: [Date: Double]) -> [Date : Double] {
        
        var bollingDev = [Date: Double] ()
        var j: Int = 0
        var first = true
        var trAvg  = 0.0, mdDev = 0.0, sdDev = 0.0
        var arDev = Array(repeating: 0.0, count: avg)
        
        let avgd = Double(avg)
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            arDev[j] = element
            j = (j  + 1 ) % avg
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                for arDevValue in arDev {
                    trAvg  +=  arDevValue
                }
                trAvg = trAvg / avgd
                
                for arDevValue in arDev {
                    mdDev  +=  pow((trAvg - arDevValue), 2.0)
                }
                sdDev = sqrt(mdDev / avgd) * dev
                bollingDev[key] = sdDev
                trAvg = 0.0
                mdDev = 0.0
            }
        }
        return bollingDev
    }
    
    static func bollingerTop(avg: Int, dev: Double,  cQuote: [StockQuote]) -> [Date : Double] {
        let bollsma = AVG.sma(avg: avg, cQuote: cQuote)
        let bolldev = Bollinger.bollingerDev(avg: avg, dev: dev, cQuote: cQuote)
        return CQuote.addDict(dict1: bollsma, dict2: bolldev)
    }
    
    static func bollingerBot(avg: Int, dev: Double,  cQuote: [StockQuote]) -> [Date : Double] {
        let bollsma = AVG.sma(avg: avg, cQuote: cQuote)
        let bolldev = Bollinger.bollingerDev(avg: avg, dev: dev, cQuote: cQuote)
        return CQuote.subDict(dict1: bollsma, dict2: bolldev)
    }
/* *************************** Bollinger BandWidth  *****************************************
BandWidth measures the percentage difference between the upper band and the lower band.
BandWidth decreases as Bollinger Bands narrow and increases as Bollinger Bands widen.
Because Bollinger Bands are based on the standard deviation, falling BandWidth reflects decreasing volatility and rising BandWidth reflects increasing volatility.
*/
    static func bollingerBW(avg: Int, dev: Double,  cQuote: [StockQuote]) -> [Date : Double] {
        
        var bollingBW = [Date: Double] ()
        var j: Int = 0
        var first = true
        var upperBB = 0.0, lowerBB = 0.0
        var trAvg  = 0.0, mdDev = 0.0, sdDev = 0.0
        var arDev = Array(repeating: 0.0, count: avg)
        
        let avgd = Double(avg)
        for sQuote in cQuote {
            
            arDev[j] = (sQuote.close + sQuote.low + sQuote.high) / 3.0
            j = (j  + 1 ) % avg;
            
            if j == 0 && first  {
                first = false
            }
            
            if !first {
                for arDevValue in arDev {
                    trAvg  +=  arDevValue
                }
                trAvg = trAvg / avgd
                
                for arDevValue in arDev {
                    mdDev  +=  pow((trAvg - arDevValue), 2.0)
                }
                sdDev = sqrt(mdDev / avgd) * dev
                upperBB = trAvg + sdDev
                lowerBB = trAvg - sdDev
                bollingBW[sQuote.dateQuote] = (upperBB - lowerBB ) / trAvg
                trAvg = 0.0
                mdDev = 0.0
            }
        }
        return bollingBW
    }
    
    /**************************************** Bollinger %b ****************************************/
    static func bollingerB(avg: Int, dev: Double,  cQuote: [StockQuote]) -> [Date : Double] {
        
        var bollingB = [Date: Double] ()
        var j: Int = 0
        var first = true
        var upperBB = 0.0, lowerBB = 0.0
        var trAvg  = 0.0, mdDev = 0.0, sdDev = 0.0
        var arDev = Array(repeating: 0.0, count: avg)
        
        let avgd = Double(avg)
        for sQuote in cQuote {
            
            arDev[j] = (sQuote.close + sQuote.low + sQuote.high) / 3.0
            j = (j  + 1 ) % avg;
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                for arDevValue in arDev {
                    trAvg  +=  arDevValue
                }
                trAvg = trAvg / avgd
                
                for arDevValue in arDev {
                    mdDev  +=  pow((trAvg - arDevValue), 2.0)
                }
                sdDev = sqrt(mdDev / avgd) * dev  //squareRoot()
                upperBB = trAvg + sdDev
                lowerBB = trAvg - sdDev
                bollingB[sQuote.dateQuote] = (sQuote.close - lowerBB ) / ( upperBB - lowerBB )
                trAvg = 0.0
                mdDev = 0.0
            }
        }
        return bollingB
    }
    
    /*************************************** Intraday Intensity (Oscillator) default 21************************/
    static func II(avg: Int,  cQuote: [StockQuote]) -> [Date : Double] {
        
        var bollingII = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var trAvg  = 0.0, mvAvg = 0.0
        var arDev = Array(repeating: 0.0, count: avg)
        var arVol = Array(repeating: 0.0, count: avg)
        
        for sQuote in cQuote {
            
            arDev[j] = ( ( 2 * sQuote.close - sQuote.low - sQuote.high ) / ( sQuote.high - sQuote.low ) ) * sQuote.volume
            arVol[j] = sQuote.volume
            j = (j  + 1 ) % avg
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                for arDevValue in arDev {
                    trAvg += arDevValue
                }
                for arVolValue in arVol {
                    mvAvg += arVolValue
                }
                bollingII[sQuote.dateQuote] = (trAvg / mvAvg) * 100.0
                trAvg  = 0.0
                mvAvg  = 0.0
            }
        }
        return bollingII
    }
    
    /*************************************** Accmulation Distribution default 10*************************************/
    static func LWAD(avg: Int,  cQuote: [StockQuote]) -> [Date : Double] {
        
        var dictLWAD = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var trAvg  = 0.0, mvAvg = 0.0
        var arDev = Array(repeating: 0.0, count: avg)
        var arVol = Array(repeating: 0.0, count: avg)
        
        for sQuote in cQuote {
            arDev[j] = ( ( sQuote.close - sQuote.open) / ( sQuote.high - sQuote.low ) ) * sQuote.volume
            arVol[j] = sQuote.volume
            j = (j  + 1 ) % avg
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                for arDevValue in arDev {
                    trAvg  +=  arDevValue
                }
                for arVolValue in arVol {
                    mvAvg  +=  arVolValue
                }
                dictLWAD[sQuote.dateQuote] = (trAvg / mvAvg) * 100.0
                trAvg  = 0.0
                mvAvg  = 0.0
            }
        }
        return dictLWAD
    }
    
    /*************************************** Money Flow Index defult 14*************************************/
    static func MFI(avg: Int,  cQuote: [StockQuote]) -> [Date : Double] {
        
        var dictMFI = [Date: Double] ()
        var j: Int = 0
        var first = true
        
        var lastTypPrice  = 0.0 , oldTypPrice = -1.0, moneyFlow = 0.0
        var sumPosMoneyFlow = 0.0 , sumNegMoneyFlow = 0.0, moneyFlowIndex = 0.0
        
        var posMoneyFlow = Array(repeating: 0.0, count: avg)
        var negMoneyFlow = Array(repeating: 0.0, count: avg)
        
        for sQuote in cQuote {
            
            lastTypPrice = (sQuote.close + sQuote.low + sQuote.high) / 3.0
            if oldTypPrice == -1.0  {
                oldTypPrice = lastTypPrice
                continue
            }
            
            moneyFlow = lastTypPrice * sQuote.volume
            posMoneyFlow[j] = lastTypPrice  >= oldTypPrice ? moneyFlow : 0.0
            negMoneyFlow[j] = lastTypPrice  >= oldTypPrice ? 0.0 : moneyFlow
            j = (j  + 1 ) % avg
            
            oldTypPrice = lastTypPrice
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                for pmfValue in posMoneyFlow {
                    sumPosMoneyFlow  +=  pmfValue
                }
                for nmfValue in negMoneyFlow {
                    sumNegMoneyFlow  +=  nmfValue
                }
                moneyFlowIndex  = 100.0 - ( 100.0 / ( 1.0 + ( sumPosMoneyFlow / sumNegMoneyFlow ) ) )
                dictMFI[sQuote.dateQuote] = moneyFlowIndex
                sumPosMoneyFlow = 0.0
                sumNegMoneyFlow = 0.0
            }
        }
        return dictMFI
    }

}
