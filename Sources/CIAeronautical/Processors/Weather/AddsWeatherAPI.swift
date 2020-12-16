// ********************** AddsWeatherAPI *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AddsWeatherAPI *********************************


import Foundation

/** API to generate a URL to download either the TAF or the METAR.
 
[METARS](https://www.aviationweather.gov/dataserver)
 
[Explanation of fields](https://www.aviationweather.gov/dataserver/fields?datatype=metar)
 
[TAF](https://www.aviationweather.gov/dataserver)
 
[Explanation of fields](https://www.aviationweather.gov/dataserver/fields?datatype=taf)
*/
public struct AddsWeatherAPI {
    private static let baseURLString = "https://www.aviationweather.gov/adds/dataserver_current/httpparam?"
    public enum EndPoint {
        case metar
        case taf
    }
    
    //Creates Strings to plug in to the TAF website for start and end times
    private func getTafStartAndEndTimes(timeIntervalHrs: Int) -> (start: String, end: String) {
        let times = Date.getDateForTaf(nowPlusHours: timeIntervalHrs)
        let df = DateFormatter()
        df.dateFormat = DateFormat.reference.value
        let start = "\(Int(times.now!.timeIntervalSince1970.rounded()))"
        let end = "\(Int(times.endTime!.timeIntervalSince1970.rounded()))"
        return (start: start, end: end)
    }
    
    /// Generates the URL to use to download TAF/METAR
    /// - Parameters:
    ///   - type: Are you downloading the TAF or the METAR. These are things you'll have to decide.
    ///   - icao: ICAO of the field you want the weather for.
    /// - Returns: The Weather.
    public func weatherURL(type: EndPoint,
                           icao: String) -> URL {
        var components = URLComponents(string: AddsWeatherAPI.baseURLString)!
        var queryItems = [URLQueryItem]()
        var baseParams: [String: String] = [:]
        switch type {
        case .metar:
            baseParams = [
                "dataSource"    : "metars",
                "requestType"   : "retrieve",
                "format"        : "xml",
                "hoursBeforeNow": "2",
                "stationString" : icao
            ]
        case .taf:
            let times = getTafStartAndEndTimes(timeIntervalHrs: 8)
            baseParams = [
                "dataSource"    : "tafs",
                "requestType"   : "retrieve",
                "format"        : "xml",
                "startTime"     : "\(times.start)", //seconds since jan 1, 1970
                "endTime"       : "\(times.end)",
                "stationString" : icao
            ]
        }
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        components.queryItems = queryItems
        return components.url!
    }
}
