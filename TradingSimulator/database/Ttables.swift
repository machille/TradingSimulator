//
//  Ttables.swift
//  SQLiteTest
//
//  Created by Maroun Achille on 23/04/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class Ttables {
    var name: String
    var id: String
    var desc: String
    var value1: String!
    var value2: String!
    var value3: Double!
    var flag1: String!
    var flag2: String!
    var index: Int
    
    public var description: String {
        return "Table: \(name) id: \(id) Description: \(desc) value 1: \(String(describing: value1))"
    }
    
    init() {
        name = ""
        id = ""
        desc = ""
        value1 = ""
        value2 = ""
        value3 = 0
        flag1 = "0"
        flag2 = "0"
        index = 0
    }
}
