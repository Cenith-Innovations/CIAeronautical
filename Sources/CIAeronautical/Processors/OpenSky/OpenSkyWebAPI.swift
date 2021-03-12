// ********************** OpenSkyWebAPI *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 1/22/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** OpenSkyWebAPI *********************************


import Foundation
import Combine
import CoreLocation

/// The interface used to search URL for OpenSky. Full description see - [OpenSky REST API](https://opensky-network.org/apidoc/rest.html)
@available(tvOS 13.0, *)
public class OpenSkyWebAPI: ObservableObject {
    
    /// The base url to add query components.
    private static let baseUrl = "https://opensky-network.org/api/states/all"
    
    /// Generates the URL to query the Open Sky web service.
    /// - Parameters:
    ///   - type: This lets you pick a region to search by or an aircraft transponder address. If left blank, this will give you a url to get ALL of the data.
    ///   - time: The time in seconds since epoch (Unix time stamp to retrieve states.) Current time will be used if omitted.
    ///   - icao24: One or more ICAO24 transponder addresses represented by a hex string (e.g. abc9f3). To filter multiple ICAO24 append the property once for each address. If omitted, the state vectors of all aircraft are returned.
    /// - Returns: The Open Sky Url.
    public static func url(type: SearchType, time: Int?) -> URL {
        var components = URLComponents(string: OpenSkyWebAPI.baseUrl)!
        var queryItems: [URLQueryItem] = []
        var baseParams: [String: String] = [:]
        
        switch type {
        case .aircraft(let icao24):
            baseParams["icao24"] = "\(icao24)"
            if let time = time { baseParams["time"] = String(describing: time) }
        case .region(let area):
            let coordsMin = SearchType.getCoordSetFor(area: area).min
            let lamin = String(describing: coordsMin.coordinate.latitude)
            let lomin = String(describing: coordsMin.coordinate.longitude)
            let coordsMax = SearchType.getCoordSetFor(area: area).max
            let lamax = String(describing: coordsMax.coordinate.latitude)
            let lomax = String(describing: coordsMax.coordinate.longitude)
            baseParams = [
                "lamin" : "\(lamin)",
                "lomin" : "\(lomin)",
                "lamax" : "\(lamax)",
                "lomax" : "\(lomax)",
            ]
        }
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        components.queryItems = queryItems
        print(components.url!)
        return components.url!
    }
}

