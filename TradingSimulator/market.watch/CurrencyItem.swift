//
//  CurrencyItem.swift
//  Trading
//
//  Created by Maroun Achille on 25/05/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Cocoa

class CurrencyItem: NSCollectionViewItem {

    var doubleClickActionHandler: (() -> Void)?
    
    @IBOutlet weak var currencyName: NSTextField!
    @IBOutlet weak var currencyValue: NSTextField!
    @IBOutlet weak var currencyChange: NSTextField!
    @IBOutlet weak var currencyDate: NSTextField!
    
    var textColor: NSColor = NSColor.green
    var backColor: NSColor = NSColor.black
    var backColor2: NSColor = NSColor.black
    
    let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 0.5
        opacityAnimation.duration = 0.3
        opacityAnimation.repeatCount = 2
        
        view.wantsLayer = true
        view.layer?.cornerRadius = 8.0
    }
      
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
       
            if isSelected {
                view.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
            } else {
                view.layer?.backgroundColor = NSColor.clear.cgColor
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if event.clickCount == 2 {
            doubleClickActionHandler?()
        }
    }
    
    func changeColor(change: Double) {
        if change < 0 {
            view.layer?.backgroundColor = ChartDefaultValue.backRedColor.cgColor
        } else {
            view.layer?.backgroundColor = ChartDefaultValue.backGreenColor.cgColor
        }
    }
    
    func animaton(status: Int) {
        if status == 1 {
            view.layer?.add(opacityAnimation, forKey: "opacityScale")
        }
    }
}
