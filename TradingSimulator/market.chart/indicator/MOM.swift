//
//  MOM.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class MOM {
    
     static func mom(period: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var momDict = [Date: Double] ()
        var j: Int = 0
        var first = true
        var arMom = Array(repeating: 0.0, count: period)
        
         for sQuote in cQuote {
            arMom[j] = sQuote.close
            
            j = (j  + 1 ) % period
            if j == 0 && first {
                first = false
            }

            if !first {
                momDict[sQuote.dateQuote] = sQuote.close - arMom[ j % period ]
            }
        }
        return momDict
    }
    
    static func roc(period: Int, cQuote: [StockQuote]) -> [Date : Double] {
        
        var rocDict = [Date: Double] ()
        var j: Int = 0
        var first = true
        var arRoc = Array(repeating: 0.0, count: period)
        
        for sQuote in cQuote {
            arRoc[j] = sQuote.close
            
            j = (j  + 1 ) % period
            if j == 0 && first {
                first = false
            }
            
            if !first {
                rocDict[sQuote.dateQuote] = ((sQuote.close -  arRoc[ j % period ]) / arRoc[ j % period ]) * 100.0
            }
        }
        return rocDict
    }
}
