//
//  OrderArrow.swift
//  Trading
//
//  Created by Maroun Achille on 01/10/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Foundation

class OrderArrow {
    var date: Date
    var action: String // Open Close
    var type: String // Long Short

    init(date: Date, action: String, type: String) {
        self.date = date
        self.action = action
        self.type = type
    }
}
