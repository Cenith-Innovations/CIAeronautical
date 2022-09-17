//
//  File.swift
//  
//
//  Created by Jorge Alvarez on 9/9/22.
//

import Foundation
import SwiftUI

public struct AirQuality: Decodable, Hashable {
    
    // MARK: - CodingKeys
    
    public enum CodingKeys: String, CodingKey {
        case dateObserved = "DateObserved"
        case hourObserved = "HourObserved"
        case localTimeZone = "LocalTimeZone"
        case reportingArea = "ReportingArea"
        case stateCode = "StateCode"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case parameterName = "ParameterName"
        case aqi = "AQI"
        case category = "Category"
        
        public enum CategoryCodingKeys: String, CodingKey {
            case number = "Number"
            case name = "Name"
        }
    }
    
    // TODO: make separate property that comes as a Date made of other components?
    
    public var dateObserved: String?
    public var hourObserved: Int?
    public var localTimeZone: String?
    public var reportingArea: String?
    public var stateCode: String?
    public var latitude: Double?
    public var longitude: Double?
    public var parameterName: String?
    public var aqi: Int?
    public var categoryName: String?
    public var categoryNumber: Int?
    
    public var observationHour: Int?
    /// UTC version of date components from API ("2022-09-10 ", 7, "PST"-> Date?)
    public var observationDate: Date?
    
    /// String version of observation date that shows area's local timezone and uses comps as backup if building Date fails
    public var observationDateString: String?
    
    /// Used so we know when we shouldn't do another request to API since we're limited to 500 an hour per api key
    public let dateFetched = Date()
    
    public var backupDateString: String {
        guard let dateObserved = dateObserved, let hour = hourObserved, let timeZone = localTimeZone else {
            return "Unknown Date"
        }
        
        let hourString = hour < 10 ? "0\(hour)" : "\(hour)"
        
        return "\(hourString)00 \(timeZone), \(dateObserved.trimmingCharacters(in: .whitespaces))"
    }
    
    /// Compares if observationDate is
    public var observationNeedsRefresh: Bool {
        
        // TODO: also first check that we haven't last refreshed in less than 5 minutes
        
        // if observationDate is nil, check dateFetched instead
        guard let observationDate = observationDate else {
            // as a fallback, check dateFetched so we always fetch again if it's been more than an hour
            let diff = Date().timeIntervalSinceReferenceDate - dateFetched.timeIntervalSinceReferenceDate
            let hours = Int(diff) / 60
            return hours > 0
        }
        
        // use observationDate and Date()
        let observationHour = Calendar.current.dateComponents([.hour], from: observationDate).hour
        let currentHour = Calendar.current.dateComponents([.hour], from: Date()).hour
        // also check dateFetched to also check if its been more than an hour so we can safely make another request
        print("observationHour = \(observationHour), currentHour = \(currentHour)")
        let result = observationHour != currentHour
        print("observationNeedsRefresh: \(result)")
        return result
    }
    
    /// Returns Date? using date components returned from API ("2022-09-10 ", 7, "PST"-> Date?)
    private var dateFromComps: Date? {
        let result =  Date.componentsToDate(dateObserved: dateObserved, hourObserved: hourObserved, timeZone: localTimeZone)
        return result
    }
    
    /// Returns Color tuple for background / text color based on AQI. Returns gray if no AQI or out of range AQI
    public var color: (back: Color, text: Color) {
        
        guard let aqi = aqi, aqi > 0 else { return (Color.gray, Color.black) }
        
        switch aqi {
        case 0...50:
            return (Color.green, Color.black)
        case 51...100:
            return (Color.yellow, Color.black)
        case 101...150:
            return (Color.orange, Color.white)
        case 151...200:
            return (Color.red, Color.white)
        case 201...300:
            return (Color.purple, Color.white)
        default:
            return (Color(red: 126.0 / 255.0, green: 0.0 / 255.0, blue: 35.0 / 255.0), Color.white)
        }
    }
    
    // MARK: - Decode
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let categoryContaier = try container.nestedContainer(keyedBy: CodingKeys.CategoryCodingKeys.self, forKey: .category)
        
        // dateObserved
        dateObserved = try container.decode(String.self, forKey: .dateObserved)
        
        // hourObserved
        hourObserved = try container.decode(Int.self, forKey: .hourObserved)
        
        // localTimeZone
        localTimeZone = try container.decode(String.self, forKey: .localTimeZone)
        
        // reportingArea
        reportingArea = try container.decode(String.self, forKey: .reportingArea)
        
        // stateCode
        stateCode = try container.decode(String.self, forKey: .stateCode)
        
        // latitude
        latitude = try container.decode(Double.self, forKey: .latitude)
        
        // longitude
        longitude = try container.decode(Double.self, forKey: .longitude)
        
        // parameterName
        parameterName = try container.decode(String.self, forKey: .parameterName)
        
        // aqi
        aqi = try container.decode(Int.self, forKey: .aqi)
        
        // categoryName
        categoryName = try categoryContaier.decode(String.self, forKey: .name)
        
        // categoryNumber
        categoryNumber = try categoryContaier.decode(Int.self, forKey: .number)
        
        // Non-API properties
        
        // observationDate
        observationDate = dateFromComps
        
        // observationDateString
        if let timeZone = localTimeZone, let date = observationDate, let dateString = DateFormatter.dateForTimeZone(timeZone: timeZone, date: date) {
            observationDateString = dateString
        }
    }

    /// Takes in an array of AirQuality and returns the one with the highest AQI
    public static func highestAqi(aqs: [AirQuality]) -> AirQuality? {
                
        // return nil if array is empty
        guard let firstAq = aqs.first else { return nil }
        
        var resultAq = firstAq
        
        for aq in aqs {
            if let currAqi = aq.aqi, let resultAqi = resultAq.aqi, currAqi > resultAqi { resultAq = aq }
        }
        
        return resultAq
    }
}
