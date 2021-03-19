//
//  CurrencyViewController.swift
//  Trading
//
//  Created by Maroun Achille on 25/05/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class CurrencyViewController: NSViewController {

    @IBOutlet weak var collectionView: NSCollectionView!
    
    let question = "Currency Quote"
    let idqDB = IndexDailyQuoteDB.instance
    let isq = InternetStreamQuote.instance
    var stockArray: [StockDayQuote]?

    var currencyId: String?
    let currencyItemIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "currencyItemIdentifier")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureGridLayout()
        readCurrencyTable()
    }
        
    override func viewWillAppear() {
        isq.addActionDelegate(name: "CURRENCY", controller: self)
    }
    
    
    override func viewDidDisappear() {
        isq.removeActionDelegate(name: "CURRENCY")
    }
    
    func readCurrencyTable() {
        stockArray = idqDB.getCurrency()
    }

    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.black]
           
        collectionView.enclosingScrollView?.borderType = .noBorder
           
        let nib = NSNib(nibNamed: "CurrencyItem", bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: currencyItemIdentifier)
    }
    
    
    func configureAndShowQuickLook() {
        guard let id = currencyId else {
            return
        }
        let chartF = ChartWindowFactory.instance
        chartF.setStockId(id: id)
        chartF.show()
        
     }
    
    func configureGridLayout() {
        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumInteritemSpacing = 10.0
        gridLayout.minimumLineSpacing = 10.0
        
        gridLayout.maximumNumberOfColumns = 5
        gridLayout.maximumNumberOfRows = 10

        gridLayout.minimumItemSize = NSSize(width: 85.0, height: 90.0)
        gridLayout.maximumItemSize = NSSize(width: 95.0, height: 100.0)
        collectionView.collectionViewLayout = gridLayout
    }
}

extension CurrencyViewController: QuoteDelegate {
    func reloadQuote() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
extension CurrencyViewController: NSCollectionViewDataSource {
    
 
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return stockArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell = collectionView.makeItem(withIdentifier: currencyItemIdentifier, for: indexPath) as? CurrencyItem else { return NSCollectionViewItem() }
        
        guard let item = stockArray?[indexPath.item] else {
                return cell
            }
        
        cell.currencyName.stringValue = item.name
        cell.currencyValue.doubleValue = item.close
        cell.currencyChange.stringValue = Calculate.formatNumber(2, item.varChange) + " %"
        cell.changeColor(change: item.varChange)
        cell.currencyDate.stringValue = CDate.dateQuote(item.dateQuote)!
                
        cell.doubleClickActionHandler = { [weak self] in
            self?.currencyId = item.id
            self?.configureAndShowQuickLook()
        }
        
        cell.animaton(status: item.status)
        
        return cell
    }
}

extension CurrencyViewController: NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 100.0, height: 120.0)
    }    
}

