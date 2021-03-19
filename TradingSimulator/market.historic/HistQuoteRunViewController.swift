//
//  HistQuoteRunViewController.swift
//  Trading
//
//  Created by Maroun Achille on 04/06/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

protocol RunDelegate {
    func dspMessage (_ message: String)
    func updateProgressBar()
    func resetProgressBar(nbRows: Int)
}

class HistQuoteRunViewController: NSViewController {
    let question = "Internet Historic Quote"
    
    @IBOutlet weak var headLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var mode: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var textView: NSTextView!
    
    var reload: Bool = false
    private var textFontAttributes: [NSAttributedString.Key : Any]?
    
    private var ihq: HistQuoteDownload?
    private var totalRow:Int = 0
    private var currentRow:Int = 0
    
    var stockHistArray: [StockHist]? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if let textfont = textView.font,  let textcolor = textView.textColor {
            textFontAttributes = [
                            NSAttributedString.Key.font: textfont,
                            NSAttributedString.Key.foregroundColor: textcolor
                                ]
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }
    
    func updateUI() {
        if !isViewLoaded {
            return
        }
        if reload {
            mode.stringValue = "Full"
        } else {
            mode.stringValue = "Update"
        }
        updateHistLabel()
    }
    
    func numberOfRows() ->Int {
        return stockHistArray?.count ?? 0
    }
    
    func updateHistLabel() {
        headLabel.stringValue = "Total Stock Historic:"
        totalRow = numberOfRows()
        currentRow = 0
        titleLabel.stringValue = "0/\(totalRow)"
        progressBar.minValue = 0
        progressBar.maxValue = Double(numberOfRows())
    }
    
    func updateScreLabel(nbRows: Int) {
        headLabel.stringValue = "Total Stock Screener:"
        totalRow = nbRows
        currentRow = 0
        titleLabel.stringValue = "0/\(totalRow)"
        progressBar.minValue = 0
        progressBar.maxValue = Double(nbRows)
        progressBar.doubleValue = 0
    }
    
    @IBAction func start(_ sender: Any) {
        updateHistLabel()
        
        let cqueue = DispatchQueue(label: "cqueue.historic",  qos: .userInteractive, attributes: .concurrent)
        let queue = OperationQueue()
        
        let ihq = self.ihq ?? HistQuoteDownload(queue: queue)

        ihq.delegate = self
        ihq.reload = self.reload
        ihq.stockHistArray = self.stockHistArray
        
        
        cqueue.async {
            queue.maxConcurrentOperationCount = 6
            ihq.startRun()
            queue.waitUntilAllOperationsAreFinished()
                    
            DispatchQueue.main.async {
                self.dspMessage("Save Log")
                self.saveTextView()
            }
        }
        if self.ihq == nil {
            self.ihq = ihq
        }
    
    }
    
    private func stopRun() {
        if let ihq = ihq {
            ihq.stopRun()
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        stopRun()
    }
    
    @IBAction func close(_ sender: NSButton) {
        stopRun()
        let firstViewController = presentingViewController as! HistQuoteViewController
        firstViewController.passDataBack()
        self.dismiss(self)
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    func saveTextView() {
        if let text = textView.textStorage?.string {
            DirectoryFiles.logSave(data: text, fileName: "QuoteDownload.txt")
        }
    }
}

extension HistQuoteRunViewController: RunDelegate {
       
    func dspMessage (_ message: String) {
        DispatchQueue.main.async {
            let attributedMessage = NSAttributedString(string: message + "\r\n", attributes: self.textFontAttributes!)
            self.textView.textStorage?.append(attributedMessage)
            self.textView.scrollRangeToVisible(NSMakeRange( (self.textView.textStorage as NSAttributedString?)!.string.count, 0))
        }
    }
    
    func updateProgressBar() {
        DispatchQueue.main.async {
            self.progressBar.increment(by: 1)
            self.currentRow += 1
            self.titleLabel.stringValue = " \(self.currentRow)/\(self.totalRow)"
        }
    }

    func resetProgressBar(nbRows: Int) {
        DispatchQueue.main.async {
            self.updateScreLabel(nbRows: nbRows)
        }
    }
}
