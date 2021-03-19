//
//  HighLow.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class HighLow {
    static func highestHigh(period: Int, dict: [Date: Double]) -> [Date : Double] {
        
        var highHighDict = [Date: Double] ()
        var highDict = [Date: Double] ()
        
        var j :Int = 0
        var first = true
        var yValue = 0.0, extermeValue = 0.0
        
        var arHigh = Array(repeating: 0.0, count: period)
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            arHigh[j] = element
            j = (j  + 1 ) % period
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                for arHighValue in arHigh {
                    extermeValue = max(extermeValue , arHighValue)
                }
                highDict[key] = extermeValue
                extermeValue = 0.0
            }
        }
        //Take yesterday higher High for today
        first = true
        
        let tempDict2 = highDict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict2 {
            if first  {
                first = false;
                yValue = element
            } else {
                highHighDict[key] = yValue
                yValue = element
            }
        }
        return highHighDict
    }
    
    static func lowestLow (period: Int, dict: [Date: Double]) -> [Date : Double] {
        
        var lowestLowDict = [Date: Double] ()
        var lowDict = [Date: Double] ()
        
        var j :Int = 0
        var first = true
        var yValue = 0.0, extermeValue = 9999999999.0
        
        var arLow = Array(repeating: 0.0, count: period)
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            arLow[j] = element
            j = (j  + 1 ) % period
            
            if j == 0 && first {
                first = false
            }
            
            if !first {
                for arLowValue in arLow {
                    extermeValue = min(extermeValue , arLowValue)
                }
                lowDict[key] = extermeValue
                extermeValue = 9999999999.0
            }
        }
        //Take yesterday lowest Low for today
        first = true
        
        let tempDict2 = lowDict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict2 {
            if first  {
                first = false;
                yValue = element
            } else {
                lowestLowDict[key] = yValue
                yValue = element
            }
        }
        return lowestLowDict
    }

    // TODO: Add Centerline: (20-day high + 20-day low)/2
}
