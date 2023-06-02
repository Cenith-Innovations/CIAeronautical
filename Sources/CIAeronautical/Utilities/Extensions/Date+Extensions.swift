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
    static func getAhasDateComponents() -> (year: String, month: String, day: String, hourZ: String) {
        let now = Date()
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let year = String(cal.component(.year, from: now))
        let month = String(cal.component(.month, from: now))
        let day = String(cal.component(.day, from: now))
        let hourZ = String(cal.component(.hour, from: now))
        return (year: year, month: month, day: day, hourZ: hourZ)
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
    
    /// Ex: "2022-09-28 " -> "Wednesday"
    static func weekdayString(dateString: String?) -> String? {
        
        guard let dateString = dateString else { return nil }
        
        let yearMonthDay = dateString.trimmingCharacters(in: .whitespaces).split(separator: "-")
        guard yearMonthDay.count == 3, let year = Int(yearMonthDay[0]), let month = Int(yearMonthDay[1]), let day = Int(yearMonthDay[2]) else {
            print("\(yearMonthDay) could not be made into comps")
            return nil
        }
        
        let cal = Calendar.current
        let comps = DateComponents(calendar: cal, year: year, month: month, day: day)
        if let date = cal.date(from: comps) {
            let dateComps = cal.component(.weekday, from: date)
            switch dateComps {
            case 1:
                return "Sunday"
            case 2:
                return "Monday"
            case 3:
                return "Tuesday"
            case 4:
                return "Wednesday"
            case 5:
                return "Thursday"
            case 6:
                return "Friday"
            case 7:
                return "Saturday"
            default:
                return nil
            }
        }
        
        return nil
    }
    
    /// Returns an optional String version of the passed in date. Ex: "2022-09-18"
    static func yearMonthDayString(date: Date) -> String? {
        let currentDateComps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        var currentDayString: String?
        if let year = currentDateComps.year, let month = currentDateComps.month, let day = currentDateComps.day {
            let monthString = month < 10 ? "0\(month)" : "\(month)"
            let dayString = day < 10 ? "0\(day)" : "\(day)"
            currentDayString = "\(year)-\(monthString)-\(dayString)"
        }
        return currentDayString
    }
    
    /// Converts date component Strings into a Date that's returned
    static func componentsToDate(dateObserved: String?, hourObserved: Int?, timeZone: String?) -> Date? {
        
        guard let dateObserved = dateObserved, let hourObserved = hourObserved, let timeZone = timeZone else { return nil }
        
        let yearMonthDay = dateObserved.trimmingCharacters(in: .whitespaces).split(separator: "-")
        guard yearMonthDay.count == 3, let year = Int(yearMonthDay[0]), let month = Int(yearMonthDay[1]), let day = Int(yearMonthDay[2]), let time = TimeZone(abbreviation: timeZone) else {
            print("\(yearMonthDay) could not be made into comps")
            return nil
        }
                
        var cal = Calendar.current
        cal.timeZone = time
        let comps = DateComponents(calendar: cal,
                                   timeZone: time,
                                   year: year,
                                   month: month,
                                   day: day,
                                   hour: hourObserved)
        
        // if we're in daylight saving time, PST will be treated as PDT, so lets use offset
        if time.isDaylightSavingTime() {
            return cal.date(from: comps)?.addingTimeInterval((time.daylightSavingTimeOffset()))
        }
        
        return cal.date(from: comps)
        
    }
}
