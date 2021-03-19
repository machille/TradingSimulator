//
//  ChartIndicDetailViewController.swift
//  Trading
//
//  Created by Maroun Achille on 12/03/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class ChartIndicDetailViewController: NSViewController {

    @IBOutlet weak var indicButton: NSPopUpButton!
    @IBOutlet weak var defaultValue: NSButton!
    @IBOutlet weak var value1: NSTextField!
    @IBOutlet weak var value2: NSTextField!
    @IBOutlet weak var value3: NSTextField!
    @IBOutlet weak var color1: NSColorWell!
    @IBOutlet weak var color2: NSColorWell!
    @IBOutlet weak var active: NSButton!
    
    @IBOutlet weak var actionButton: NSButton!
    
    let question = "Setup Chart Indicator"
    var action: String = "Add"
    
    var cdb = ChartSettingDB.instance
    
    var dataArray: [IndicatorSetting]?
    
    var chartIndic: ChartIndicator?  {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readDataTable ()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }
    
    func readDataTable () {
        do {
            try dataArray = cdb.getIndicatorList()
            
            indicButton.removeAllItems()
            guard let dataArray = dataArray,  dataArray.count > 0 else {
                dspAlert(text: "Indicator is Empty")
                return
            }
            for (index, data) in dataArray.enumerated()  {
                indicButton.insertItem(withTitle: data.desc, at: index)
            }
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func updateUI() {
        if !isViewLoaded {
            return
        }
        
        if let chartIndic = chartIndic {
            if action != "Add" {
                if let index = getIndicIndex(id: chartIndic.indicatorId) {
                    indicButton.selectItem(at: index)
                }
            }
        
            if chartIndic.defaultValue == "1" {
                defaultValue.state = NSControl.StateValue.on
            } else {
                defaultValue.state = NSControl.StateValue.off
            }

            value1.doubleValue = chartIndic.value1
            value2.doubleValue = chartIndic.value2
            value3.doubleValue = chartIndic.value3
            color1.color = chartIndic.color1
            color2.color = chartIndic.color2
            
            if chartIndic.active == "1" {
                active.state = NSControl.StateValue.on
            } else {
                active.state = NSControl.StateValue.off
            }
        }
        actionButton.title = action
    }
    
    private func validate() -> Bool {
        
        let index = indicButton.indexOfSelectedItem
        if let value = dataArray?[index] {
            chartIndic?.indicatorId = value.id
            chartIndic?.indicatorDesc = value.desc
        } else {
            dspAlert(text: "Indicator is required")
            return false
        }
        
        if defaultValue.state == NSControl.StateValue.on  {
            chartIndic?.defaultValue = "1"
        } else {
            chartIndic?.defaultValue = "0"
            
            guard value1.doubleValue > 0  else {
                dspAlert(text: "Indicator Value 1 is required")
                return false
            }
        }
        chartIndic?.value1 = value1.doubleValue
        chartIndic?.value2 = value2.doubleValue
        chartIndic?.value3 = value3.doubleValue
        chartIndic?.color1 = color1.color
        chartIndic?.color2 = color2.color
        
        if active.state == NSControl.StateValue.on  {
            chartIndic?.active = "1"
        } else {
            chartIndic?.active = "0"
        }
        
        return true
    }
    
    fileprivate func getIndicIndex(id : String) -> Int? {
        guard let dataArray = dataArray,  dataArray.count > 0 else {
            dspAlert(text: "Indicator is Empty")
            return nil
        }
        if let index = dataArray.firstIndex(where: { $0.id == id }) {
            return index
        }
        return nil
    }
    
    fileprivate func dspAlert(text: String) {
        Message.messageAlert(question,text: text)
    }
    
    @IBAction func save(_ sender: Any) {
        if validate() {
            let firstViewController = presentingViewController as! ChartDetailViewController
            firstViewController.passDataBack(action: action, chartIndic: chartIndic!)
            self.dismiss(self)
        }
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss(self)
    }
}
