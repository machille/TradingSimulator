//
//  HistQuoteDownload.swift
//  Trading
//
//  Created by Maroun Achille on 31/12/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Foundation

class HistQuoteDownload {
    var hqdb: StockQuoteDB = StockQuoteDB.instance
    
    var stockHistArray: [StockHist]?
    var reload = false
    
    private var dateTo = Date()
    private var startDate = Date()
    private var test = 0
    
    @objc dynamic var isRunning: Bool = false
    var queue: OperationQueue
    var delegate: RunDelegate?
    
    var globalArray = AtomicArray<StockQuoteHist>()
    
    init(queue: OperationQueue) {
        self.queue = queue
    }

//MARK: -- Start Run
    func startRun() {
        isRunning = true
       
        startDate = Date()

        dateTo = Date()
        dateTo = CDate.lastOpenDate(date: dateTo)
        
        dspMessage ("Start Update Historic Quote \(dateTo) - Mode Update: \(reload) + Stock Number: \(numberOfRows()) at: \(startDate)")
                
        globalArray.removeAll()
        historicDelete()
        historicDownload()
        
        queue.waitUntilAllOperationsAreFinished()
        dspMessage ("End Update Historic Price \(dateTo) + Stock Number: \(numberOfRows())  at: \(Date()) \(startDate - Date())")
        
        
        dspMessage ("Start Update Stock Quote \(dateTo) at: \(Date()) \(startDate - Date())")
        queue.addOperation {
            self.updateStockQuote()
        }
        queue.waitUntilAllOperationsAreFinished()
        dspMessage ("End Update Stock Quote \(dateTo) at: \(Date()) \(startDate - Date())")
        globalArray.removeAll()
    }

    
    func stopRun() {
        isRunning = false
        queue.cancelAllOperations()
        dspMessage ( "stopRun Historic Quote" )
    }

    private func historicDownload () {
        
        guard let stockHistArray = stockHistArray else {
            dspMessage ("stockHistArray is empty")
            return
        }
        let counts = stockHistArray.reduce(into: [:]) { counts, stockRef in counts[stockRef.historicReference, default: 0] += 1 }
        dspMessage(counts.description)
       
        for (histRef, _) in counts {
            let refHistArray = stockHistArray.filter{( stock : StockHist) -> Bool in
                return stock.historicReference == histRef
            }
            
            runQueue(histRef: histRef, stockArray: refHistArray)
        }
       
        queue.waitUntilAllOperationsAreFinished()

        dspMessage ("End Download Run at: \(Date()) -- \(startDate - Date())  \(globalArray.count)")

        queue.waitUntilAllOperationsAreFinished()
        self.dspMessage("Start Insert Data Base for: \(globalArray.count)")
        insertQuote()
        dspMessage ("End Insert Data Base at: \(Date()) -- \(startDate - Date()) for: \(globalArray.count)")
    }
    
