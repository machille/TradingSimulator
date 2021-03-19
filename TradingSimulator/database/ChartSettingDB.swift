//
//  ChartSettingDB.swift
//  Trading
//
//  Created by Maroun Achille on 12/11/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa
import SQLite3

class ChartSettingDB {
    static let instance = ChartSettingDB()
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    let dateFormatter = DateFormatter()
    var histQuotestatement: OpaquePointer?
    
    private init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func getChart(id: String) throws -> ChartSetting {
        
        let selectSQL = """
                SELECT CHART_ID, DESCRIPTION, CHART_MODEL, CHART_TYPE, PERIOD, BACK_COLOR, LINE_COLOR,
                     COLUMN_COLOR, DEFAULT_COLOR, JCHIGHT_COLOR, JCLOW_COLOR, CHART_SELECT, CHART_ORDER
                FROM MAIN.CHART_SETTING WHERE CHART_ID = ?
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw SQLiteError.NotFound(message: db.errorMessage)
        }
        
        let chart: ChartSetting = ChartSetting.init()
        
        chart.id = String(cString: (sqlite3_column_text(statement, 0)))
        chart.desc = String(cString: (sqlite3_column_text(statement, 1)))
        chart.model = String(cString: (sqlite3_column_text(statement, 2)))
        chart.type = String(cString: (sqlite3_column_text(statement, 3)))
        chart.period = String(cString: (sqlite3_column_text(statement, 4)))
        
        chart.backColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 5))) )
        chart.lineColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 6))) )
        chart.columnColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 7))) )
        chart.defaultColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 8))) )
        chart.jcHighColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 9))) )
        chart.jcLowColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 10))) )
        
        chart.selected = String(cString: (sqlite3_column_text(statement, 11)))
        chart.order =  sqlite3_column_int(statement, 12)
        
        try chart.chartIndic = getChartIndicatorList(chart: chart)
        
        return chart
    }
    
    func getChartDraw(id: String) throws -> ChartDrawing {
        let chart = try getChart(id: id)
        let chartD: ChartDrawing = ChartDrawing.init()
        
        chartD.id           = chart.id
        chartD.desc         = chart.desc
        chartD.model        = chart.model
        chartD.type         = chart.type
        chartD.period       = chart.period
        chartD.backColor    = chart.backColor
        chartD.lineColor    = chart.lineColor
        chartD.columnColor  = chart.columnColor
        chartD.defaultColor = chart.defaultColor
        chartD.jcHighColor  = chart.jcHighColor
        chartD.jcLowColor   = chart.jcLowColor
        chartD.selected     = chart.selected
        chartD.order        = chart.order
        
        for chartIndic in chart.chartIndic {
            let indicator = try getIndicator(id: chartIndic.indicatorId)
            if chartIndic.active == "1" {
                if chartIndic.defaultValue == "0" {
                    indicator.value1 = chartIndic.value1
                    indicator.value2 = chartIndic.value2
                    indicator.value3 = chartIndic.value3
                    indicator.color1 = chartIndic.color1
                    indicator.color2 = chartIndic.color2
                }
                chartD.chartIndic.append(indicator)
            }
        }

        return chartD
    }
    
    
    func getChartList() throws -> Array<ChartSetting>  {
        return try getChartList(otherWhere: "")
    }
    
    func getChartSelect() throws -> Array<ChartDrawing>  {
        var chartDArray = [ChartDrawing]()
        for chart in try getChartList(otherWhere: "WHERE CHART_SELECT = '1'") {
            chartDArray.append(try getChartDraw(id: chart.id))
        }
        return chartDArray
    }
    
    func getChartList(otherWhere: String) throws -> Array<ChartSetting>  {
        var chartArray = [ChartSetting]()
        
        let selectSQL = """
                SELECT CHART_ID, DESCRIPTION, CHART_MODEL, CHART_TYPE, PERIOD, BACK_COLOR, LINE_COLOR,
                       COLUMN_COLOR, DEFAULT_COLOR, JCHIGHT_COLOR, JCLOW_COLOR, CHART_SELECT, CHART_ORDER
                FROM MAIN.CHART_SETTING
                """ +  " " + otherWhere +  " ORDER BY CHART_ORDER"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            
            let chart: ChartSetting = ChartSetting.init()
            
            chart.id = String(cString: (sqlite3_column_text(statement, 0)))
            chart.desc = String(cString: (sqlite3_column_text(statement, 1)))
            chart.model = String(cString: (sqlite3_column_text(statement, 2)))
            chart.type = String(cString: (sqlite3_column_text(statement, 3)))
            chart.period = String(cString: (sqlite3_column_text(statement, 4)))
            
            chart.backColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 5))) )
            chart.lineColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 6))) )
            chart.columnColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 7))) )
            chart.defaultColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 8))) )
            chart.jcHighColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 9))) )
            chart.jcLowColor = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 10))) )
            
            chart.selected = String(cString: (sqlite3_column_text(statement, 11)))
            chart.order =  sqlite3_column_int(statement, 12)
            
            try chart.chartIndic = getChartIndicatorList(chart: chart)
            
            chartArray.append(chart)
        }
        return chartArray
    }
    
    func stringToColor(color: String) -> NSColor {
        return NSColor(hex: color)!
    }
    
    func colorToString(color: NSColor) -> String {
        return color.toHex!
    }
    
    func chartInsert(chart: ChartSetting) throws {
        
        let insertSQL = """
            INSERT INTO CHART_SETTING
                    (DESCRIPTION, CHART_MODEL, CHART_TYPE, PERIOD, BACK_COLOR, LINE_COLOR, COLUMN_COLOR,
                     DEFAULT_COLOR, JCHIGHT_COLOR, JCLOW_COLOR, CHART_SELECT, CHART_ORDER, CHART_ID )
            VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        
        try chartInsertUpdate(chart: chart, sql: insertSQL)
        try chartIndicatorUpdateAll(chart: chart)
    }
    
    
    func chartUpdate(chart: ChartSetting) throws {
        
        let updateSQL = """
            UPDATE CHART_SETTING SET DESCRIPTION=?, CHART_MODEL=?, CHART_TYPE=?, PERIOD=?, BACK_COLOR=?,
                  LINE_COLOR=?, COLUMN_COLOR=?, DEFAULT_COLOR=?, JCHIGHT_COLOR=?, JCLOW_COLOR=?, CHART_SELECT=?, CHART_ORDER=?
            WHERE CHART_ID = ?
            """
        
        try chartInsertUpdate(chart: chart, sql: updateSQL)
        try chartIndicatorUpdateAll(chart: chart)
    }
    
