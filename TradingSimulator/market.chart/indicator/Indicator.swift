//
//  Indicator.swift
//  Trading
//
//  Created by Maroun Achille on 09/04/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class Indicator {
    
    static func indicator(indic: IndicatorSetting, hist: [StockQuote] ) -> [IndicatorDraw] {
        var indicDrawArray = [IndicatorDraw]()
        
        let indicDraw = IndicatorDraw()
        indicDraw.color1 = indic.color1
        indicDraw.color2 = indic.color2
        indicDraw.desc   = indic.id + ":" + String(Int(indic.value1))
        indicDraw.type   = indic.type
        indicDraw.model  = indic.model
        indicDrawArray.append(indicDraw)
        
        switch (indic.id) {
        
        case "VOLUME":
            indicDraw.indicDict = CQuote.getVolume(cQuote: hist)

        case "STOC":
            indicDraw.desc   = indic.desc + String(Int(indic.value1))
            let fastKDict = Stochastics.stochastics(avg: Int(indic.value1), cQuote: hist)
            let fastDDict = AVG.sma(avg: Int(indic.value2), dict: fastKDict)
            indicDraw.indicDict = fastDDict
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "Slow K" + String(Int(indic.value3))
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = AVG.sma(avg: Int(indic.value3), dict: fastDDict)
            indicDrawArray.append(indicDraw2)
            
        case "MSTOC":
            let fastDDict = DINAPOLI.mSTOC(avg1: Int(indic.value1), avg2: Int(indic.value2), cQuote: hist)
            indicDraw.indicDict = fastDDict
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "Slow K" + String(Int(indic.value3))
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = AVG.mma(avg: Int(indic.value3), dict: fastDDict)
            indicDrawArray.append(indicDraw2)
            
        case "RSI", "RSITF":
            indicDraw.indicDict = RSI.rsi(period: Int(indic.value1), cQuote: hist)
            
        case "MACD":
            let macdDict = MACD.macd(shortAvg: Int(indic.value1), longAvg: Int(indic.value2), cQuote: hist)
            let ema1Dict = AVG.ema(avg: Int(indic.value3), dict: macdDict)
            let ema2Dict = CQuote.subDict(dict1: macdDict, dict2: ema1Dict)
            
            indicDraw.indicDict = macdDict
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "EMA " + String(Int(indic.value3))
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = ema1Dict
            indicDrawArray.append(indicDraw2)
            
            let indicDraw3 = IndicatorDraw()
            indicDraw3.color1 = indic.color2
            indicDraw3.color2 = indic.color2
            indicDraw3.desc   = "HIST " + String(Int(indic.value3))
            indicDraw3.type   = indic.type
            indicDraw3.model  = "Histogram"
            indicDraw3.indicDict = CQuote.calDict2(oper: "MLT", dict: ema2Dict, calcValue: 2.8)
            indicDrawArray.append(indicDraw3)
            
        case "MACDH":
            let macdDict = MACD.macd(shortAvg: Int(indic.value1), longAvg: Int(indic.value2), cQuote: hist)
            let ema1Dict = AVG.ema(avg: Int(indic.value3), dict: macdDict)
            indicDraw.indicDict = CQuote.subDict(dict1: macdDict, dict2: ema1Dict)
            
        case "MMACD":
            let macdDict = DINAPOLI.dMACD(avg1: indic.value1, avg2: indic.value2, cQuote: hist)
            let ema1Dict = AVG.ema(avg: Int(indic.value3), dict: macdDict)
            let ema2Dict = CQuote.subDict(dict1: macdDict, dict2: ema1Dict)
            
            indicDraw.indicDict = macdDict
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "EMA " + String(Int(indic.value3))
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = ema1Dict
            indicDrawArray.append(indicDraw2)
            
            let indicDraw3 = IndicatorDraw()
            indicDraw3.color1 = indic.color2
            indicDraw3.color2 = indic.color2
            indicDraw3.desc   = "HIST " + String(Int(indic.value3))
            indicDraw3.type   = indic.type
            indicDraw3.model  = "Histogram"
            indicDraw3.indicDict = CQuote.calDict2(oper: "MLT", dict: ema2Dict, calcValue: 2.8)
            indicDrawArray.append(indicDraw3)
            
        case "PPO":
            let ema1Dict = AVG.ema(avg: Int(indic.value1), cQuote: hist)
            let ema2Dict = AVG.ema(avg: Int(indic.value2), cQuote: hist)
            let ppoDict = CQuote.divDict(dict1: CQuote.subDict(dict1: ema1Dict, dict2: ema2Dict) , dict2: ema2Dict)
            
            indicDraw.indicDict = ppoDict
            
            let ema3Dict = AVG.ema(avg: Int(indic.value3), dict: ppoDict )
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "EMA " + String(Int(indic.value3))
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = ema3Dict
            indicDrawArray.append(indicDraw2)
            
            let ema4Dict = CQuote.subDict(dict1: ppoDict, dict2: ema3Dict)
            let indicDraw3 = IndicatorDraw()
            indicDraw3.color1 = indic.color2
            indicDraw3.color2 = indic.color2
            indicDraw3.desc   = "HIST " + String(Int(indic.value3))
            indicDraw3.type   = indic.type
            indicDraw3.model  = "Histogram"
            indicDraw3.indicDict = CQuote.calDict2(oper: "MLT", dict: ema4Dict, calcValue: 2.8)
            indicDrawArray.append(indicDraw3)
            
        case "PPOH":
            let ema1Dict = AVG.ema(avg: Int(indic.value1), cQuote: hist)
            let ema2Dict = AVG.ema(avg: Int(indic.value2), cQuote: hist)
            let ppoDict = CQuote.divDict(dict1: CQuote.subDict(dict1: ema1Dict, dict2: ema2Dict) , dict2: ema2Dict)
            let ema3Dict = AVG.ema(avg: Int(indic.value3), dict: ppoDict )
            
            indicDraw.indicDict = CQuote.subDict(dict1: ppoDict, dict2: ema3Dict)
            
        case "CCI":
            indicDraw.indicDict = CCI.cci(avg: Int(indic.value1), cQuote: hist)
      
        case "Aroon":
            indicDraw.desc   = "Up"
            indicDraw.indicDict = AROON.aroonUp(avg: Int(indic.value1), cQuote: hist)
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "Down"
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = AROON.aroonDown(avg: Int(indic.value1), cQuote: hist)
            indicDrawArray.append(indicDraw2)
            
        case "AROOSC":
            indicDraw.indicDict = AROON.aroonOsc(avg: Int(indic.value1), cQuote: hist)
            
        case "DMI":
            indicDraw.desc   = "DI+"
            indicDraw.indicDict = ADX.diPlus(avg: Int(indic.value1), cQuote: hist)

            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "DI-"
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = ADX.diMinus(avg: Int(indic.value1), cQuote: hist)
            indicDrawArray.append(indicDraw2)
            
            let indicDraw3 = IndicatorDraw()
            indicDraw3.color1 = NSColor(hex: "#00FFFF")!
            indicDraw3.color2 = NSColor(hex: "#00FFFF")!
            indicDraw3.desc   = "ADX"
            indicDraw3.type   = indic.type
            indicDraw3.model  = indic.model
            indicDraw3.indicDict = ADX.adx(avg: Int(indic.value1), cQuote: hist)
            indicDrawArray.append(indicDraw3)
            
        case "ADX":
            let adxDict = ADX.adx(avg: Int(indic.value1), cQuote: hist)
            indicDraw.indicDict = adxDict

            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "ADXR"
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = ADX.adxr(avg: Int(indic.value1), adxDict: adxDict)
            indicDrawArray.append(indicDraw2)
            
        case "WAD":
            indicDraw.indicDict = William.williamAD(cQuote: hist)

        case "WILLR":
            indicDraw.indicDict = William.williamR(avg: Int(indic.value1), cQuote: hist)
            
        case "CHAMF":
            indicDraw.indicDict = Chaikin.chaikinMF(avg: Int(indic.value1), cQuote: hist)

        case "CHAOSC":
            indicDraw.indicDict = Chaikin.chaikinOSC(avg1: Int(indic.value1), avg2: Int(indic.value2), cQuote: hist)
            
        case "ACDS":
            indicDraw.indicDict = AccuDist.accuDist(cQuote: hist)
            
        case "FDX":
            indicDraw.indicDict = ELDER.forceIndex(avg: Int(indic.value1), cQuote: hist)

        case "BULLPO":
            indicDraw.indicDict = ELDER.bullPower(avg: Int(indic.value1), cQuote: hist)

        case "BEARPO":
            indicDraw.indicDict = ELDER.bearPower(avg: Int(indic.value1), cQuote: hist)

        case "CMB":
            let rsiDict = RSI.rsi(period: 14, cQuote: hist)
            let ema1Dict = AVG.ema(avg: Int(indic.value1), dict: rsiDict)
            let ema2Dict = AVG.ema(avg: Int(indic.value2), dict: ema1Dict)
            let ema3Dict = AVG.ema(avg: Int(indic.value3), dict: ema2Dict )
            
            indicDraw.indicDict =   CQuote.subDict(dict1: ema2Dict, dict2: ema3Dict)
            
        case "BW":
            indicDraw.indicDict = Bollinger.bollingerBW(avg: Int(indic.value1), dev: indic.value2, cQuote: hist)

        case "BOLB":
            indicDraw.indicDict = Bollinger.bollingerB(avg: Int(indic.value1), dev: indic.value2, cQuote: hist)

        case "II":
            indicDraw.indicDict = Bollinger.II(avg: Int(indic.value1), cQuote: hist)

        case "MFI":
            indicDraw.indicDict = Bollinger.MFI(avg: Int(indic.value1), cQuote: hist)

        case "LWAD":
            indicDraw.indicDict = Bollinger.LWAD(avg: Int(indic.value1), cQuote: hist)

        case "ATR":
            indicDraw.indicDict = ATR.atr(avg: Int(indic.value1), cQuote: hist)

        case "DETOSC":
            indicDraw.indicDict = DINAPOLI.detOsc(avg: Int(indic.value1), cQuote: hist)

        case "MOM":
            indicDraw.indicDict = MOM.mom(period: Int(indic.value1), cQuote: hist)

        case "ROC":
            indicDraw.indicDict = MOM.roc(period: Int(indic.value1), cQuote: hist)

        case "SQUEEZ":
// TODO: add new fourth parmameter to squeeze MOM
            indicDraw.indicDict = Channel.squeeze(avg: Int(indic.value1), bspread: indic.value2, kspread: indic.value3, cQuote: hist)
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = NSColor(hex: "#00E532")! // Green
            indicDraw2.color2 = NSColor(hex: "#E5002E")! // Red
            indicDraw2.desc   = "SQZ-MOM"
            indicDraw2.type   = indic.type
            indicDraw2.model  = "Histogram"
            indicDraw2.indicDict = Channel.squeezeMOM(period: Int(indic.value1), cQuote: hist)
            indicDrawArray.append(indicDraw2)
            
       case "WAVABC":
            var macdDict = MACD.macd(shortAvg: Int(indic.value1), longAvg: Int(indic.value2), cQuote: hist)
            var ema1Dict = AVG.ema(avg: Int(indic.value2), dict: macdDict)
            
            indicDraw.indicDict = CQuote.subDict(dict1: macdDict, dict2: ema1Dict)
            indicDraw.color2 = indic.color1
            
            
            macdDict = MACD.macd(shortAvg: Int(indic.value1), longAvg: Int(indic.value3), cQuote: hist)
            ema1Dict = AVG.ema(avg: Int(indic.value3), dict: macdDict)
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "Signal"
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = CQuote.subDict(dict1: macdDict, dict2: ema1Dict)
            indicDrawArray.append(indicDraw2)
            
        case "OBV":
            indicDraw.indicDict = OBV.obv(cQuote: hist)

        case "DTOSC":
            let rsiDict = RSI.stochRSI(period: Int(indic.value1), stoc: Int(indic.value2), cQuote: hist)
            let fastDDict = AVG.ema(avg: Int(indic.value3), dict: rsiDict)
            
            indicDraw.indicDict = fastDDict
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "Slow K " + String(Int(indic.value3))
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = AVG.sma(avg: Int(indic.value3), dict: fastDDict)
            indicDrawArray.append(indicDraw2)

        case "RSLine":
            let avg = Int(indic.value1)
            var histMode = ChartType.Daily.rawValue
            if avg == 52 {
                histMode = ChartType.Weekly.rawValue
            }
            
            if let histIndex = HistoricQuoteDB.instance.getHistoricQuote(id: "SP500")?.getHist(contain: histMode) {
                let rsDict = RSLine.rsline(avg: Int(indic.value1), iQuote: histIndex, cQuote: hist)
                indicDraw.indicDict = rsDict
            }
            
        // SMA by default
        case "SMA":
            indicDraw.indicDict = AVG.sma(avg: Int(indic.value1), cQuote: hist)

        case "EMA":
            indicDraw.indicDict = AVG.ema(avg: Int(indic.value1), cQuote: hist)

        case "DMA":
            indicDraw.desc = "DMA " + String(Int(indic.value1)) + " D " + String(Int(indic.value2))
            indicDraw.indicDict = AVG.dma(avg: Int(indic.value1), deplaced: Int(indic.value2), cQuote: hist)
            
        case "CHAEMA":
            let chaLineDict = AVG.ema(avg: Int(indic.value1), cQuote: hist)
            indicDraw.indicDict = chaLineDict
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "Up " + String(Int(indic.value1))
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = AVG.channel(coefficient: Int(indic.value2), dict: chaLineDict)
            indicDrawArray.append(indicDraw2)
            
            let indicDraw3 = IndicatorDraw()
            indicDraw3.color1 = indic.color2
            indicDraw3.color2 = indic.color2
            indicDraw3.desc   = "Down " + String(Int(indic.value1))
            indicDraw3.type   = indic.type
            indicDraw3.model  = indic.model
            indicDraw3.indicDict = AVG.channel(coefficient: -1 * Int(indic.value2), dict: chaLineDict)
            indicDrawArray.append(indicDraw3)
            
        case "BOL":
            indicDraw.indicDict = AVG.sma(avg: Int(indic.value1), cQuote: hist)
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color2
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "BOL Top " + String(Int(indic.value1)) + ":" + String(indic.value2)
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = Bollinger.bollingerTop(avg: Int(indic.value1), dev: indic.value2 , cQuote: hist)
            indicDrawArray.append(indicDraw2)
            
            let indicDraw3 = IndicatorDraw()
            indicDraw3.color1 = indic.color2
            indicDraw3.color2 = indic.color2
            indicDraw3.desc   = "BOL Bot " + String(Int(indic.value1)) + ":" + String(indic.value2)
            indicDraw3.type   = indic.type
            indicDraw3.model  = indic.model
            indicDraw3.indicDict = Bollinger.bollingerBot(avg: Int(indic.value1), dev: indic.value2 , cQuote: hist)
            indicDrawArray.append(indicDraw3)
            
        case "KEL":
            indicDraw.desc = "KEL Up " + String(Int(indic.value1)) + " " + String(indic.value2)
            indicDraw.indicDict = Channel.keltnerTop(avg: Int(indic.value1), spread: indic.value2, avgAtr: Int(indic.value3), cQuote: hist)
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color1
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "KEL Down " + String(Int(indic.value1)) + " " + String(indic.value2)
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = Channel.keltnerBot(avg: Int(indic.value1), spread: indic.value2, avgAtr: Int(indic.value3), cQuote: hist)
            indicDrawArray.append(indicDraw2)
            
        case "HL":
            indicDraw.desc = "HH " + String(Int(indic.value1))
            indicDraw.indicDict = HighLow.highestHigh(period: Int(indic.value1), dict: CQuote.getHigh(cQuote: hist))
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color1
            indicDraw2.color2 = indic.color2
            indicDraw2.desc   = "LL " + String(Int(indic.value1))
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.indicDict = HighLow.lowestLow(period: Int(indic.value1), dict: CQuote.getLow(cQuote: hist))
            indicDrawArray.append(indicDraw2)
        
        /// **** Trailing Stop ****
        case "SAR":
            indicDraw.indicDict = Stop.sar(accStep: indic.value1, maxStep: indic.value2, cQuote: hist)
            indicDraw.stop = true
            
        case "KASEUP":
            indicDraw.indicDict = Stop.kaseStopUp(avg: Int(indic.value1), coef: 1.0, cQuote: hist)
            indicDraw.desc   = indic.id + ": 1"
            indicDraw.stop = true
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color1
            indicDraw2.color2 = indic.color1
            indicDraw2.desc   = indic.id + ":" + String(indic.value2)
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.stop = true
            indicDraw2.indicDict = Stop.kaseStopUp(avg: Int(indic.value1), coef: indic.value2, cQuote: hist)
            indicDrawArray.append(indicDraw2)

            let indicDraw3 = IndicatorDraw()
            indicDraw3.color1 = indic.color2
            indicDraw3.color2 = indic.color2
            indicDraw3.desc   = indic.id + ":" + String(indic.value3)
            indicDraw3.type   = indic.type
            indicDraw3.model  = indic.model
            indicDraw3.stop = true
            indicDraw3.indicDict = Stop.kaseStopUp(avg: Int(indic.value1), coef: indic.value3, cQuote: hist)
            indicDrawArray.append(indicDraw3)

        case "KASEDW":
            indicDraw.indicDict = Stop.kaseStopDown(avg: Int(indic.value1), coef: 1.0, cQuote: hist)
            indicDraw.desc   = indic.id + ": 1"
            indicDraw.stop = true
            
            let indicDraw2 = IndicatorDraw()
            indicDraw2.color1 = indic.color1
            indicDraw2.color2 = indic.color1
            indicDraw2.desc   = indic.id + ":" + String(indic.value2)
            indicDraw2.type   = indic.type
            indicDraw2.model  = indic.model
            indicDraw2.stop = true
            indicDraw2.indicDict = Stop.kaseStopDown(avg: Int(indic.value1), coef: indic.value2, cQuote: hist)
            indicDrawArray.append(indicDraw2)
            
            let indicDraw3 = IndicatorDraw()
            indicDraw3.color1 = indic.color2
            indicDraw3.color2 = indic.color2
            indicDraw3.desc   = indic.id + ":" + String(indic.value3)
            indicDraw3.type   = indic.type
            indicDraw3.model  = indic.model
            indicDraw3.stop = true
            indicDraw3.indicDict = Stop.kaseStopDown(avg: Int(indic.value1), coef: indic.value3, cQuote: hist)
            indicDrawArray.append(indicDraw3)
            
        case "CHEXUP":
            indicDraw.indicDict = Stop.chandelierExitUp(avg: Int(indic.value1), coef: Int(indic.value2), cQuote: hist)
            indicDraw.stop = true

        case "CHEXDW":
            indicDraw.indicDict = Stop.chandelierExitDown(avg: Int(indic.value1), coef: Int(indic.value2), cQuote: hist)
            indicDraw.stop = true
       
        case "SFZUP":
            indicDraw.indicDict = Stop.safeZoneUp(avg: Int(indic.value1), coef: Int(indic.value2), cQuote: hist)
            indicDraw.stop = true
  
        case "SFZDW":
            indicDraw.indicDict = Stop.safeZoneDown(avg: Int(indic.value1), coef: Int(indic.value2), cQuote: hist)
            indicDraw.stop = true
            

        default:
            indicDrawArray.removeAll()
        }
        
        if indic.maValue1 > 0 {
            indicDrawArray.append(calculateAvg(dict: indicDraw.indicDict, avgColor: indic.maColor1, avg: Int(indic.maValue1), avgType: indic.maType1))
        }
        
        if indic.maValue2 > 0 {
            indicDrawArray.append(calculateAvg(dict: indicDraw.indicDict, avgColor: indic.maColor2, avg: Int(indic.maValue2), avgType: indic.maType2))
        }
        
        return indicDrawArray
    }
    
    private static func calculateAvg (dict: [Date: Double], avgColor: NSColor,  avg: Int, avgType: String) -> IndicatorDraw {

        let indicDraw2 = IndicatorDraw()
        
        indicDraw2.color1 = avgColor
        indicDraw2.color2 = avgColor
        indicDraw2.desc   = avgType + " " + String(avg)
        indicDraw2.type   = IndicatorType.Follow.rawValue
        indicDraw2.model  = IndicatorModel.Line.rawValue
        if avgType == AverageType.SMA.rawValue {
            indicDraw2.indicDict = AVG.sma(avg: avg, dict: dict)
        } else {
            indicDraw2.indicDict = AVG.ema(avg: avg, dict: dict)
        }
        
        return indicDraw2
    }
}
