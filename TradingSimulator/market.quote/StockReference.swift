//
//  StockReference.swift
//  Trading
//
//  Created by Maroun Achille on 01/07/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation


class StockReference {
    
    var referenceId: String
    var referenceUrl: String
    var internetUrlDict = [String: [URL]]()
    
    init (referenceId: String, referenceUrl: String) {
        self.referenceId = referenceId
        self.referenceUrl = referenceUrl
    }
    
    
    func clearUrl() {
        internetUrlDict.removeAll()
    }
    
    func addUrl(marketPlace: String, urlStr: String) {
        
        let urlStr = urlStr.replacingOccurrences(of: "^", with: "%5E")
        
        guard let url = URL(string: urlStr) else {
            print("Error: cannot create URL")
            return
        }
        
        if internetUrlDict[marketPlace] != nil {
            var urlUpd: [URL] = internetUrlDict[marketPlace]!
            urlUpd.append(url)
            internetUrlDict[marketPlace] = urlUpd
        } else {
            var urlsNew = [URL]()
            urlsNew.append(url)
            internetUrlDict[marketPlace] = urlsNew
        }
    }
    
    public var description: String {
        return ("StockReference [referenceId= \(referenceId), referenceUrl= \(referenceUrl), internettUrlMap= [\(internetUrlDict.description)]")
    }
}
