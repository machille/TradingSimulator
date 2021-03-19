//
//  QuoteIndexViewController2.swift
//  Trading
//
//  Created by Maroun Achille on 07/09/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class QuoteIndexViewController: NSViewController {
    let question = "Quote Index"
    var textColor: NSColor = NSColor.green
    var backColor: NSColor = NSColor.black
    var backColor2: NSColor = NSColor.black
      
    let idqDB: IndexDailyQuoteDB  = IndexDailyQuoteDB.instance
    var indexArray: [StockDayQuote]?

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.backgroundColor = NSColor.black
        
        // replacing tableViewSelectionDidChange due to switching beteween tableView with the same target
        tableView.action = #selector(onItemClicked)
        
        readIndexTable()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        InternetStreamQuote.instance.addActionDelegate(name: "INDEX", controller: self)
    }
        
    override func viewDidDisappear() {
        super.viewDidDisappear()
        InternetStreamQuote.instance.removeActionDelegate(name: "INDEX")
    }

    private func readIndexTable() {
        indexArray = idqDB.getAllIndex()
        reloadIndexList()
    }
    
    private func reloadIndexList() {
        tableView.reloadData()
    }
        
    @objc private func tableViewDoubleClick(_ sender:AnyObject) {
        guard tableView.selectedRow >= 0,
        let item = indexArray?[tableView.selectedRow] else {
            return
        }
        let chartF = ChartWindowFactory.instance
        chartF.setStockId(id: item.id)
        chartF.show()
    }
        
    @objc private func onItemClicked() {
        if tableView.clickedRow > -1 {
            guard let item = indexArray?[tableView.clickedRow] else {
                return
            }
            MarketWatchActionDelegate.instance.setIndex(name: "STOCK", indexId: item.id)
        }
    }
    
    private func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
}

extension QuoteIndexViewController: QuoteDelegate {
    func reloadQuote() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension QuoteIndexViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return indexArray?.count ?? 0
    }
}


extension QuoteIndexViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let indexIdCell = "quoteIndexUserCell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let item = indexArray?[row] else {
            return nil
        }
        
        if item.varChange < 0 {
            textColor = ChartDefaultValue.redColor
            backColor2 = ChartDefaultValue.backRedColor
        } else if item.varChange > 0 {
            textColor = ChartDefaultValue.greenColor
            backColor2 = ChartDefaultValue.backGreenColor
        } else {
            textColor = ChartDefaultValue.whiteColor
            backColor2 = ChartDefaultValue.backWhiteColor
        }
        
        if item.status == 0 {
            backColor = textColor
            textColor = NSColor.black //self.tableView.backgroundColor
        } else if item.status == 1 {
            backColor = textColor
            textColor = NSColor.black //self.tableView.backgroundColor
        } else {
            backColor = NSColor.black //self.tableView.backgroundColor
        }
        
        let cellIdentifier = CellIdentifiers.indexIdCell
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? QuoteIndexCustomTableCell {
            cell.indexName.stringValue = item.name

            cell.indexTime.stringValue = CDate.dateQuote(item.dateQuote)!
            cell.indexLast.doubleValue = Calculate.roundnumber(item.close, 2)
            cell.indexVar.stringValue = Calculate.formatNumber(2, item.varChange) + " %"
            cell.indexChange.doubleValue = Calculate.roundnumber(item.change, 2)
            
            cell.indexName.textColor = textColor
            cell.indexTime.textColor = textColor
            cell.indexLast.textColor = textColor
            cell.indexChange.textColor = textColor
            
            cell.indexVar.wantsLayer = true
//            cell.indexVar.drawsBackground = false
/*
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = cell.indexVar.bounds
            let toColor = backColor2
            let fromColor = toColor.highlight(withLevel: 0.5)
            gradientLayer.colors = [fromColor!.cgColor, toColor.cgColor]
            gradientLayer.locations = [0.0, 1.0]
//            cell.indexVar.layer?.addSublayer(gradientLayer)
            cell.indexVar.layer?.insertSublayer(gradientLayer, at: 0)
            
            let topTextLayer = CATextLayer()
            topTextLayer.string = Calculate.formatNumber(2, item.varChange) + " %"
            topTextLayer.alignmentMode = .center
            topTextLayer.frame = cell.indexVar.bounds
            //CGRect(x: cell.indexVar.bounds.width/8, y: cell.indexVar.bounds.size.height - 50.0, width: 50 , height: 50)
            topTextLayer.fontSize = 16
            
            
            topTextLayer.foregroundColor = NSColor.white.cgColor
            //topTextLayer.contentsScale = (NSScreen.main()?.backingScaleFactor)!
            gradientLayer.addSublayer(topTextLayer)
*/

            cell.indexVar.layer?.backgroundColor = backColor2.cgColor
            cell.indexVar.layer?.borderColor = NSColor(red:204.0/255.0, green:204.0/255.0, blue:204.0/255.0, alpha:1.0).cgColor
            cell.indexVar.layer?.borderWidth = 0.2
            cell.indexVar.layer?.cornerRadius = 5.0

            cell.indexVar.layer?.shadowColor = NSColor(red:204.0/255.0, green:204.0/255.0, blue:204.0/255.0, alpha:0.5).cgColor
            cell.indexVar.layer?.shadowRadius = 5.0
            cell.indexVar.layer?.shadowOpacity = 1.5
            cell.indexVar.layer?.shadowOffset = CGSize(width: 1.5, height: 1.5)
            cell.indexVar.layer?.masksToBounds = true

            let tmpRow : NSTableRowView = tableView.rowView(atRow: row, makeIfNecessary: false)!
            tmpRow.backgroundColor = backColor
            //tmpRow.selectionHighlightStyle = .none
            return cell
        }
        return nil
    }
}



