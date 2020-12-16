// ********************** AhasWebAPI *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AhasWebAPI *********************************


import Foundation

public struct AhasWebAPI {
    internal static let baseURLString = "http://www.usahas.com/webservices/ahas.asmx/GetAHASRisk?"
    
    static func AhasURL(area: String,
                         month: String,
                         day: String,
                         hour: String,
                         parameters: [String: String]?) -> URL {
        
        
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "area" : "\"\(area)\"",
            "iMonth" : month,
            "iDay" : day,
            "iHour" : hour
        ]
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }}
        components.queryItems = queryItems
        return components.url!
    }
}

