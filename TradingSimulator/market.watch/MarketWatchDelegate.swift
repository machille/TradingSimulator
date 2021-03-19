//
//  MarketFireActionDelegate.swift
//  Trading
//
//  Created by Maroun Achille on 20/11/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Foundation

protocol MarketWatchDelegate: class  {
    func setIndex(indexId: String)
    func setWatchList(watchListId: Int)
    func watchAllChart()
}


class MarketWatchActionDelegate {

    static let instance = MarketWatchActionDelegate()
    private var delegateDict = [String : MarketWatchDelegate]()
    
    
    private init() {
    }
    
    func addActionDelegate(name: String, controller: MarketWatchDelegate) {
        if delegateDict[name] != nil {
            return
        } else {
            delegateDict[name] = controller
        }
    }
    
    func removeActionDelegate(name: String) {
        if delegateDict[name] != nil {
            delegateDict.removeValue(forKey: name)
        }
    }
    
    func setIndex(name: String, indexId: String) {
        if let delegate = delegateDict[name] {
            delegate.setIndex(indexId: indexId)
        }
    }
    
    func setWatchList(name: String, watchListId: Int) {
        if let delegate = delegateDict[name] {
            delegate.setWatchList(watchListId: watchListId)
        }
    }
    
    func watchAllChart(name: String) {
        if let delegate = delegateDict[name] {
            delegate.watchAllChart()
        }
    }
}
