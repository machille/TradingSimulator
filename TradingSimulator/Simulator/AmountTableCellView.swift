//
//  AmountTableCellView.swift
//  Trading
//
//  Created by Maroun Achille on 19/08/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class AmountTableCellView: NSTableCellView {

    @IBOutlet weak var investedAmt: NSTextField!
    @IBOutlet weak var estimatedAmt: NSTextField!
    
}

class PeriodTableCellView: NSTableCellView {
    
    @IBOutlet weak var dateFrom: NSTextField!
    @IBOutlet weak var dateTo: NSTextField!
    
}

class ResultTableCellView: NSTableCellView {
    
    @IBOutlet weak var result: NSTextField!
    @IBOutlet weak var varPer: NSTextField!
    
}
