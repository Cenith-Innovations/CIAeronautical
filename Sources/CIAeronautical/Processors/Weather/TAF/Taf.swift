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
    public init(id: UUID = UUID(), rawText: String? = nil, stationId: String? = nil, issueTime: Date? = nil, bulletinTime: Date? = nil, validTimeFrom: Date? = nil, validTimeTo: Date? = nil, remarks: String? = nil, latitude: Double? = nil, longitude: Double? = nil, elevationM: Double? = nil, forecast: [Forecast]? = nil, temperature: Double? = nil, validTime: Date? = nil, surfaceTempC: Double? = nil, maxTempC: Double? = nil, minTempC: Double? = nil) {
        self.id = id
        self.rawText = rawText
        self.stationId = stationId
        self.issueTime = issueTime
        self.bulletinTime = bulletinTime
        self.validTimeFrom = validTimeFrom
        self.validTimeTo = validTimeTo
        self.remarks = remarks
        self.latitude = latitude
        self.longitude = longitude
        self.elevationM = elevationM
        self.forecast = forecast
        self.temperature = temperature
        self.validTime = validTime
        self.surfaceTempC = surfaceTempC
        self.maxTempC = maxTempC
        self.minTempC = minTempC
    }
    
    public static let dummyTAF = Taf(id: UUID(), rawText: "TAF AMD KBAB 251540Z 2515/2617 33009KT 9999 FEW080 QNH2979INS BECMG 2523/2524 23009KT 9999 SCT045 QNH2973INS BECMG 2604/2605 15009KT 9999 SKC QNH2979INS TX18/2523Z TN06/2515Z", stationId: "KBAB", issueTime: Date(), bulletinTime: Date(), validTimeFrom: Date(), validTimeTo: Date(), remarks: nil, latitude: 39.13, longitude: -121.43, elevationM: 31.0, forecast: [Forecast.dummyForcast, Forecast.dummyForcast], temperature: 10.0, validTime: Date(), surfaceTempC: 12.0, maxTempC: 32.0, minTempC: 12.0)

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

public struct Forecast: Identifiable   {
    
    public static var dummyForcast = Forecast(forecastTimeFrom: Date(), forecastTimeTo: Date(), changeIndicator: nil, timeBecoming: Date(), probability: 0, windDirDegrees: 230, windSpeedKts: 21, windGustKts: 10, windShearHeightFtAGL: 4000, windShearDirDegrees: 230, windShearSpeedKts: 10, visibilityStatuteMiles: 10, altimeterInHg: 30.01, verticleVisFt: 10, wxString: "", notDecoded: "", skyConditions: [SkyCondition.dummySkyCondition, SkyCondition.dummySkyCondition], turbulenceCondition: [TurbulanceCondition.dummyTurbulanceCon, TurbulanceCondition.dummyTurbulanceCon], icingConditions: [IcingCondition.dummyIcingCon, IcingCondition.dummyIcingCon])
    
    public init(forecastTimeFrom: Date? = nil, forecastTimeTo: Date? = nil, changeIndicator: String? = nil, timeBecoming: Date? = nil, probability: Int? = nil, windDirDegrees: Double? = nil, windSpeedKts: Double? = nil, windGustKts: Double? = nil, windShearHeightFtAGL: Int? = nil, windShearDirDegrees: Double? = nil, windShearSpeedKts: Double? = nil, visibilityStatuteMiles: Double? = nil, altimeterInHg: Double? = nil, verticleVisFt: Double? = nil, wxString: String? = nil, notDecoded: String? = nil, skyConditions: [SkyCondition]? = nil, turbulenceCondition: [TurbulanceCondition]? = nil, icingConditions: [IcingCondition]? = nil) {
        self.forecastTimeFrom = forecastTimeFrom
        self.forecastTimeTo = forecastTimeTo
        self.changeIndicator = changeIndicator
        self.timeBecoming = timeBecoming
        self.probability = probability
        self.windDirDegrees = windDirDegrees
        self.windSpeedKts = windSpeedKts
        self.windGustKts = windGustKts
        self.windShearHeightFtAGL = windShearHeightFtAGL
        self.windShearDirDegrees = windShearDirDegrees
        self.windShearSpeedKts = windShearSpeedKts
        self.visibilityStatuteMiles = visibilityStatuteMiles
        self.altimeterInHg = altimeterInHg
        self.verticleVisFt = verticleVisFt
        self.wxString = wxString
        self.notDecoded = notDecoded
        self.skyConditions = skyConditions
        self.turbulenceCondition = turbulenceCondition
        self.icingConditions = icingConditions
    }
    
    public let id = UUID()
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
    
    public static let dummySkyCondition = SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 2000, cloudType: nil)
    
    public init(skyCover: String? = nil, cloudBaseFtAgl: Double? = nil, cloudType: String? = nil) {
        self.skyCover = skyCover
        self.cloudBaseFtAgl = cloudBaseFtAgl
        self.cloudType = cloudType
    }
    
    public var skyCover: String?
    public var cloudBaseFtAgl: Double?
    public var cloudType: String?
}

public struct TurbulanceCondition: Equatable {
    
    public static let dummyTurbulanceCon = TurbulanceCondition(intensity: "", minAltFtAgl: 5000, maxAltFtAgl: 25000)
    
    public init(intensity: String? = nil, minAltFtAgl: Double? = nil, maxAltFtAgl: Double? = nil) {
        self.intensity = intensity
        self.minAltFtAgl = minAltFtAgl
        self.maxAltFtAgl = maxAltFtAgl
    }
    
    public var intensity: String?
    public var minAltFtAgl: Double?
    public var maxAltFtAgl: Double?
}

public struct IcingCondition {
    
    public static let dummyIcingCon = IcingCondition(intensity: "Mod", minAltFtAgl: 3000, maxAltFtAgl: 15000)
    
    public init(intensity: String? = nil, minAltFtAgl: Double? = nil, maxAltFtAgl: Double? = nil) {
        self.intensity = intensity
        self.minAltFtAgl = minAltFtAgl
        self.maxAltFtAgl = maxAltFtAgl
    }
    
    public var intensity: String?
    public var minAltFtAgl: Double?
    public var maxAltFtAgl: Double?
}




