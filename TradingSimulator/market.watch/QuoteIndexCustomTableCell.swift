//
//  QuoteIndexCustomTableCell.swift
//  Trading
//
//  Created by Maroun Achille on 07/09/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class QuoteIndexCustomTableCell: NSTableCellView {
    
    @IBOutlet weak var indexName: NSTextField!
    @IBOutlet weak var indexTime: NSTextField!
    @IBOutlet weak var indexLast: NSTextField!
    @IBOutlet weak var indexVar: NSTextField!
    @IBOutlet weak var indexChange: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}