    private func runQueue(histRef: String, stockArray: [StockHist]) {
        
        let perThread = 70
        var ysplit = Int(round(Double(stockArray.count ) / Double(perThread)))
        
        if ysplit < 1 {
            ysplit = 1
        }
        var iFrom = 0
        var iTo = 0
        
        for n in 1...ysplit {
            iFrom = iTo
            if n == ysplit {
                iTo = stockArray.count
            } else {
                iTo = n * perThread
            }
        
            let splitArray = Array(stockArray[iFrom ..< iTo])
           
            if histRef == "STOOQ" {
                let stooqOperation = STOOQHistoric(stooqHistArray: splitArray, thread: n + 1, delegate: delegate)
                stooqOperation.completionBlock = {
                    if stooqOperation.isCancelled {
                        return
                    }
                    
                    if stooqOperation.sqhArray.count > 0 {
                        self.globalArray.append(contentsOf: stooqOperation.sqhArray)
                    }
                }
                queue.addOperation(stooqOperation)
                
            } else if histRef == "YAHOO" {
                let yahooOperation = YAHOOHistoric( yahooHistArray: splitArray, thread:  n + 1, delegate: delegate)
                yahooOperation.completionBlock = {
                    if yahooOperation.isCancelled {
                        return
                    }
                    if yahooOperation.sqhArray.count > 0 {
                        self.globalArray.append(contentsOf: yahooOperation.sqhArray)
                    }
                }
                queue.addOperation(yahooOperation)
 
            }
        }
    }
    
// MARK: delete historic quote
    private func historicDelete() {
        guard let stockHistArray = stockHistArray else {
            return
        }
        
        guard reload == true else {
            return
        }
        
        for stock in stockHistArray {
            if !isRunning {
                dspMessage ("Stoped Update Historic Price")
                break
            }
 
            dspMessage ("Delete Historic Quote from : \(stock.id) : \(stock.name)")
            do {
                try hqdb.histQuoteDelete(stockId: stock.id)
                stock.quoteDate = CDate.startDate()
                stock.upToDate = "New"
            } catch let error as SQLiteError {
                dspMessage( error.description)
            } catch let error {
                dspMessage("Other Error \(error)")
            }
        }
    }
  
//MARK: -- insert Historic Quote with Synchrone
    func insertQuote() {
        var cpt = 0
        var first = true
        var db2: SQLiteDB
      
        do {
            db2 = try hqdb.histQuoteBeginStatement()
        } catch let error as SQLiteError {
            dspMessage("Open DB \(error.description) ")
            return
        } catch let error {
            dspMessage("Open DB Other Error \(error)")
            return
        }
      
        for sqh in globalArray {
            cpt += 1
            do {
                if first {
                    try db2.beginTransaction()
                    first = false
                }

                try hqdb.histQuoteInsertBatch (db: db2, stockId: sqh.stockId, quoteDate: sqh.dateQuote, quoteOpen: sqh.open, quoteHigh: sqh.high, quoteLow: sqh.low, quoteClose: sqh.close, volume: sqh.volume)
     
                if ( ( cpt % 10000 ) == 0 )   {
                    try db2.commit()
                    dspMessage ("insertQuote Commit : \(cpt)")
                    first = true
                }
            
            } catch SQLiteError.Duplicate( _) {
       
            } catch let error as SQLiteError {
                dspMessage("\(error.description) Stock \(sqh.stockId) Quote Date \(CDate.defaultForamt(sqh.dateQuote)) ")
            } catch let error {
                dspMessage("Other Error \(error)")
            }
        }
  //MARK: -- Last commit
        do {
            try hqdb.histQuoteEndStatement(db: db2)
        } catch let error as SQLiteError {
            dspMessage("Commit \(error.description) ")
        } catch let error {
            dspMessage("Commit \(error)")
        }
    }

    func updateStockQuote() {
        do {
            try hqdb.truncateStockQuote()
            try hqdb.updateStockQuote()
            try hqdb.deleteOrphanQuote()
            
        } catch let error as SQLiteError {
            self.dspMessage("updateStockQuote : \(error.description)")
        } catch let error {
            self.dspMessage("updateStockQuote : Other Error \(error)")
        }
    }
   
    func numberOfRows() ->Int {
        return stockHistArray?.count ?? 1
    }
       
    func dspMessage (_ message: String) {
        if let delegate = self.delegate {
            delegate.dspMessage(message)
        } else {
            print(message)
        }
    }
}

//MARK: -- YAHOO Historic
class YAHOOHistoric: AsyncOperation {

    private var thread: Int
    private var yahooHistArray: [StockHist]
    private var dateTo = Date()
    private let dateFormatter = DateFormatter()
    var isRunning = true
    var sqhArray: [StockQuoteHist]
    
    private var delegate: RunDelegate?
    
    init(yahooHistArray: [StockHist], thread: Int, delegate: RunDelegate?) {
        self.thread = thread
        self.delegate = delegate
        self.yahooHistArray = yahooHistArray
        sqhArray = [StockQuoteHist]()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMD")
    }
    
