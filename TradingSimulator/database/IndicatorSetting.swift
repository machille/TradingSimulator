//
//  IndicatorSetting.swift
//  Trading
//
//  Created by Maroun Achille on 04/03/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class IndicatorSetting {

    var id: String
    var desc: String
    var model: String // Line or Histograme or point
    var type: String  // Trend follow or Osciator or Chart
    var value1: Double
    var value2: Double
    var value3: Double
    var color1: NSColor
    var color2: NSColor
    
    var splineValue1: String //if value != nil then is active
    var splineColor1: NSColor
    var splineValue2: String //if value != nil then is active
    var splineColor2: NSColor
    var splineZero: String
    var splineColor0: NSColor
    
    var maValue1: Double // if value != 0 then is active
    var maColor1: NSColor
    var maType1: String // SMA, EMA
    var maValue2: Double // if value != 0 then is active
    var maColor2: NSColor
    var maType2: String // SMA, EMA
    
    public var description: String {
        return "Indicator: \(id) : \(desc) Model: \(model) Type: \(type)"
    }
    
    init() {
        
        id = ""
        desc = "Default"
        model = "Line"// Line or Histograme or point
        type = "Trend Follow"  // Trend follow or Osciator
        value1 = 0.0
        value2 = 0.0
        value3 = 0.0
        color1 = NSColor(hex: "#32d82f")! //green
        color2 = NSColor(hex: "#ff0000")! //red
        
        splineValue1 = ""
        splineColor1 = NSColor(hex: "#ffffff")! //white
        splineValue2 = ""
        splineColor2 = NSColor(hex: "#ffffff")! //white
        splineZero = "0"
        splineColor0 = NSColor(hex: "#ffffff")! //white
        
        maValue1 = 0.0
        maColor1 = NSColor(hex: "#ffffff")! //white
        maType1 = "SMA"
        maValue2 = 0.0
        maColor2 = NSColor(hex: "#ffffff")! //white
        maType2 = "SMA"
    }
}
