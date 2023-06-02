// ********************** AhasWebAPI *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AhasWebAPI *********************************


import Foundation

public struct AhasWebAPI {
    
    static func AhasURL(area: String, year: String, month: String, day: String, hour: String, parameters: [String: String]? = nil, hr12Risk: Bool = false) -> URL {
        
        var hr12RiskURLString = "http://usahas.com/webservices/Fluffy_AHAS_\(year).asmx/GetAHASRisk\(year)_12?"
        var currentRiskURLString = "http://usahas.com/webservices/Fluffy_AHAS_\(year).asmx/GetAHASRisk\(year)?"
        
        var components = URLComponents(string: hr12Risk ? hr12RiskURLString : currentRiskURLString)!
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "Type": "ICAO",
            "Area" : "\"\(area)\"",
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

