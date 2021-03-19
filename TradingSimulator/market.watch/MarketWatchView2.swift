//
//  MarketWatchView2.swift
//  Trading
//
//  Created by Maroun Achille on 08/09/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class MarketWatchView: NSView {

    fileprivate let header = "Market Watch"
    fileprivate var stockQuoteView: QuoteStockViewController?
    fileprivate var indexQuoteView: QuoteIndexViewController?
    fileprivate var rssView: RSSViewController?
    fileprivate var watchListView: QuoteWatchListViewController?
    fileprivate var currencyView: CurrencyViewController?
    
    var showWL = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadMarketView()
    }
     
//    func switchDisplayMode() {
//        showWL = showWL ? false: true
//        if showWL {
//            UserDefaults.standard.set(true, forKey: "showWatchList")
////            withWatchListView()
//        } else {
//            UserDefaults.standard.set(false, forKey: "showWatchList")
////            defaultView()
//        }
//    }
    
     func getStockArray() -> [StockDayQuote]? {
        if let stockQuoteView = stockQuoteView {
            return stockQuoteView.stockArray
        }
        return nil
     }
     
    func loadMarketView() {
        let storyboard = NSStoryboard(name: "Market", bundle: nil)
                
        guard let stockQuoteView = storyboard.instantiateController(withIdentifier: "StockTable") as? QuoteStockViewController
                else {
                    Message.messageAlert(header, text: "Cannot load QuoteStockViewController")
                    return
                }
         
        guard let indexQuoteView = storyboard.instantiateController(withIdentifier: "IndexQuoteViewController") as? QuoteIndexViewController
                else {
                    Message.messageAlert(header, text: "Cannot load QuoteIndexViewController")
                    return
                }
         
        guard let rssView = storyboard.instantiateController(withIdentifier: "RSSViewController") as? RSSViewController
                else {
                    Message.messageAlert(header, text: "Cannot load RSSViewController2")
                    return
                }
         
        guard let watchListView = storyboard.instantiateController(withIdentifier: "quoteWatchListViewController") as? QuoteWatchListViewController
                else {
                    Message.messageAlert(header, text: "Cannot load QuoteWatchListViewController")
                    return
                }
             
        guard let currencyView = storyboard.instantiateController(withIdentifier: "currencyViewController") as? CurrencyViewController
                else {
                    Message.messageAlert(header, text: "Cannot load CurrencyViewController")
                    return
                }

        self.indexQuoteView = indexQuoteView
        self.stockQuoteView = stockQuoteView
        self.watchListView = watchListView
        self.rssView = rssView
        self.currencyView = currencyView
        
        self.indexQuoteView?.qsvc = self.stockQuoteView
        self.watchListView?.qsvc = self.stockQuoteView
        
        withWatchListView()
        
     }

     func withWatchListView() {
        addSubview(indexQuoteView!.view)
        indexQuoteView!.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(watchListView!.view)
        watchListView!.view.translatesAutoresizingMaskIntoConstraints = false
    
        addSubview(stockQuoteView!.view)
        stockQuoteView!.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(currencyView!.view)
        currencyView!.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(rssView!.view)
        rssView!.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: indexQuoteView!.view, attribute: .top, relatedBy: .equal, toItem:  self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: indexQuoteView!.view, attribute: .left, relatedBy: .equal, toItem:  self, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: indexQuoteView!.view, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.23, constant: 0).isActive = true
          //NSLayoutConstraint(item: indexQuoteView.view, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 0.50, constant: 0 ).isActive = true
        NSLayoutConstraint(item: indexQuoteView!.view, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.50, constant: 0 ).isActive = true
                 
        NSLayoutConstraint(item: watchListView!.view, attribute: .top, relatedBy: .equal, toItem:  indexQuoteView!.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: watchListView!.view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: watchListView!.view, attribute: .width, relatedBy: .equal, toItem: indexQuoteView!.view, attribute: .width, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: watchListView!.view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0 ).isActive = true
        //NSLayoutConstraint(item: watchListView!.view, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: wlh, constant: 0 ).isActive = true
          
        NSLayoutConstraint(item: stockQuoteView!.view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stockQuoteView!.view, attribute: .left, relatedBy: .equal, toItem:  indexQuoteView!.view, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stockQuoteView!.view, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.46, constant: 0).isActive = true
//        NSLayoutConstraint(item: stockQuoteView!.view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stockQuoteView!.view, attribute: .bottom, relatedBy: .equal, toItem:  self, attribute: .bottom, multiplier: 1, constant: 0 ).isActive = true
       
        NSLayoutConstraint(item: currencyView!.view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: currencyView!.view, attribute: .left, relatedBy: .equal, toItem:  stockQuoteView!.view, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: currencyView!.view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: currencyView!.view, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.45, constant: 0 ).isActive = true
//        NSLayoutConstraint(item: currencyView!.view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0 ).isActive = true

        NSLayoutConstraint(item: rssView!.view, attribute: .top, relatedBy: .equal, toItem:  currencyView!.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: rssView!.view, attribute: .left, relatedBy: .equal, toItem:  stockQuoteView!.view, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: rssView!.view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: rssView!.view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0 ).isActive = true
//
      }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}
