//
//  CDate.swift
//  Trading
//
//  Created by Maroun Achille on 08/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class CDate {
    static let dateFormatter = DateFormatter()
    
    static func getTime (_ value: Double) -> Date {
        return Date(timeIntervalSince1970: value)
    }
    
    static func formatDate(_ date1: Date, _ format: String) -> String {
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMD")
        let date: String = dateFormatter.string(from: date1)
        return date
    }
    
    static func dateFromDB(_ value: String?) -> Date? {
        if let value = value {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: value) {
                return date
            }
        }
        return nil
    }
    
    static func dateToDB(_ value: Date?) -> String? {
        if let value = value {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: value)
            return date
            
        }
        return nil
    }
    
    static func defaultForamt(_ value: Date?) -> String {
        if let value = value {
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let date = dateFormatter.string(from: value)
            return date
            
        }
        return "..."
    }
    
    static func dateQuote(_ value: Date?) -> String? {
        if let value = value {
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            let date = dateFormatter.string(from: value)
            return date
            
        }
        return nil
    }
    
    static func dateQuoteShort(_ value: Date?) -> String? {
        if let value = value {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let date = dateFormatter.string(from: value)
            return date
            
        }
        return nil
    }
    
    static func dateQuoteTime(_ value: Date?) -> String {
        if let value = value {
            dateFormatter.dateFormat = "HH:mm"
            let date = dateFormatter.string(from: value)
            return date
            
        }
        return "00:00"
    }
    
    static func subDate( _ date1: Date, _ period: String) -> Date {
        let strSplit = period.split(separator: " ")
        if let value =  Int(strSplit[0]) {
            if strSplit[1].hasPrefix("Day") {
                return NSCalendar.current.date(byAdding: .day, value: value * -1,  to: date1)!
            } else if strSplit[1].hasPrefix("Month") {
                return NSCalendar.current.date(byAdding: .month, value: value * -1,  to: date1)!
            } else {
                return NSCalendar.current.date(byAdding: .year, value: value * -1,  to: date1)!
            }
        }
        return NSCalendar.current.date(byAdding: .month, value: -9,  to: date1)!
    }
    
    static func addDate( _ date1: Date, _ period: String) -> Date {
        let strSplit = period.split(separator: " ")
        if let value =  Int(strSplit[0]) {
            if strSplit[1].hasPrefix("Day") {
                return NSCalendar.current.date(byAdding: .day, value: value,  to: date1)!
            } else if strSplit[1].hasPrefix("Month") {
                return NSCalendar.current.date(byAdding: .month, value: value,  to: date1)!
            } else {
                return NSCalendar.current.date(byAdding: .year, value: value,  to: date1)!
            }
        }
        return NSCalendar.current.date(byAdding: .month, value: 9,  to: date1)!
    }
    
    static func addMonth(_ date1: Date , _ count: Int) -> Int {
        if let date2 = NSCalendar.current.date(byAdding: .month, value: count,  to: date1) {
            return Calendar.current.component(.month, from: date2)
        }
        return 0
    }
    
    static func getMonth(_ date1: Date) -> Int {
        return Calendar.current.component(.month, from: date1)
    }
    
    static func lastOpenDate(date: Date) -> Date {
        var openDate = date
        repeat {
            openDate = openDate - 1 * 60 * 60 * 24
        } while !isOpenDate(date: openDate)
            
        return openDate
    }
    
    
    static func nextOpenDate(date: Date) -> Date {
        var openDate = date
        repeat {
            openDate = openDate + 1 * 60 * 60 * 24
        } while !isOpenDate(date: openDate)
        
        return openDate
    }
    
    static func isOpenDate(date: Date) -> Bool {
        let weekDay = Calendar.current.component(.weekday, from: date)
        if weekDay == 7  || weekDay == 1 {
            return false
        } else {
            return true
        }
    }
    
    static func timeStampFrom(date: Date) -> Double {
        let dateValue = Calendar.current.date(bySettingHour: 4, minute: 0, second: 0, of: date)
        return dateValue!.timeIntervalSince1970
    }
    
    static func timeStampTo(date: Date) -> Double {
        let dateValue = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: date)
        return dateValue!.timeIntervalSince1970
    }
    
    static func startDate() -> Date {
        let lastUpdateDate = lastOpenDate(date: Date())
        let year:Int = Calendar.current.component(.year, from: lastUpdateDate) - 10
        return dateFromDB("\(year)-12-29")!
    }
    
    static func stripTime(from originalDate: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: originalDate)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    static func yearDate(date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: date)
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
