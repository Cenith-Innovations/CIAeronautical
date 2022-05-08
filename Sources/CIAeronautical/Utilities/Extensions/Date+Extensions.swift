// ********************** Date+Extensions *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Date+Extensions *********************************


import Foundation

public extension Date {
    
    ///Returns Dates of Now and hours in the future Date
    static func getDateForTaf(startTime: Date? = Date(), nowPlusHours: Int) -> (now: Date?, endTime: Date?) {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let endTime = calendar.date(byAdding: .hour, value: nowPlusHours, to: startTime!)
        return (now: startTime!, endTime: endTime)
    }
    
    ///Returns string date components for now to enter in ahasDownloader.
    static func getAhasDateComponents() -> (month: String, day: String, hourZ: String) {
        let now = Date()
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let month = String(cal.component(.month, from: now))
        let day = String(cal.component(.day, from: now))
        let hourZ = String(cal.component(.hour, from: now))
        return (month: month, day: day, hourZ: hourZ)
    }
    
    /// Returns a String of passed of Date's hour in Zulu / UTC
    /// - Parameters:
    ///   - date: Date we pass in to get back its hour component in Zulu / UTC
    static func getCurrHourZulu(date: Date) -> String {
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let hourZ = String(cal.component(.hour, from: date))
        return hourZ
    }
}
