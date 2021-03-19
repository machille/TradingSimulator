//
//  SimuOrderViewController.swift
//  Trading
//
//  Created by Maroun Achille on 16/06/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class SimuOrderViewController: NSViewController {

    let question = "Simulator Order"
    
    @IBOutlet weak var operationDate: NSTextField!
    @IBOutlet weak var long: NSButton!
    @IBOutlet weak var short: NSButton!
    @IBOutlet weak var open: NSButton!
    @IBOutlet weak var close: NSButton!
    @IBOutlet weak var quantity: NSTextField!
    @IBOutlet weak var execPrice: NSTextField!
    @IBOutlet weak var amount: NSTextField!
    @IBOutlet weak var stopLoss: NSTextField!
    @IBOutlet weak var commission: NSTextField!
    @IBOutlet weak var netPrice: NSTextField!
    @IBOutlet weak var netAmount: NSTextField!
    @IBOutlet weak var comment: NSTextField!
    
    var action: String = "Open"
    
    var simuPos: SimuPosition? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quantity.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }
    
    func updateUI() {
        if !isViewLoaded {
            return
        }
        
        guard let simuPos =  simuPos else {
            return
        }
        
        operationDate.stringValue = CDate.formatDate(simuPos.lastDate, "dd/MM/YYYY")
        execPrice.doubleValue = simuPos.lastQuote
        commission.doubleValue = simuPos.commission
        
        if action == "Open" {
            if simuPos.positionType == "Long" {
                long.state = NSControl.StateValue.on
                long.isEnabled = false
                short.state = NSControl.StateValue.off
                short.isEnabled = false
            } else if simuPos.positionType == "Short" {
                long.state = NSControl.StateValue.off
                long.isEnabled = false
                short.state = NSControl.StateValue.on
                short.isEnabled = false
            } else {
                long.state = NSControl.StateValue.on
                long.isEnabled = true
                short.state = NSControl.StateValue.off
                short.isEnabled = true
            }
    
            open.state = NSControl.StateValue.on
            open.isEnabled = false
            close.state = NSControl.StateValue.off
            close.isEnabled = false
        }
        
        if action == "Close" {
            if simuPos.quantity == 0 {
                Message.messageAlert(question, text: "Can not Close Position when Quantiy is ZERO")
                return
            }
            if simuPos.positionType == "Long" {
                long.state = NSControl.StateValue.on
                long.isEnabled = false
                short.state = NSControl.StateValue.off
                short.isEnabled = false
            } else if simuPos.positionType == "Short" {
                long.state = NSControl.StateValue.off
                long.isEnabled = false
                short.state = NSControl.StateValue.on
                short.isEnabled = false
            }
            open.state = NSControl.StateValue.off
            open.isEnabled = false
            close.state = NSControl.StateValue.on
            close.isEnabled = false
            quantity.doubleValue = simuPos.quantity
            calculateOrder()
        }
    }
    
    @IBAction func longShort(_ sender: NSButton) {
        calculateOrder()
    }
    
    @IBAction func openClose(_ sender: NSButton) {
    }
    
    
    @IBAction func save(_ sender: Any) {
        
        if quantity.doubleValue == 0.0 {
           Message.messageAlert(question, text: "Quantiy must be greater than  Zero")
        } else {
            let simuOrd = SimuOrder()
            simuOrd.setOrderId()
            simuOrd.simuId = simuPos!.simuId
            simuOrd.positionId = simuPos!.getPositionId()
            simuOrd.operationDate = simuPos!.lastDate
            
            if long.state == NSControl.StateValue.on {
                simuOrd.operationType = "Long"
            } else {
                simuOrd.operationType = "Short"
            }
            
            if open.state == NSControl.StateValue.on {
                simuOrd.operationAction = "Open"
                simuPos?.stopLoss = stopLoss.doubleValue
                stopLoss.isEditable = true
            } else {
                simuOrd.operationAction = "Close"
                stopLoss.isSelectable = true
            }
            
            simuOrd.quantity = quantity.doubleValue
            simuOrd.executionPrice = execPrice.doubleValue
            simuOrd.commission = commission.doubleValue
            simuOrd.netPrice = netPrice.doubleValue
            simuOrd.amount = amount.doubleValue
            simuOrd.netAmount = netAmount.doubleValue
            simuOrd.comment = comment.stringValue
            
            let firstViewController = presentingViewController as! SimuViewController
            firstViewController.passDataBack(action: action, simuOrd: simuOrd)
            self.dismiss(self)
        }
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
    
}

extension SimuOrderViewController : NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        calculateOrder()
    }
    
    private func calculateOrder() {
        amount.doubleValue = quantity.doubleValue * execPrice.doubleValue
        
        if quantity.doubleValue != 0.0 {
            if (long.state == NSControl.StateValue.on && open.state == NSControl.StateValue.on) ||
                (short.state == NSControl.StateValue.on && close.state == NSControl.StateValue.on)  {
                netAmount.doubleValue = amount.doubleValue + commission.doubleValue
            } else if (long.state == NSControl.StateValue.on && close.state == NSControl.StateValue.on) ||
                (short.state == NSControl.StateValue.on && open.state == NSControl.StateValue.on)  {
                netAmount.doubleValue = amount.doubleValue - commission.doubleValue
            }
            
            if open.state == NSControl.StateValue.on {
                if long.state == NSControl.StateValue.on {
                    stopLoss.doubleValue = simuPos!.lastQuote - (simuPos!.lastQuote * simuPos!.stopLossDefault) / 100.0
                } else {
                    stopLoss.doubleValue = simuPos!.lastQuote + (simuPos!.lastQuote * simuPos!.stopLossDefault) / 100.0
                }
            } else {
                stopLoss.stringValue = ""
            }
            netPrice.doubleValue = netAmount.doubleValue / quantity.doubleValue
            
        } else {
            netPrice.stringValue = ""
            netAmount.stringValue = ""
            stopLoss.stringValue = ""
            amount.stringValue = ""
        }
    }
}
