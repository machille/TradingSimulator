//
//  IndicatorDetailViewController.swift
//  Trading
//
//  Created by Maroun Achille on 06/03/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Cocoa

class IndicatorDetailViewController: NSViewController {

    @IBOutlet weak var indicId: NSTextField!
    @IBOutlet weak var indicDesc: NSTextField!
    @IBOutlet weak var indicModel: NSPopUpButton!
    @IBOutlet weak var indicType: NSPopUpButton!
    @IBOutlet weak var value1: NSTextField!
    @IBOutlet weak var value2: NSTextField!
    @IBOutlet weak var value3: NSTextField!
    @IBOutlet weak var color1: NSColorWell!
    @IBOutlet weak var color2: NSColorWell!
    
    @IBOutlet weak var lineZero: NSButton!
    @IBOutlet weak var zeroColor: NSColorWell!
    @IBOutlet weak var lineValue1: NSTextField!
    @IBOutlet weak var lineColor1: NSColorWell!
    @IBOutlet weak var lineValue2: NSTextField!
    @IBOutlet weak var lineColor2: NSColorWell!
    
    @IBOutlet weak var avgValue1: NSTextField!
    @IBOutlet weak var avgType1: NSPopUpButton!
    @IBOutlet weak var avgColor1: NSColorWell!
    @IBOutlet weak var avgValue2: NSTextField!
    @IBOutlet weak var avgType2: NSPopUpButton!
    @IBOutlet weak var avgColor2: NSColorWell!
    
    @IBOutlet weak var actionButton: NSButton!
    
    let question = "Setup Indicator"
    var action: String = "Add"
    
    var cdb = ChartSettingDB.instance
    
    var formatter = NumberFormatter()
    
    
    var indic: IndicatorSetting?  {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        indicModel.removeAllItems()
        indicModel.addItems(withTitles: IndicatorModel.allValues)
        indicModel.selectItem(at: 0)
        
        indicType.removeAllItems()
        indicType.addItems(withTitles: IndicatorType.allValues)
        indicType.selectItem(at: 0)
        
        avgType1.removeAllItems()
        avgType1.addItems(withTitles: AverageType.allValues)
        avgType1.selectItem(at: 0)
        
        avgType2.removeAllItems()
        avgType2.addItems(withTitles: AverageType.allValues)
        avgType2.selectItem(at: 0)
        
        formatter.minimumFractionDigits = 4
        formatter.numberStyle = .decimal
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateUI()
    }
    
    func updateUI() {
        
        if !isViewLoaded {
            return
        }
        
        if action == "Add" {
            indicId.isEditable = true
        } else {
            indicId.isEditable = false
        }
            
        if let indic = indic {
            indicId.stringValue = indic.id
            indicDesc.stringValue = indic.desc
            indicModel.selectItem(withTitle: indic.model)
            indicType.selectItem(withTitle: indic.type)
            value1.stringValue = formatter.string(from: indic.value1 as NSNumber)!
            value2.doubleValue = indic.value2
            value3.doubleValue = indic.value3
            color1.color = indic.color1
            color2.color = indic.color2
            
            if indic.splineZero == "1" {
                lineZero.state = NSControl.StateValue.on
            } else {
                lineZero.state = NSControl.StateValue.off
            }
            zeroColor.color = indic.splineColor0
            lineValue1.stringValue = indic.splineValue1
            lineColor1.color = indic.splineColor1
            lineValue2.stringValue = indic.splineValue2
            lineColor2.color = indic.splineColor2
                
            avgValue1.doubleValue = indic.maValue1
            avgType1.selectItem(withTitle: indic.maType1)
            avgColor1.color = indic.maColor1
            avgValue2.doubleValue = indic.maValue2
            avgType2.selectItem(withTitle: indic.maType2)
            avgColor2.color = indic.maColor2
        }
        
        actionButton.title = action
    }
    
    func validate() ->Bool {
        guard !indicId.stringValue.isEmpty  else {
            dspAlert(text: "Indicator Id is required")
            return false
        }
        indic?.id = indicId.stringValue
        
        guard !indicDesc.stringValue.isEmpty  else {
            dspAlert(text: "Description is required")
            return false
        }
        indic?.desc = indicDesc.stringValue
        
        
        guard IndicatorModel.allValues.contains(indicModel.titleOfSelectedItem!) else {
            dspAlert(text: "Indicator Model invalid Value")
            return false
        }
        indic?.model = indicModel.titleOfSelectedItem!
        
        guard IndicatorType.allValues.contains(indicType.titleOfSelectedItem!) else {
            dspAlert(text: "Indicator Type invalid Value")
            return false
        }
        indic?.type = indicType.titleOfSelectedItem!
        
        guard value1.doubleValue > 0  else {
            dspAlert(text: "Indicator Value 1 is required")
            return false
        }
        indic?.value1 = value1.doubleValue

        indic?.value2 = value2.doubleValue
        indic?.value3 = value3.doubleValue
        indic?.color1 = color1.color
        indic?.color2 = color2.color

        if lineZero.state == NSControl.StateValue.on  {
            indic?.splineZero = "1"
        } else {
            indic?.splineZero = "0"
        }
        indic?.splineColor0 = zeroColor.color
        indic?.splineValue1 = lineValue1.stringValue
        indic?.splineColor1 = lineColor1.color
        indic?.splineValue2 = lineValue2.stringValue
        indic?.splineColor2 = lineColor2.color
        
        indic?.maValue1 = avgValue1.doubleValue
        indic?.maType1 = avgType1.titleOfSelectedItem!
        indic?.maColor1 = avgColor1.color
        indic?.maValue2 = avgValue2.doubleValue
        indic?.maType2 = avgType2.titleOfSelectedItem!
        indic?.maColor2 = avgColor2.color
        
        do {
            if action == "Add" {
                try cdb.indicatorInsert(indicator: indic!)
            } else {
                try cdb.indicatorUpdate(indicator: indic!)
            }
            return true
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        
        return false
    }
    
    private func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }

    @IBAction func Save(_ sender: Any) {
        if validate() {
            let firstViewController = presentingViewController as! IndicatorTableViewController
            firstViewController.passDataBack(action: action, indicator: indic!)
            self.dismiss(self)
        }
    }
    
    @IBAction func dismissWindow(_ sender: NSButton) {
        self.dismiss(self)
    }
}
