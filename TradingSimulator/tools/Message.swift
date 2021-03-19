//
//  Message.swift
//  Trading
//
//  Created by Maroun Achille on 27/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa

class Message {
    static func messageAlert(_ header: String, text: String) {
        let alert = NSAlert()
        alert.messageText = header
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    static func dialogOKCancel(_ header: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = header
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
}
