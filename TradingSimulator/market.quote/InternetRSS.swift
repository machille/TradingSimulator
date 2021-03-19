//
//  InternetRSS.swift
//  Trading
//
//  Created by Maroun Achille on 11/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//
// http://blue-bear.jp/kb/swift4-read-xml-via-xmlparser-and-reflect-with-tableview/

import Cocoa

class InternetRSS: NSObject {
    static let instance = InternetRSS()
    var trDB: TableRowDB
    private let question = "Internet RSS"
    
    private var delegateDict = [String : QuoteDelegate]()
    var dateFormatter = DateFormatter()

    //for current Element
    var currentElementName : String!
    
    //First Element name
    let itemElementName : String  = "item"
    
    //Element name under item element
    let titleElementName   : String = "title"
    let descElementName    : String = "description"
    let linkElementName    : String = "link"
    let pubDateElementName : String = "pubDate"

    
    //variable for each element
    var elements = [RSSEntry]()
    
    var element:String!
    var title:String! = ""
    var desc:String!  = ""
    var link:String!  = ""
    var strDate:String!  = ""
    //var pubDate:Date!
    @objc dynamic var newCpt: Int = 0
    @objc dynamic var rssName:String!  = ""
    
    @objc dynamic var isRunning: Bool = false
    @objc dynamic var textView: NSTextView!
    
    private override init() {
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm"
        trDB = TableRowDB(columns: ["DESCRIPTION", "VALUE_1"], tableName: "TTABLES", whereExpr: "TABLE_NAME = 'RSS' AND FLAG1='1'")
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
    
    public func startReader() {
        do {
            try trDB.readTable()
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
            return
        } catch let error {
            dspAlert(text: "Other Error \(error)")
            return
        }
        isRunning = true
        
        let cqueue = DispatchQueue(label: "cqueue.rss")
        cqueue.async { self.readRSS()}
    }
    
    private func fireAction() {
        for (_, delegate) in delegateDict {
            delegate.reloadQuote()
        }
    }

    private func readRSS() {
        var test = 0
        var notFirst = false
        
        while isRunning {
            if test == 5 {
                stopReader()
            }
            
            if notFirst {
                sleep(7)
            } else {
                notFirst = true
            }
            
            for row in trDB.rowTable {
                let rowData = row as! [Any]
                self.rssName = rowData[0] as? String
                let urlStr = rowData[1] as! String
                
                let url = NSURL(string: urlStr)
                let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
                    self.rssName = url?.host
                    guard error == nil else {
                        self.dspMessage("error calling GET on \(String(describing: url)) \n \(error!))")
                        test = test + 1
                        return
                    }
                    
                    if data == nil {
                        self.dspMessage("dataTaskWithRequest error: \(String(describing: error?.localizedDescription))")
                        test = test + 1
                        return
                    }
                    
                    let parser = XMLParser(data: data!)
                    parser.delegate = self
                    parser.parse()
                    
                }
                task.resume()
            }
        }
    }
    
    public func stopReader() {
        isRunning = false
    }
        
    private func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    private func dspMessage (_ message: String) {
        if let text = textView {
            DispatchQueue.main.async {
                text.textStorage?.append(NSAttributedString(string: message))
                text.textStorage?.append(NSAttributedString(string:"\r\n"))
            }
        } else {
            print(message)
        }
    }
}

 //MARK:- XML Delegate methods

extension InternetRSS: XMLParserDelegate {
    //Start to read XML
    func parserDidStartDocument(_ parser: XMLParser) {
        self.newCpt = 0
      
    }
    
    //Complete to read XML
    func parserDidEndDocument(_ parser: XMLParser) {
        if self.newCpt != 0 {
            fireAction()
        }
    }
    
    //Start to read each element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.element = elementName as String
        
        //Initiate each variable for element once find "item" element
        if (elementName as NSString).isEqual(to: self.itemElementName) {
            self.title = ""
            self.desc = ""
            self.link = ""
            self.strDate = ""
        }
    }
    
    //Method when find each element on "item" element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if self.element.isEqual(self.titleElementName) {
            self.title.append(strip(str:string))
        }
        
        if self.element.isEqual(self.descElementName) {
            self.desc.append(strip(str:string))
        }
        
        if self.element.isEqual(self.linkElementName) {
            self.link.append(strip(str:string))
        }
        
        if self.element.isEqual(self.pubDateElementName) {
            self.strDate.append(strip(str:string))
        }
    }
    
   
    func strip(str: String) -> String {
        var strBr: String
        var strSp: String
        strBr = str.replacingOccurrences(of:"\n", with: "")
        strSp = strBr.trimmingCharacters(in: .whitespaces)
        return strSp
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqual(to: self.itemElementName) {
            
            if !self.title.isEqual(nil) && !self.desc.isEqual(nil) && !self.link.isEqual(nil) && !self.strDate.isEqual(nil) {
                let index = strDate.index(strDate.startIndex, offsetBy: 22)
                let str = strDate[..<index]

                if let pubDate = dateFormatter.date(from: String(str)) {
                    let rssEnt = RSSEntry(rssName: self.rssName, title: self.title, desc: self.desc, link: self.link, pubDate: pubDate)
                    addElement(rssEnt)
                } else {
                    let rssEnt = RSSEntry(rssName: self.rssName,title: self.title, desc: self.desc, link: self.link, pubDate: Date())
                    addElement(rssEnt)
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        dspMessage("parseErrorOccurred: \(parseError)")
    }
    
    func addElement(_ value: RSSEntry) {
        if !self.elements.contains(value) {
            self.elements.append(value)
            self.newCpt = self.newCpt + 1
        }
    }
    
}
