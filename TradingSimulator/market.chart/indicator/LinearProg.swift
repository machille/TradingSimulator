//
//  LinearProg.swift
//  Trading
//
//  Created by Maroun Achille on 06/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class LinearProg {

    static func linear(period: Int, linearAB: String, dict: [Date: Double]) -> [Date : Double] {
        
        var linearDict = [Date: Double] ()
        let periodD = Double(period)
        
        let sumPeriod = periodD * (periodD + 1.0) / 2.0
        let sumSqrPeriod = (periodD + 1) * periodD * (2.0 * periodD + 1.0) / 6.0
        let slopeAdiv = periodD * sumSqrPeriod - sumPeriod * sumPeriod
        
        var first = true
        var sumY = 0.0, sumXY = 0.0
        var j: Int = 0
        var slopeA = 0.0, interceptB = 0.0, linearRegValue = 0.0
        
        var arlinear = Array(repeating: 0.0, count: period)
        
        
        //let dateFormatter2 = DateFormatter()
        //dateFormatter2.dateFormat = "EE ww dd-MM-yy"
        //dateFormatter2.timeZone = TimeZone(abbreviation: "GMD")
        
        let tempDict = dict.sorted{ $0.key < $1.key }
        for (key, element) in tempDict {
            
            arlinear[j] = element
            if first {
                j = (j  + 1 ) % period
                if j == 0 {
                    first = false
                }
            }
            
            if !first {
                for index in 0..<period {
                    sumXY += Double(index + 1) * arlinear[index]
                    sumY += arlinear[index]
                    //print(" index \(index) sumXY  \(sumXY)  \(arlinear[index])")
                }
                //print ("Date \(dateFormatter2.string(from: key))  sumXY = \(sumXY)  sumY = \(sumY)" )
                
                //arlinear[0...period-1] = arlinear[1...arlinear.count-1]
                
                //if !first { return linearDict }
                
                for index in 0..<period-1 {
                    arlinear[index] = arlinear[index + 1]
                }
                
                slopeA = (periodD * sumXY - sumPeriod * sumY ) / slopeAdiv
                interceptB = (sumY - slopeA * sumPeriod) / periodD
                linearRegValue = interceptB + slopeA * (periodD + 1.0)
                
                j = period - 1
                sumXY = 0.0
                sumY = 0.0
                
                if linearAB == "SLOPE" {
                    linearDict[key] = slopeA
                } else if linearAB == "INTERCEPT" {
                    linearDict[key] = interceptB
                } else {
                     linearDict[key] = linearRegValue
                }
            }
        }
        return linearDict
    }
    
    static func slopeB(period: Int, dict: [Date: Double]) -> [Date : Double] {
        return linear(period: period, linearAB: "SLOPE", dict: dict)
    }
    
    static func interceptA(period: Int, dict: [Date: Double]) -> [Date : Double] {
        return linear(period: period, linearAB: "INTERCEPT", dict: dict)
    }
    
    static func linearReg(period: Int, dict: [Date: Double]) -> [Date : Double] {
        return linear(period: period, linearAB: "LINEAR", dict: dict)
    }
    
    
    
    
}
