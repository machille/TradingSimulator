//
//  Chart.swift
//  Trading
//
//  Created by Maroun Achille on 07/04/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class Chart {
    var id: String
    var desc: String
    var model: String // JP, line etc
    var type: String  // Daily - Weekly
    var period: String // 9M, 7Y
    var beginPeriod: String // 9M, 7Y
    var backColor: NSColor
    var headColor: NSColor
    var lineColor: NSColor // and headColor
    var columnColor: NSColor
    var defaultColor: NSColor  // line color, HL Color
    var jcHighColor: NSColor
    var jcLowColor: NSColor
    var order: Int32
    var selected: String
    
    public var description: String {
        return "Chart: \(id) : \(desc) Model: \(model) Type: \(type)"
    }
    
    init() {
        id = "DAILY"
        desc = "Daily"
        model = "Japanese Candle"
        type = "Daily"
        period = "9 Months"
        beginPeriod = "0 Months"
        backColor = NSColor(hex: "#000000")! // black
        headColor = NSColor(hex: "#ffffff")! //white
        lineColor = NSColor(hex: "#0433FF")! //blue
        columnColor = NSColor(hex: "#EBEBEB")! //white
        defaultColor = NSColor(hex: "#EBEBEB")! //white
        jcHighColor = NSColor(hex: "#32D82F")! //green
        jcLowColor = NSColor(hex: "#ff0000")! //red
        order = 10
        selected = "0"
    }
}