    override func main () {
        dateTo = Date()
        dateTo = CDate.lastOpenDate(date: dateTo)
  
        for stock in yahooHistArray {
            if !isRunning {
                dspMessage("\(thread) Stopped Update Historic Price")
                break
            }
            
            if stock.upToDate == "Yes" {
                updateProgressBar ()
                continue
            }
  
            let nextDate = CDate.nextOpenDate(date: stock.quoteDate)
            let urlRef = "https://finance.yahoo.com/quote/\(stock.historicCode)/history"
        
            if let quoteDateStr = CDate.dateQuote(stock.quoteDate), let toDateStr = CDate.dateQuote(dateTo) {
                dspMessage("YAHOO: Start stock: \(stock.id): \(stock.name) Quote Date : \(quoteDateStr) To \(toDateStr) - \(thread)")
            }
  
            guard let urlString = urlRef.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                dspMessage("Error: cannot Encoding URL \(urlRef)")
                continue
            }
         
            guard let yahooHistURL = URL(string: urlString) else {
                dspMessage("Error: cannot create URL \(urlRef)")
                continue
            }

            do {
                let htmlData = try String(contentsOf: yahooHistURL)
                
                let splitPageData = htmlData.components(separatedBy: "}")
                
                var crumb = ""
                var rtn = ""
                
                for  line in splitPageData {
                    if line.contains("CrumbStore")  {
                        rtn = line
                        break
                    }
                }
                guard rtn != "" else {
                    dspMessage("CrumbStore Not Found for URL \(urlRef)")
                    continue
                }

                let vals = rtn.components(separatedBy: ":")                 // get third item
                let crumbTmp = vals[2].replacingOccurrences(of: "\"", with: "") // strip quotes
                    
                // unescape escaped values (particularly, \u002f
                let transform = "Any-Hex/Java"
                let crumbStore = crumbTmp as NSString
                let convertedString = crumbStore.mutableCopy() as! NSMutableString
                
                CFStringTransform(convertedString, nil, transform as NSString, true)
                crumb = convertedString as String
                
                guard crumb != ""  else {
                    dspMessage("crumb Not Found for URL \(urlRef)")
                    continue
                }

                let yahooQuote = "https://query1.finance.yahoo.com/v7/finance/download/\(stock.historicCode)?" +
                            "period1=\(String(format:"%.0f", CDate.timeStampFrom(date: nextDate)))&" +
                            "period2=\(String(format:"%.0f", CDate.timeStampTo(date: dateTo)))&" +
                            "&interval=1d&events=history&crumb=\(crumb)"
                
                guard let yahooQuoteStr = yahooQuote.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    dspMessage("Error: cannot Encoding URL \(yahooQuote)")
                    continue
                }

                guard let yahooQuoteURL = URL(string: yahooQuoteStr) else {
                    dspMessage("Error: cannot create URL \(yahooQuote)")
                    continue
                }
           
                let quoteData = try String(contentsOf: yahooQuoteURL)
              
                var quoteDate: Date
                var quoteOpen, quoteHigh, quoteLow, quoteClose, adjClose, volume, adjDiff :Double
            
                let lines = quoteData.split(separator: "\n", omittingEmptySubsequences: false)
                 
                for line in lines {
                    let stringValue = line.components(separatedBy: ",")
                    if stringValue[0].isEmpty || stringValue[0] == "Date"  || stringValue[0].starts(with: "{") || stringValue[0].hasPrefix("404 Not Found") {
                        continue
                    } else {
                        if let dateStr = self.dateFormatter.date(from: stringValue [0]) {
                            quoteDate = dateStr
                        } else {
                            dspMessage("-- Yahoo : Not a valid date for \(stock.id) : \(line)")
                            continue
                        }
                            
                        quoteClose = toDouble(stringValue [4])
                        if quoteClose == 0.0 {
                            dspMessage("-- Yahoo Close is Zero for : \(stock.id): \(line)")
                        } else {
                            quoteOpen = toDouble(stringValue [1])
                            quoteHigh = toDouble(stringValue [2])
                            quoteLow = toDouble(stringValue [3])
                            adjClose = toDouble(stringValue [5])
                            volume = toDouble(stringValue [6])
                            
                            adjDiff = (adjClose - quoteClose) / quoteClose
                            if adjDiff != 0.0 {
                                quoteClose = adjClose
                                quoteOpen = (quoteOpen * adjDiff) + quoteOpen
                                quoteHigh = (quoteHigh * adjDiff) + quoteHigh
                                quoteLow = (quoteLow * adjDiff) + quoteLow
                            }
                        
                            let sqh = StockQuoteHist(stockId: stock.id, dateQuote: quoteDate, close: quoteClose, open: quoteOpen, high: quoteHigh, low: quoteLow, volume: volume)
                            sqhArray.append(sqh)
                        }
                    }
                }

            } catch {
                dspMessage("Yahoo data not found for \(yahooHistURL)")
                continue
            }
            updateProgressBar()
        }
        self.finish()
    }

    override func cancel() {
        isRunning = false
        super.cancel()
    }
    
    func toDouble(_ value: String) -> Double {
        if let newValue = Double(value) {
            return newValue
        } else {
            return 0.0
        }
    }
    
    func updateProgressBar() {
        delegate?.updateProgressBar()
    }
    
    func dspMessage (_ message: String) {
        if let delegate = self.delegate {
            delegate.dspMessage(message)
        } else {
            print(message)
        }
    }
    
}

