//
//  IndexMember.swift
//  SQLiteTest
//
//  Created by Maroun Achille on 09/04/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class IndexMember {
    
    var indexId: String!
    var stockId: String!
    var stockName: String!
    var weight: Int = 0

    public var description: String { return "indexId: \(String(describing: indexId)) stockId: \(String(describing: stockId)) "}
    
}
