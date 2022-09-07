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
}
