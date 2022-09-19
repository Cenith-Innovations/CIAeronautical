//
//  File.swift
//  
//
//  Created by Jorge Alvarez on 9/19/22.
//

import Foundation

public struct AirDataSource: Decodable {
    public let name: String?
    public let id: Int?
    public let twcCityCode: String?
    public let state: String?
    public let stateCode: String?
    public let dataProviders: [String?]?
    /// Treated as String instead of URL since it can sometimes come back as an empty String
    public let dataProviderURLs: [String?]?
    public let forecastProvider: String?
    /// Treated as String instead of URL since it can sometimes come back as an empty String
    public let forecastProviderURL: String?
}
