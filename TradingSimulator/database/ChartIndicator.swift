//
//  ChartIndicator.swift
//  Trading
//
//  Created by Maroun Achille on 08/03/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartIndicator {
    var id: String
    var chartId: String
    var indicatorId: String
    var indicatorDesc: String
    var defaultValue: String
    var value1: Double
    var value2: Double
    var value3: Double
    var color1: NSColor
    var color2: NSColor
    var active: String
    
    public var description: String {
        return "Chart: \(chartId) Indicator: \(indicatorId)  \(indicatorDesc) default Value: \(defaultValue)"
    }
    
    init() {
        id = "-1"
        chartId = ""
        indicatorId = ""
        defaultValue = "1"
        indicatorDesc = ""
        value1 = 0.0
        value2 = 0.0
        value3 = 0.0
        color1 = NSColor(hex: "#000000")! // black
        color2 = NSColor(hex: "#000000")! // black
        active = "1"
    }
}
