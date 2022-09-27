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
        case dateIssue = "DateIssue"
        case dateForecast = "DateForecast"
        case actionDay = "ActionDay"
        case discussion = "Discussion"
        
        public enum CategoryCodingKeys: String, CodingKey {
            case number = "Number"
            case name = "Name"
        }
    }
        
    /// Current Observation only.
    public var dateObserved: String?
    
    public var hourObserved: Int?
    public var localTimeZone: String?
    public var reportingArea: String?
    public var stateCode: String?
    public var latitude: Double?
    public var longitude: Double?
    public var parameterName: String?
    /// Can come back as -1 if not AQI is available (usually only happens with forecasts and not current observations(?))
    public var aqi: Int?
    public var categoryName: String?
    public var categoryNumber: Int?
        
    // Forecast properties only
    
    /// Forecast only
    public var dateIssue: String?
    
    /// Forecast only
    public var dateForecast: String?
    
    /// Forecast only.
    public var actionDay: Bool?
    
    // Discussion
    /// Forecast only. Usually empty. Could also sometimes be url
    public var discussion: String?
    
    // Custom properties
    public var pollutant: String?
    
    /// Contains city and state from reportingArea and stateCode with country=USA every time. Starts as https://www.airnow.gov
    public var detailUrl = URL(string: "https://www.airnow.gov")!
    
    public var observationHour: Int?
    
    /// UTC version of date components from API ("2022-09-10 ", 7, "PST"-> Date?)
    public var observationDate: Date?
    
    /// String version of observation date that shows area's local timezone and uses comps as backup if building Date fails
    public var observationDateString: String?
    
    /// Used so we know when we shouldn't do another request to API since we're limited to 500 an hour per api key
    public let dateFetched = Date()
    
    public var backupDateString: String {
        // TODO: add portion that returns backup date string for forecast too?
        guard let dateObserved = dateObserved, let hour = hourObserved, let timeZone = localTimeZone else {
            return "Unknown Date"
        }
        
        let hourString = hour < 10 ? "0\(hour)" : "\(hour)"
        
        return "\(hourString)00 \(timeZone), \(dateObserved.trimmingCharacters(in: .whitespaces))"
    }
    
    // MARK: - Computed Properties
    
    /// Returns whether or not enough time has passed to fetch a new AQI Forecast by checking last fetched forecast's date (day only). Should only be used on AirQualities we get back from the forecast request, not current observation.
    static public func forecastNeedsRefresh(currentDayString: String, forecasts: [AirQuality]?) -> Bool {        
        guard let forecastDateFetched = forecasts?.first?.dateFetched, let dateFetchedString = Date.yearMonthDayString(date: forecastDateFetched), let forecastDayString = forecasts?.first?.dateForecast?.trimmingCharacters(in: .whitespaces) else {
            return true
        }
        
        // return false if dateFetchedString matches currentDayString
        if dateFetchedString == currentDayString {
            print("No refresh: dateFetched = \(dateFetchedString), currentDayString = \(currentDayString)")
            return false
        }
        
        if forecastDayString == currentDayString {
            print("No refresh: forecastDayString = \(forecastDayString), currentDayString = \(currentDayString)")
            return false
        }
        
        return true
    }
    
    /// Compares if observationDate is
    public var observationNeedsRefresh: Bool {
        
        // 1. make sure at least 5 minutes have passed since dateFetched
        let diff = Date().timeIntervalSinceReferenceDate - dateFetched.timeIntervalSinceReferenceDate
        let mins = Int(diff) / 60
        if mins < 10 {
            print("its been less than 10 minutes since we last fetched, returning early")
            return false
        }
                
        // 2. only fetch if hour observed and current hour are NOT the same
        // if observationDate is nil, check dateFetched instead
        guard let observationDate = observationDate else {
            print("observationDate could not be made, checking dateFetched as fallback")
            // as a fallback, return true if it's been more than 1 hour since we last fetched current observation
            let hours = Int(mins) / 60
            if hours > 0 {
                print("it's been more than 1 hour, current observation needs refresh")
                return true
            } else {
                print("it's been 1 hour or less, current observation does not need refresh")
                return false
            }
        }
        
        // use observationDate and Date()
        let observationHour = Calendar.current.dateComponents([.hour], from: observationDate).hour
        let currentHour = Calendar.current.dateComponents([.hour], from: Date()).hour
        print("observationHour = \(String(describing: observationHour)), currentHour = \(String(describing: currentHour))")
        let result = observationHour != currentHour
        print("observationNeedsRefresh: \(result)")
        return result
    }
    
    /// Returns Date? using date components returned from API ("2022-09-10 ", 7, "PST"-> Date?)
    private var dateFromComps: Date? {
        let result =  Date.componentsToDate(dateObserved: dateObserved, hourObserved: hourObserved, timeZone: localTimeZone)
        return result
    }
    
    private var pollutantFromParameter: String? {
        guard let name = parameterName else { return nil }
        switch name {
        case "O3":
            return "Ozone"
        case "PM2.5":
            return "Fine Particles"
        case "PM10":
            return "Coarse Particles"
        default:
            return nil
        }
    }
    
    /// Returns Color tuple for background / text color based on AQI. Returns gray if no AQI or out of range AQI
    public var color: (back: Color, text: Color) {
        
        guard let name = categoryNumber else { return (Color.gray, Color.black) }
        switch name {
        case 1:
            // Green
            return (Color(red: 0.0 / 255.0, green: 228.0 / 255.0, blue: 0.0 / 255.0), Color.black)//(Color.green, Color.black)
        case 2:
            // Yellow
            return (Color(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0), Color.black)
        case 3:
            // Orange
            return (Color(red: 255.0 / 255.0, green: 126.0 / 255.0, blue: 0.0 / 255.0), Color.white)
        case 4:
            // Red
            return (Color(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0), Color.white)
        case 5:
            // Purple
            return (Color(red: 143.0 / 255.0, green: 63.0 / 255.0, blue: 151.0 / 255.0), Color.white)
        case 6:
            // Maroon
            return (Color(red: 126.0 / 255.0, green: 0.0 / 255.0, blue: 35.0 / 255.0), Color.white)
        default:
            return (Color.gray, Color.black)
        }
    }
    
    // MARK: - Decode
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let categoryContaier = try container.nestedContainer(keyedBy: CodingKeys.CategoryCodingKeys.self, forKey: .category)
        
        // dateObserved
        dateObserved = try? container.decode(String.self, forKey: .dateObserved)
        
        // hourObserved
        hourObserved = try? container.decode(Int.self, forKey: .hourObserved)
        
        // localTimeZone
        localTimeZone = try? container.decode(String.self, forKey: .localTimeZone)
        
        // reportingArea
        reportingArea = try? container.decode(String.self, forKey: .reportingArea)
        
        // stateCode
        stateCode = try? container.decode(String.self, forKey: .stateCode)
        
        // latitude
        latitude = try? container.decode(Double.self, forKey: .latitude)
        
        // longitude
        longitude = try? container.decode(Double.self, forKey: .longitude)
        
        // parameterName
        parameterName = try? container.decode(String.self, forKey: .parameterName)
        
        // aqi
        aqi = try? container.decode(Int.self, forKey: .aqi)
        
        // categoryName
        categoryName = try? categoryContaier.decode(String.self, forKey: .name)
        
        // categoryNumber
        categoryNumber = try? categoryContaier.decode(Int.self, forKey: .number)
        
        // Forecast properties
        
        // dateIssue
        dateIssue = try? container.decode(String.self, forKey: .dateIssue)
        
        // dateForecast
        dateForecast = try? container.decode(String.self, forKey: .dateForecast)
        
        // actionDay
        actionDay = try? container.decode(Bool.self, forKey: .actionDay)
        
        // discussion
        discussion = try? container.decode(String.self, forKey: .discussion)
        
        // Custom properties
        
        // pollutant
        pollutant = pollutantFromParameter
        
        // detailUrl
        if let url = urlFromAreaAndState { detailUrl = url }
        
        // observationDate
        observationDate = dateFromComps
        
        // observationDateString
        if let timeZone = localTimeZone, let date = observationDate, let dateString = DateFormatter.dateForTimeZone(timeZone: timeZone, date: date) {
            observationDateString = dateString
        }
        
        // forecastDate
        // forecastDateString
    }
    
    /// Ex: "https://www.airnow.gov/?city=Las%20Vegas&state=NV&country=USA"
    private var urlFromAreaAndState: URL? {
        if let area = reportingArea, let state = stateCode {
            let city = area.replacingOccurrences(of: " ", with: "%20")
            return URL(string: "https://www.airnow.gov/?city=\(city)&state=\(state)&country=USA")
        }
        return nil
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
