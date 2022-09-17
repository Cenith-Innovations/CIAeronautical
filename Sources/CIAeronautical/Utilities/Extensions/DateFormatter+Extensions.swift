//
//  File.swift
//  
//
//  Created by Jorge Alvarez on 9/6/22.
//

import Foundation

public extension DateFormatter {
    
    /// Returns DateFormatter that uses UTC time zone for decoding METAR/TAF/Forecast Dates
    static let weatherDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return formatter
    }()
    
    static var sharedTimeZoneFormatter = DateFormatter()
    
    /// Returns a String of Date passed in that matches TimeZone passed in. Returns nil if timeZone is invalid
    static func dateForTimeZone(timeZone: String, date: Date) -> String? {
        guard let validTimeZone = TimeZone(abbreviation: timeZone) else { return nil }
        sharedTimeZoneFormatter.timeZone = validTimeZone
        // example from AirNow app: "9 AM PDT SEP 16, 2022"
        sharedTimeZoneFormatter.dateFormat = "h a zzz MMM d, yyyy"
        return sharedTimeZoneFormatter.string(from: date)
    }
}
