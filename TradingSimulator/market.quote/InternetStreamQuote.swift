//
//  InternetStreamQuote.swift
//  Trading
//
//  Created by Maroun Achille on 08/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class InternetStreamQuote {
    
    static let instance = InternetStreamQuote()
    private let sdpDB = StockDayQuoteDB.instance
    private let question = "Internet Stream Quote"
    
    private var stockRefArray : [StockReference]
    @objc dynamic var isRunning: Bool = false
    @objc dynamic var textView: NSTextView!
    
    private var delegateDict = [String : QuoteDelegate]()
    
    let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
        
        stockRefArray = sdpDB.stockRefArray
    }
    
    func addActionDelegate(name: String, controller: QuoteDelegate) {
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
    
    func dspMessage (_ message: String) {
        if let text = textView {
            DispatchQueue.main.async {
                text.textStorage?.append(NSAttributedString(string: message))
                text.textStorage?.append(NSAttributedString(string:"\r\n"))
            }
        } else {
            NSLog(message)
        }
    }
    
    
    private func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    func startRead() {
        if self.isRunning {
            return
        }
        self.isRunning = true

        let cqueue = DispatchQueue(label: "cqueue.quote")
        cqueue.async { self.readQuote()
        }
    }
    
    func stopRead() {
        self.isRunning = false
        sdpDB.resetStatus()
        fireAction()
    }
    
    private func fireAction() {
        for (_, delegate) in delegateDict {
            delegate.reloadQuote()
        }
    }
    
    private func readQuote() {
        var notFirst = false
        
        while self.isRunning {

            self.fireAction()
            if notFirst {
               sleep(1)
            } else {
                notFirst = true
            }
            
           if  self.sdpDB.stockRefArray.count < 1  {
                self.dspAlert(text: " ************** No Reference URL **********************" )
                self.isRunning = false
                return
            }
            
            for stockRef in self.stockRefArray {
                
                for (_, urlArray) in  stockRef.internetUrlDict {
                    
                    for url in urlArray {
                        if stockRef.referenceId == "YAHDLY" {
                          
                            session.dataTask(with: url, completionHandler: {
                                data, response, error in
                                guard error == nil else {
                                    self.dspMessage("error calling GET on \(url)")
                                    return
                                }
                                
                                guard let data = data else {
                                    self.dspMessage("Error: did not receive data")
                                    return
                                }
                                
                                do {
                                    let jsonDecoder = JSONDecoder()
                                    let quote = try jsonDecoder.decode(Quote.self, from: data)
                                     
                                    for result in quote.quoteResponse.result {
                                        
                                        if let time = result.regularMarketTime {
                                            self.sdpDB.updateDayQuote (stockRef: result.symbol,
                                                              dateQuote: CDate.getTime(time),
                                                              last: result.regularMarketPrice,
                                                              change: result.regularMarketChange,
                                                              varChange: result.regularMarketChangePercent,
                                                              open: result.regularMarketOpen,
                                                              high: result.regularMarketDayHigh,
                                                              low: result.regularMarketDayLow,
                                                              volume: result.regularMarketVolume)
                                            
                                        } else {
                                            self.sdpDB.updateDayQuote (stockRef: result.symbol,
                                                                       dateQuote: Date(),
                                                                       last: 0.0,
                                                                       change: 0.0,
                                                                       varChange: 0.0,
                                                                       open: 0.0,
                                                                       high: 0.0,
                                                                       low: 0.0,
                                                                       volume: 0.0)
                                        }
                                       
                                    }
                                } catch let jsonErr {
                                    self.dspMessage(" error trying to convert the data to JSON using Quote\(jsonErr)")
                                    return
                                }
                                if !self.isRunning {
                                    self.sdpDB.resetStatus()
                                }
                            }).resume()
                        } // if stockRef.referenceId
                    } // for url
                } // for  (marketPlace, urlArray)
            }  // for stockRef
        } // while
    }
}
