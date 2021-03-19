//
//  SQLiteError.swift
//  SQLiteTest
//
//  Created by Maroun Achille on 09/04/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Duplicate(message: String)
    case Step(message: String)
    case Bind(message: String)
    case NotFound(message: String)
    case Execute(message: String)
    case DataErrror(message: String)
    
    public var description: String {
        switch self {
        case .OpenDatabase(let name):
            return "Canot Open DataBase: \(name)"
        case .Prepare(let sql):
            return "Prepare Statement Error \(sql)"
        case .Duplicate(let row):
            return "Duplicate Key \(row))"
        case .Step(let message):
            return "Step Error for \(message)"
        case .Bind(let message):
            return "Bind Error for \(message)"
        case .NotFound(let message):
            return "Not Found Error \(message)"
        case .Execute(let message):
            return "Execute Error \(message)"
        case .DataErrror(let message):
            return "Data Format Error \(message)"
        }
    }
        
}
