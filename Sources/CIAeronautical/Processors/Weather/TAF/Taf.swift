// ********************** Taf *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Taf *********************************


import Foundation
import CIFoundation

/// TAF: Terminal Area Forcast
public struct Taf: Identifiable, Loopable, Hashable {
    public var id = UUID()
    public var rawText: String?
    public var stationId: String?
    public var issueTime: Date?
    public var bulletinTime: Date?
    public var validTimeFrom: Date?
    public var validTimeTo: Date?
    public var remarks: String?
    public var latitude: Double?
    public var longitude: Double?
    public var elevationM: Double?
    public var forecast: [Forecast]?
    public var temperature: Double?
    public var validTime: Date?
    public var surfaceTempC: Double?
    public var maxTempC: Double?
    public var minTempC: Double?
}

public struct Forecast: Hashable   {
    public var forecastTimeFrom: Date?
    public var forecastTimeTo: Date?
    public var changeIndicator: String?
    public var timeBecoming: Date?
    public var probability: Int?
    public var windDirDegrees: Double?
    public var windSpeedKts: Double?
    public var windGustKts: Double?
    public var windShearHeightFtAGL: Int?
    public var windShearDirDegrees: Double?
    public var windShearSpeedKts: Double?
    public var visibilityStatuteMiles: Double?
    public var altimeterInHg: Double?
    public var verticleVisFt: Double?
    public var wxString: String?
    public var notDecoded: String?
    public var skyConditions: [SkyCondition]?
    public var turbulenceCondition: [TurbulanceCondition]?
    public var icingConditions: [IcingCondition]?
    
    /// TAF.rawText is broken up and each part is assigned to its respective Forecast based on index order
    public var rawText: String?
    
    public static let changeIndicatorsDict = ["TEMPO": "Temporary", "BECMG": "Gradual"]
    
    public static var DummySkyConditions: [SkyCondition] = [
        SkyCondition(skyCover: "FEW", cloudBaseFtAgl: 6000),
        SkyCondition(skyCover: "OVC", cloudBaseFtAgl: 7000)
    ]
    
    public static let dummyForecast = Forecast(forecastTimeFrom: Date(), forecastTimeTo: Date(), changeIndicator: "TEMPO", timeBecoming: Date(), probability: 40, windDirDegrees: 170, windSpeedKts: 10, windGustKts: 15, windShearHeightFtAGL: nil, windShearDirDegrees: nil, windShearSpeedKts: nil, visibilityStatuteMiles: 5, altimeterInHg: 30, verticleVisFt: 100, wxString: "-RA", notDecoded: nil, skyConditions: Forecast.DummySkyConditions, turbulenceCondition: [], icingConditions: [], rawText: "BECMG 1216/1217 32009KT 9999 FEW040 QNH2993INS WND VRB06KT AFT 1302 TX10/1222Z TN01/1311Z")
    
    public static let dummyTAF = Taf(id: UUID(), rawText: "", stationId: "KBAB", issueTime: Date(), bulletinTime: Date(), validTimeFrom: Date(), validTimeTo: Date(), remarks: "", latitude: 30.0, longitude: 120.0, elevationM: 20.0, forecast: [Forecast.dummyForecast, Forecast.dummyForecast], temperature: 30.6, validTime: Date(), surfaceTempC: 50.2, maxTempC: 55.2, minTempC: 54.1)
}

public struct SkyCondition: Equatable, Hashable {
    public var skyCover: String?
    public var cloudBaseFtAgl: Double?
    public var cloudType: String?
}

public struct TurbulanceCondition: Equatable, Hashable {
    public var intensity: String?
    public var minAltFtAgl: Double?
    public var maxAltFtAgl: Double?
}

public struct IcingCondition: Hashable {
    public var intensity: String?
    public var minAltFtAgl: Double?
    public var maxAltFtAgl: Double?
}
