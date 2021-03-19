//
//  ChartDefaultValue2.swift
//  Trading
//
//  Created by Maroun Achille on 26/09/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa


public enum DrawToolsModel: String, CaseIterable {
    case Line
    case TPosition
    case Fibonacci
    
    static var allValues: [String] {
        var values = [String]()
        for value in self.allCases {
            values.append(value.rawValue)
        }
        return values
    }
}


public enum AverageType: String, CaseIterable  {
    case SMA
    case EMA
    static var allValues: [String] {
        var values = [String]()
        for value in self.allCases {
            values.append(value.rawValue)
        }
        return values
    }
}


public enum ChartModel: String, CaseIterable {
    case LineChart = "Line Chart"
    case BarsChart = "Bars Chart"
    case JapaneseCandle = "Japanese Candle"
    static var allValues: [String] {
        var values = [String]()
        for value in self.allCases {
            values.append(value.rawValue)
        }
        return values
    }
}


public enum ChartType: String, CaseIterable {
    case Weekly
    case Daily
    static var allValues: [String] {
        var values = [String]()
        for value in self.allCases {
            values.append(value.rawValue)
        }
        return values
    }
}


public enum IndicatorModel: String, CaseIterable {
    case Line
    case Histogram
    case Point
    static var allValues: [String] {
        var values = [String]()
        self.allCases.forEach {
            values.append($0.rawValue)
        }
        return values
    }
}


public enum IndicatorType: String, CaseIterable {
    case Oscillator
    case Follow = "Trend Follow"
    case Chart
    case Point
    static var allValues: [String] {
        var values = [String]()
        self.allCases.forEach {
            values.append($0.rawValue)
        }
        return values
    }
}

struct ChartDefaultValue {

    static let menuPeriod = ["3 Months", "6 Months", "9 Months", "1 Year" , "2 Years" , "3 Years" , "5 Years" , "7 Years" ]
    static let beginPeriod = ["0 Day", "1 Day" , "1 Month" , "2 Months", "3 Months", "4 Months", "5 Months" , "6 Months" , "1 Year",  "2 Years" , "3 Years", "4 Years", "5 Years", "7 Years"]

    static let colorArray: [String] = ["#f1ede9", "#07eb96", "#ccaa87", "#ff0066", "#00ffff", "#0abde3", "#e3dbd2", "#ffff09", "#389f3f" ]
    static var j: Int = 0
        
    var j: Int = 0 // for color switch

    static let stopDict : [String: String] = ["Kase UP" : "KASEUP" ,
                                              "Kase Down" : "KASEDW",
                                              "Chandelier Up" : "CHEXUP",
                                              "Chandelier Down" : "CHEXDW",
                                              "Safe Zone Up" : "SFZUP",
                                              "Safe Zone Down" : "SFZDW",
                                            ]
    static var stopList : [String] {
        return stopDict.keys.sorted()
    }
    
    static func textWidth(text: String) -> CGFloat {
        let attributes = ChartDefaultValue.font != nil ? [NSAttributedString.Key.font: ChartDefaultValue.font] : [:]
        return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
    }

    static func textBoldWidth(text: String) -> CGFloat {
        let attributes = ChartDefaultValue.font != nil ? [NSAttributedString.Key.font: ChartDefaultValue.headerFont] : [:]
        return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
    }
    
    static let greenColor = NSColor(hex: "#3ef63e")!
    static let backGreenColor = NSColor(hex: "#19B919")!
    static let redColor = NSColor(hex: "#ff1132")! // #FF2F2F")! #e9e1d9
    static let backRedColor = NSColor(hex: "#ff1919")!
    static let backWhiteColor = NSColor(hex: "#e4e7e4")!
    static let whiteColor = NSColor.white
    static let blackColor = NSColor.black
    static let stopColor = NSColor(hex: "#fa9d57")!
    static let alertColor = NSColor(hex: "#FFB2B2")!

    static let box1Color = NSColor(hex: "#32d82f")! //green
    static let box2Color = NSColor(hex: "#ef2864")! //magenta

    static let font = NSFont(name: "Helvetica", size: 13)
    static let fontSize: CGFloat = 13
    
    static let headerFont = NSFont.boldSystemFont(ofSize: 12)
    
    
    static let fontHeight = ChartDefaultValue.font?.boundingRectForFont.height ?? 20
    static let fontWidth = ChartDefaultValue.font?.boundingRectForFont.width ?? 70

    static let scaleLigneD: CGFloat = 20.0
    static let hh: CGFloat = 30.0
    static let hhIndic: CGFloat = 4.0
    static let ww: CGFloat = 5.0
    static let wMargin: CGFloat = 8.0
    static let dateFormat = "MMM-yy"
 
}
