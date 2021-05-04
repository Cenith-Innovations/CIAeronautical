// ********************** Taf *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Taf *********************************


import Foundation
import CIFoundation

/// TAF: Terminal Area Forcast
public struct Taf: Identifiable, Loopable {
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

public struct Forecast   {
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
}

public struct SkyCondition: Equatable {
    public var skyCover: String?
    public var cloudBaseFtAgl: Double?
    public var cloudType: String?
}

public struct TurbulanceCondition: Equatable {
    public var intensity: String?
    public var minAltFtAgl: Double?
    public var maxAltFtAgl: Double?
}

public struct IcingCondition: Hashable {
    public var intensity: String?
    public var minAltFtAgl: Double?
    public var maxAltFtAgl: Double?
}