    private func chartInsertUpdate(chart: ChartSetting, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 13, chart.id, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 1, chart.desc,  -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, chart.model, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 3, chart.type,  -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 4, chart.period,-1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 5, colorToString(color: chart.backColor), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 6, colorToString(color: chart.lineColor), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 7, colorToString(color: chart.columnColor), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 8, colorToString(color: chart.defaultColor), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 9, colorToString(color:chart.jcHighColor), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 10, colorToString(color:chart.jcLowColor), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 11, chart.selected,-1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_int(statement, 12, chart.order) == SQLITE_OK
        
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            if db.errorCode == "19" {
                throw SQLiteError.Duplicate(message: db.errorMessage)
            }
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func chartDelete(chart: ChartSetting) throws {
        try chartIndicatorDelete(chart: chart)
        try chartDelete(id: chart.id)
    }
    
    func chartDelete(id: String) throws {
        let deleteSQL = "DELETE FROM CHART_SETTING WHERE CHART_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    // MARK: - indicator Setting
    func getIndicator(id: String) throws -> IndicatorSetting {
        
        let selectSQL = """
                SELECT INDICATOR_ID, DESCRIPTION, DRAWING_MODEL, INDIC_TYPE, DEFAULT_VALUE1, DEFAULT_VALUE2,
                        DEFAULT_VALUE3, DEFAULT_COLOR1, DEFAULT_COLOR2, SPLINE_VALUE1, SPLINE_COLOR1, SPLINE_VALUE2,
                        SPLINE_COLOR2, SPLINE_ZERO, SPLINE_COLOR0, MA1_COLOR, MA1_VALUE, MA1_TYPE, MA2_COLOR,
                        MA2_VALUE, MA2_TYPE
                FROM INDICATOR_SETTING WHERE INDICATOR_ID = ?
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw SQLiteError.NotFound(message: db.errorMessage)
        }
        
        let indicator: IndicatorSetting = IndicatorSetting.init()
        
        indicator.id = String(cString: (sqlite3_column_text(statement, 0)))
        indicator.desc = String(cString: (sqlite3_column_text(statement, 1)))
        indicator.model = String(cString: (sqlite3_column_text(statement, 2)))
        indicator.type = String(cString: (sqlite3_column_text(statement, 3)))
        indicator.value1 = sqlite3_column_double(statement, 4)
        indicator.value2 = sqlite3_column_double(statement, 5)
        indicator.value3 = sqlite3_column_double(statement, 6)
        indicator.color1 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 7))) )
        indicator.color2 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 8))) )
        
        indicator.splineValue1 = String(cString: (sqlite3_column_text(statement, 9)))
        indicator.splineColor1 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 10))) )
        indicator.splineValue2 = String(cString: (sqlite3_column_text(statement, 11)))
        indicator.splineColor2 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 12))) )
        indicator.splineZero = String(cString: (sqlite3_column_text(statement, 13)))
        indicator.splineColor0 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 14))) )
        
        indicator.maColor1 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 15))) )
        indicator.maValue1 = sqlite3_column_double(statement, 16)
        indicator.maType1 = String(cString: (sqlite3_column_text(statement, 17)))
        
        indicator.maColor2 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 18))) )
        indicator.maValue2 = sqlite3_column_double(statement, 19)
        indicator.maType2 = String(cString: (sqlite3_column_text(statement, 20)))
        return indicator
    }

    
    func getIndicatorList() throws -> Array<IndicatorSetting>  {
        var inicatortArray = [IndicatorSetting]()
        
        let selectSQL = """
                SELECT INDICATOR_ID, DESCRIPTION, DRAWING_MODEL, INDIC_TYPE, DEFAULT_VALUE1, DEFAULT_VALUE2,
                        DEFAULT_VALUE3, DEFAULT_COLOR1, DEFAULT_COLOR2, SPLINE_VALUE1, SPLINE_COLOR1, SPLINE_VALUE2,
                        SPLINE_COLOR2, SPLINE_ZERO, SPLINE_COLOR0, MA1_COLOR, MA1_VALUE, MA1_TYPE, MA2_COLOR,
                        MA2_VALUE, MA2_TYPE
                FROM INDICATOR_SETTING
                ORDER BY DESCRIPTION 
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            
            let indicator: IndicatorSetting = IndicatorSetting.init()
            
            indicator.id = String(cString: (sqlite3_column_text(statement, 0)))
            indicator.desc = String(cString: (sqlite3_column_text(statement, 1)))
            indicator.model = String(cString: (sqlite3_column_text(statement, 2)))
            indicator.type = String(cString: (sqlite3_column_text(statement, 3)))
            indicator.value1 = sqlite3_column_double(statement, 4)
            indicator.value2 = sqlite3_column_double(statement, 5)
            indicator.value3 = sqlite3_column_double(statement, 6)
            indicator.color1 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 7))) )
            indicator.color2 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 8))) )
           
            indicator.splineValue1 = String(cString: (sqlite3_column_text(statement, 9)))
            indicator.splineColor1 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 10))) )
            indicator.splineValue2 = String(cString: (sqlite3_column_text(statement, 11)))
            indicator.splineColor2 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 12))) )
            indicator.splineZero = String(cString: (sqlite3_column_text(statement, 13)))
            indicator.splineColor0 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 14))) )
            
            indicator.maColor1 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 15))) )
            indicator.maValue1 = sqlite3_column_double(statement, 16)
            indicator.maType1 = String(cString: (sqlite3_column_text(statement, 17)))
            
            indicator.maColor2 = stringToColor(color:  String(cString: (sqlite3_column_text(statement, 18))) )
            indicator.maValue2 = sqlite3_column_double(statement, 19)
            indicator.maType2 = String(cString: (sqlite3_column_text(statement, 20)))
            
            inicatortArray.append(indicator)
        }
        return inicatortArray
    }
    
    func indicatorInsert(indicator: IndicatorSetting) throws {
        
        let insertSQL = """
            INSERT INTO INDICATOR_SETTING
                    ( DESCRIPTION, DRAWING_MODEL, INDIC_TYPE, DEFAULT_VALUE1, DEFAULT_VALUE2,
                      DEFAULT_VALUE3, DEFAULT_COLOR1, DEFAULT_COLOR2, SPLINE_VALUE1, SPLINE_COLOR1, SPLINE_VALUE2,
                      SPLINE_COLOR2, SPLINE_ZERO, SPLINE_COLOR0, MA1_COLOR, MA1_VALUE, MA1_TYPE, MA2_COLOR,
                      MA2_VALUE, MA2_TYPE, INDICATOR_ID )
            VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        
        try indicatorInsertUpdate(indicator: indicator, sql: insertSQL )
    }
    
    
    func indicatorUpdate(indicator: IndicatorSetting) throws {
        
        let updateSQL = """
            UPDATE INDICATOR_SETTING SET DESCRIPTION = ?, DRAWING_MODEL = ?, INDIC_TYPE = ?, DEFAULT_VALUE1 = ?, DEFAULT_VALUE2 = ?,
                      DEFAULT_VALUE3 = ?, DEFAULT_COLOR1 = ?, DEFAULT_COLOR2 = ?, SPLINE_VALUE1 = ?, SPLINE_COLOR1 = ?, SPLINE_VALUE2 = ?,
                      SPLINE_COLOR2 = ?, SPLINE_ZERO = ?, SPLINE_COLOR0 = ?, MA1_COLOR = ?, MA1_VALUE = ?, MA1_TYPE = ?, MA2_COLOR = ?,
                      MA2_VALUE = ?, MA2_TYPE = ?
            WHERE  INDICATOR_ID = ?
            """
        
        try indicatorInsertUpdate(indicator: indicator, sql: updateSQL )
    }
    
    private func indicatorInsertUpdate(indicator: IndicatorSetting, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 21, indicator.id, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 1, indicator.desc,  -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, indicator.model, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 3, indicator.type,  -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 4, indicator.value1) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 5, indicator.value2) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 6, indicator.value3) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 7, colorToString(color: indicator.color1), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 8, colorToString(color: indicator.color2), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            
            sqlite3_bind_text(statement, 9, indicator.splineValue1, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 10, colorToString(color: indicator.splineColor1), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 11, indicator.splineValue2, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 12, colorToString(color: indicator.splineColor2), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 13, indicator.splineZero, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 14, colorToString(color:indicator.splineColor0), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
           
            sqlite3_bind_text(statement, 15, colorToString(color:indicator.maColor1), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_double(statement, 16, indicator.maValue1) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 17, indicator.maType1,-1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 18, colorToString(color:indicator.maColor2), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_double(statement, 19, indicator.maValue2) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 20, indicator.maType2,-1, SQLITE_TRANSIENT) == SQLITE_OK
            
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            if db.errorCode == "19" {
                throw SQLiteError.Duplicate(message: db.errorMessage)
            }
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func indicatorDelete(indicator: IndicatorSetting) throws {
        try chartIndicatorDelete(indic: indicator)
        try indicatorDelete(id: indicator.id)
    }
    
    func indicatorDelete(id: String) throws {
        let deleteSQL = "DELETE FROM INDICATOR_SETTING WHERE INDICATOR_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    // MARK: - Chart Indicator
    func getChartIndicatorList(chart: ChartSetting) throws -> Array<ChartIndicator>  {
        var inicatortArray = [ChartIndicator]()
        
        let selectSQL = """
            SELECT LINE_ID, CHART_ID, INDICATOR_SETTING.INDICATOR_ID, INDICATOR_SETTING.DESCRIPTION, DEFAULT_VALUE, VALUE1, VALUE2, VALUE3, COLOR1, COLOR2, ACTIVE
              FROM CHART_INDICATOR, INDICATOR_SETTING
             WHERE CHART_INDICATOR.INDICATOR_ID = INDICATOR_SETTING.INDICATOR_ID
               AND CHART_ID = ?
            """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_bind_text(statement, 1, chart.id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            
            let chartIndic: ChartIndicator = ChartIndicator.init()
            
            chartIndic.id = String(cString: (sqlite3_column_text(statement, 0)))
            chartIndic.chartId = String(cString: (sqlite3_column_text(statement, 1)))
            chartIndic.indicatorId = String(cString: (sqlite3_column_text(statement, 2)))
            chartIndic.indicatorDesc = String(cString: (sqlite3_column_text(statement, 3)))
            chartIndic.defaultValue = String(cString: (sqlite3_column_text(statement, 4)))
            chartIndic.value1 = sqlite3_column_double(statement, 5)
            chartIndic.value2 = sqlite3_column_double(statement, 6)
            chartIndic.value3 = sqlite3_column_double(statement, 7)
            chartIndic.color1 = stringToColor(color: String(cString: (sqlite3_column_text(statement, 8))) )
            chartIndic.color2 = stringToColor(color: String(cString: (sqlite3_column_text(statement, 9))) )
            chartIndic.active = String(cString: (sqlite3_column_text(statement, 10)))
            
            inicatortArray.append(chartIndic)
        }
        return inicatortArray
    }
    
    func chartIndicatorUpdateAll(chart: ChartSetting) throws {
        for chartIndic in chart.chartIndic {
            if chartIndic.id == "-1" { //new insert
                chartIndic.id = String(SequenceDB.instance.nextSequence(id: "CHARTINDIC"))
                chartIndic.chartId = chart.id
                try chartIndicatorInsert(chartIndic: chartIndic)
            } else {
                try chartIndicatorUpdate(chartIndic: chartIndic)
            }
        }
    }
    
    func chartIndicatorInsert(chartIndic: ChartIndicator) throws {
        
        let insertSQL = """
            INSERT INTO CHART_INDICATOR
                (CHART_ID, INDICATOR_ID, DEFAULT_VALUE, VALUE1, VALUE2, VALUE3, COLOR1, COLOR2, ACTIVE, LINE_ID )
            VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        
        try chartIndicatorInsertUpdate(chartIndic: chartIndic, sql: insertSQL)
    }
    
    
    func chartIndicatorUpdate(chartIndic: ChartIndicator) throws {
        
        let updateSQL = """
            UPDATE CHART_INDICATOR SET CHART_ID = ?, INDICATOR_ID = ?, DEFAULT_VALUE = ?, VALUE1 = ?, VALUE2 = ?, VALUE3 = ?,
                COLOR1 = ?, COLOR2 = ?, ACTIVE = ?
            WHERE LINE_ID = ?
            """
        
        try chartIndicatorInsertUpdate(chartIndic: chartIndic, sql: updateSQL)
    }
    
    private func chartIndicatorInsertUpdate(chartIndic: ChartIndicator, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 10, chartIndic.id, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 1, chartIndic.chartId,  -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, chartIndic.indicatorId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 3, chartIndic.defaultValue,  -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 4, chartIndic.value1) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 5, chartIndic.value2) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 6, chartIndic.value3) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 7, colorToString(color: chartIndic.color1), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 8, colorToString(color: chartIndic.color2), -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 9, chartIndic.active,-1, SQLITE_TRANSIENT) == SQLITE_OK
            
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            if db.errorCode == "19" {
                throw SQLiteError.Duplicate(message: db.errorMessage)
            }
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func chartIndicatorDelete(chartIndic: [ChartIndicator]) throws {
        let deleteSQL = "DELETE FROM CHART_INDICATOR WHERE LINE_ID = ?"
        for chId in chartIndic {
            try chartIndicatorDelete(id: chId.id, sql: deleteSQL)
        }
    }
    
    func chartIndicatorDelete(chart: ChartSetting) throws {
        let deleteSQL = "DELETE FROM CHART_INDICATOR WHERE CHART_ID = ?"
        try chartIndicatorDelete(id: chart.id, sql: deleteSQL)
    }
    
    func chartIndicatorDelete(indic: IndicatorSetting) throws {
        let deleteSQL = "DELETE FROM CHART_INDICATOR WHERE INDICATOR_ID = ?"
        try chartIndicatorDelete(id: indic.id, sql: deleteSQL)
    }
    
    func chartIndicatorDelete(id: String, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
}
