//
//  calculate.swift
//  Trading
//
//  Created by Maroun Achille on 25/09/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class Calculate  {
    
    static func formatNumberCurrency (_ dec: Int, _ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.maximumFractionDigits = dec
        formatter.locale = .current
        return formatter.string(from: value as NSNumber) ?? "0.0"
    }
    
    static func formatNumber (_ dec: Int, _ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = dec
        formatter.minimumFractionDigits = dec
        formatter.numberStyle = .decimal
        return formatter.string(from: value as NSNumber) ?? "0.0"
    }
    
    static func formatVar (_ dec: Int, _ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = dec
        formatter.minimumFractionDigits = dec
        //formatter.numberStyle = .decimal
        formatter.numberStyle = NumberFormatter.Style.percent
        return formatter.string(from: value as NSNumber) ?? "0.0"
    }
    
    static func roundnumber (_ value: Double, _ dec: Double) -> Double {
        let multiplier = pow(10.0, dec)
        let rounded: Double = round(value * multiplier) / multiplier
        return rounded
    }
    
    static func leftPad(value: String, toLength: Int, withPad: String) -> String {
        if value.count >= toLength {
            return value
        } else {
            let remainingLength: Int = toLength - value.count
            var padString = String()
            for _ in 0 ..< remainingLength {
                padString += withPad
            }
            
            return "\(padString)\(value)"
        }
    }
    
    static func rightPad(value: String, toLength: Int, withPad: String) -> String {
        if value.count >= toLength {
            return value
        } else {
            let remainingLength: Int = toLength - value.count
            var padString = String()
            for _ in 0 ..< remainingLength {
                padString += withPad
            }
            
            return "\(value)\(padString)"
        }
    }
}

