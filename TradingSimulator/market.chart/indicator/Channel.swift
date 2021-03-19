//
//  Channel.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

/****************
 * Originally developed by Chester Keltner and later modified by Linda Raschke,
 * Keltner Channels, also known as Keltner Bands are a volatility-based technical indicator.
 * The Channels are composed of two bands plotted around an Exponential Moving Average
 * of the data for a given period and are they are calculated by adding or subtracting twice
 * the average true range from the moving average.
 * User inputs }
 NPeriod :=Input(\"Bands Channel\'s Periods\", 1,252,20);
 BBStdDev :=Input(\"Bollinger Bands Deviation\",.001,10,2);
 KTStdDev :=Input(\"Keltner Bands Deviation\",0.0,10,1.5);
 MoPeriod :=Input(\"Momentum Periods\",1,50,12);
 MoEMA :=Input(\"Momentum EMA Periods\",1,20,5);
 
 
 {Bollinger Bands}
 HBLine := BBandTop( C, NPeriod, E, BBStdDev);
 LBLine := BBandBot( C, NPeriod, E, BBStdDev);
 
 {Keltner Bands}
 HKLine := MOV(C,NPeriod,S) + KTStdDev * ATR(NPeriod);
 LKLine := MOV(C,NPeriod,S) - KTStdDev * ATR(NPeriod);
 
 MoHist := Mov((C - Ref(C,-MoPeriod)),MoEMA, E);
 
 BBUp := If((HBLine > HKLine) AND (MoHist > 0), MoHist, 0);
 BBDo := If((LBLine < LKLine) AND (MoHist < 0), MoHist, 0);
 BBMid1:= If((BBUp = 0) AND (BBDo = 0) AND (MoHist > 0), MoHist, 0);
 BBMid2:= If((BBUp = 0) AND (BBDo = 0) AND (MoHist < 0), MoHist, 0);
 
 
 BBUp {Histogram - Blue};
 BBDo {Histogram - Red};
 BBMid1 {Histogram - Gray};
 BBMid2 {Histogram - Brown};
 
 * @param hist
 * @param avg
 * @param spread
 * @return
 */

class Channel {
    
    static func keltnerTop(avg: Int, spread: Double, avgAtr: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var keltnerTop = [Date: Double] ()
        
        let kbMid = AVG.sma(avg: avg, dict: CQuote.typicalPrice3(cQuote: cQuote))
        let kbAtr = ATR.atr(avg: avgAtr, cQuote: cQuote)

        let tempDict = kbMid.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            if let kbAatrValue = kbAtr[key] {
                keltnerTop[key] = element + (kbAatrValue * spread)
            }
        }
        return keltnerTop
    }
    
    static func keltnerBot(avg: Int, spread: Double, avgAtr: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var keltnerBop = [Date: Double] ()
        
        let kbMid = AVG.sma(avg: avg, dict: CQuote.typicalPrice3(cQuote: cQuote))
        let kbAtr = ATR.atr(avg: avgAtr, cQuote: cQuote)
        
        let tempDict = kbMid.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            if let kbAatrValue = kbAtr[key] {
                keltnerBop[key] = element - (kbAatrValue * spread)
            }
        }
        return keltnerBop
    }
    
    static func squeeze(avg: Int, bspread: Double, kspread: Double, cQuote: [StockQuote]) -> [Date : Double] {
        
        var sqzDict = [Date: Double] ()
        var squeezeValue = 0.0
        
        let bStd = Bollinger.bollingerDev(avg: avg, dev: bspread, cQuote: cQuote)
        let kbAtr = ATR.atr(avg: avg, cQuote: cQuote)
        
        let tempDict = bStd.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            if let kbAatrValue = kbAtr[key] {
                squeezeValue = element - (kbAatrValue * kspread);
                if (squeezeValue < 0) {
                    sqzDict[key] = -0.001
                } else {
                    sqzDict[key] = 0.001
                }
            }
        }
        return sqzDict
    }

    static func squeezeMOM(period: Int, cQuote: [StockQuote]) -> [Date : Double] {
        let avgHHLL =  CQuote.calDict2(oper: "DIV",
                                       dict: CQuote.addDict(dict1: HighLow.highestHigh(period: period,
                                                                                       dict: CQuote.getHigh(cQuote : cQuote)),
                                                            dict2: HighLow.lowestLow(period: period,
                                                                                     dict: CQuote.getLow(cQuote : cQuote)) ),
                                       calcValue: 2.0)
        
        let avgHLLast =  CQuote.calDict2(oper: "DIV",
                                         dict: CQuote.addDict(dict1: avgHHLL,
                                                              dict2: AVG.ema(avg: period, cQuote : cQuote) ),
                                         calcValue: 2.0)
        
        return LinearProg.linearReg(period: period,
                                    dict: CQuote.subDict(dict1: CQuote.getClose(cQuote: cQuote),
                                                         dict2: avgHLLast))
    }
 
}

