//
//  ChartSetting.swift
//  Trading
//
//  Created by Maroun Achille on 12/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class ChartSetting : Chart {

    var chartIndic: [ChartIndicator]
    
    override init() {
        chartIndic = [ChartIndicator]()
    }
}
