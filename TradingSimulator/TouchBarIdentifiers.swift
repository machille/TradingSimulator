//
//  TouchBarIdentifiers.swift
//  Trading
//
//  Created by Maroun Achille on 19/01/2021.
//  Copyright © 2021 Maroun Achille. All rights reserved.
//

import Cocoa

extension NSTouchBarItem.Identifier {
    static let startItem = NSTouchBarItem.Identifier("com.quote.StartItem")
    static let stopItem = NSTouchBarItem.Identifier("com.quote.StopItem")
    static let allChartItem = NSTouchBarItem.Identifier("com.quote.AllChartItem")
    static let simuItem = NSTouchBarItem.Identifier("com.simu.SimuItem")
    static let histQuoteItem = NSTouchBarItem.Identifier("com.quote.HistQuoteItem")
 
}

extension NSTouchBar.CustomizationIdentifier {
    static let quoteBar = NSTouchBar.CustomizationIdentifier("com.trading.MarketWatchViewController.QuoteBar")
    
}
