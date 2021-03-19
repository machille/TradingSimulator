//
//  TableComboDB.swift
//  Trading
//
//  Created by Maroun Achille on 15/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation


class TableComboDB {

    var tableArray: [Ttables]?
    var tableCurrent: Ttables?
    var tableName: String
    
    init (tableName :String) throws {
        self.tableName = tableName
        try tableArray = TtablesDB.instance.getTablesList(name: tableName)
    }
    
    func numberOfItems() -> Int {
         return tableArray?.count ?? 0
    }
    
    func comboBox(objectValueForItemAt index: Int) -> Any? {
        if let tableCurrent = tableArray?[index] {
            return tableCurrent.desc
        } else {
            tableCurrent = nil
            return "..."
        }
    }
    
    func comboBox(keyValueForItemAt index: Int) -> String? {
        if index < 0 {
            return nil
        }
        
        if let tableCurrent = tableArray?[index] {
            return tableCurrent.id 
        } else {
            return nil
        }
    }
    
    func comboBox(keyIndexForItem item: String) -> Int {
        for index in 0...numberOfItems() - 1 {
            tableCurrent = tableArray?[index]
            if tableCurrent?.id == item {
                return index
            }
        }
        return 0
    }
    
    func comboBox(keyValueForItemAt key: String) -> String? {
        for table in tableArray! {
            tableCurrent = table
            if tableCurrent?.id == key {
                return tableCurrent?.desc
            }
        }
        return "?"
    }
    
    func comboBox(keyCheckForItem key: String) -> Bool {
        for table in tableArray! {
            tableCurrent = table
            if tableCurrent?.id == key {
                return true
            }
        }
        return false
    }
}
