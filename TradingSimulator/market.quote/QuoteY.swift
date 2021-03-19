//
//  QuoteY.swift
//  Trading
//
//  Created by Maroun Achille on 03/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//
import Foundation

struct Result: Codable {
    var language: String
    var quoteType: String
    //var currency: String
    var fiftyTwoWeekRange: String!
    var regularMarketChangePercent: Double!
    var regularMarketPreviousClose: Double!
    var fiftyTwoWeekLow: Double!
    var fiftyTwoWeekHigh: Double!
    //var priceHint: Double
    var regularMarketPrice: Double!
    var regularMarketTime: Double!
    var regularMarketChange: Double!
    var regularMarketOpen: Double!
    var regularMarketDayHigh: Double!
    var regularMarketDayLow: Double!
    var exchange: String!
    // var shortName: String
    var marketState: String!
    var regularMarketDayRange: String!
    var fullExchangeName: String!
    var market: String!
    var tradeable: Bool!  // bool
    var sourceInterval: Double!
    var exchangeTimezoneName:  String!
    var exchangeTimezoneShortName: String!
    var gmtOffSetMilliseconds: Double!
    var exchangeDataDelayedBy: Double!
    var symbol: String
    var fiftyTwoWeekLowChange: Double!
    var fiftyTwoWeekLowChangePercent: Double!
    var fiftyTwoWeekHighChange: Double!
    var fiftyTwoWeekHighChangePercent: Double!
    var regularMarketVolume: Double!
    //    var esgPopulated: Bool! // bool
    var quoteSourceName: String!
}

struct QuoteResponse: Codable  {
    var result: [Result]
    var error: String!
}

struct Quote: Codable {
    var quoteResponse: QuoteResponse
}

