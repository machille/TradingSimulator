//
//  RSSViewController2.swift
//  TradingSimulator
//
//  Created by Maroun Achille on 04/02/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class RSSViewController: NSViewController {
    
    private let question = "RSS news"
    private let cellIdentifier =  "rssImageCell"
    private let irss: InternetRSS  = InternetRSS.instance
    
    @IBOutlet weak var tableView: NSTableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.target = self
            tableView.doubleAction = #selector(tableViewDoubleClick(_:))
            tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
            tableView.backgroundColor = NSColor.black
        }
        
        override func viewWillAppear() {
            irss.addActionDelegate(name: "RSS2", controller: self)
        }
        
        override func viewDidDisappear() { 
            irss.removeActionDelegate(name: "RSS2")
        }
        
        func reloadRssList() {
            tableView.reloadData()
            tableView.scrollRowToVisible(irss.elements.count - 1)
        }
        
        @objc func tableViewDoubleClick(_ sender:AnyObject) {
            guard tableView.selectedRow >= 0
            else {
                return
            }
            let item = irss.elements[tableView.selectedRow]
            if let url = URL(string: item.link) {
                NSWorkspace.shared.open(url)
            }
        }
        
        func dspAlert(text: String) {
            Message.messageAlert(question, text: text)
        }
    }

extension RSSViewController: QuoteDelegate {
    func reloadQuote() {
        DispatchQueue.main.async {
            self.reloadRssList()
        }
    }
}

extension RSSViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return irss.elements.count
    }
}

extension RSSViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            
        let item = irss.elements[row]
      
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = item.title
            return cell
        }
        return nil
    }
}