//MARK: -- STOOQ Historic
class STOOQHistoric: AsyncOperation {

    private var thread: Int
    private var stooqHistArray: [StockHist]
    private var dateTo = Date()
    private let dateFormatter = DateFormatter()
    private let dateFormatter2 = DateFormatter()
    var isRunning = true
    var sqhArray: [StockQuoteHist]
    
    private var delegate: RunDelegate?
    
    init(stooqHistArray: [StockHist], thread: Int, delegate: RunDelegate?) {
        self.thread = thread
        self.delegate = delegate
        self.stooqHistArray = stooqHistArray
        sqhArray = [StockQuoteHist]()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter2.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMD")
        dateFormatter2.timeZone = TimeZone(abbreviation: "GMD")
    }
    
    override func main () {
        dateTo = Date()
        dateTo = CDate.lastOpenDate(date: dateTo)
  
        for stock in stooqHistArray {
            if !isRunning {
                dspMessage("Stoped Update Historic Price")
                break
            }
            
            if stock.upToDate == "Yes" {
                updateProgressBar ()
                continue
            }
            
            if let quoteDateStr = CDate.dateToDB(stock.quoteDate), let toDateStr = CDate.dateToDB(dateTo) {
                dspMessage("STOOQ: Start stock : \(stock.id) : \(stock.name) Quote Date : \(quoteDateStr) To \(toDateStr)")
            }
            
            let nextDate = CDate.nextOpenDate(date: stock.quoteDate)
            let urlStr = "https://stooq.com/q/d/l/?s=\(stock.historicCode)" +
                  "&d1=\(dateFormatter2.string(from: nextDate))&d2=\(dateFormatter2.string(from: dateTo))&i=d"

            if let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        
                guard let stooqHistURL = URL(string: urlString) else {
                    dspMessage("Error: cannot create stooqHist URL \(urlStr)")
                    continue
                }
            
                do {
                    let htmlData = try String(contentsOf: stooqHistURL)
                    let lines = htmlData.split(separator: "\r\n", omittingEmptySubsequences: false)
                    var quoteDate: Date
                    var quoteOpen, quoteHigh, quoteLow, quoteClose, volume :Double
                    
                    for line in lines {
                        let stringValue = line.components(separatedBy: ",")
                        if stringValue[0].isEmpty || stringValue [0] == "Date" {
                            continue
                        } else {
                            if let dateStr = self.dateFormatter.date(from: stringValue [0]) {
                                quoteDate = dateStr
                            } else {
                                dspMessage("-- STOOQ Not a valid date for : \(stock.id) : \(line)" )
                                continue
                            }
                            quoteClose = toDouble(stringValue [4])
                            if quoteClose == 0.0 {
                                dspMessage("-- STOOQ Close is Zero for : \(stock.id) : \(line)")
                            } else {
                                quoteOpen = toDouble(stringValue [1])
                                quoteHigh = toDouble(stringValue [2])
                                quoteLow = toDouble(stringValue [3])
                        
                                if stringValue.count > 5 {
                                    volume = toDouble(stringValue [5])
                                } else {
                                    volume = 0.0
                                }
                                let sqh = StockQuoteHist(stockId: stock.id, dateQuote: quoteDate, close: quoteClose, open: quoteOpen, high: quoteHigh, low: quoteLow, volume: volume)
                                sqhArray.append(sqh)
        
                            }
                        }
                    } // for lines
                } catch {
                    dspMessage("STOOQ data not found for \(stooqHistURL)")
                    continue
                }
            }
            updateProgressBar()
        }
        self.finish()
    }

    override func cancel() {
        isRunning = false
        super.cancel()
    }
    
    func toDouble(_ value: String) -> Double {
        if let newValue = Double(value) {
            return newValue
        } else {
            return 0.0
        }
    }
    
    func updateProgressBar() {
        delegate?.updateProgressBar()
    }
    
    func dspMessage (_ message: String) {
        if let delegate = self.delegate {
            delegate.dspMessage(message)
        } else {
            print(message)
        }
    }
}
