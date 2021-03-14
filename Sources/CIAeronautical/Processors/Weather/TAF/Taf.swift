// ********************** Taf *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Taf *********************************


import Foundation

/// TAF: Terminal Area Forcast
public struct Taf: Identifiable, Loopable {
    public var id = UUID()
    public var rawText: String?
    public var stationId: String?
    public var issueTime: String?
    public var bulletinTime: String?
    public var validTimeFrom: String?
    public var validTimeTo: String?
    public var remarks: String?
    public var latitude: String?
    public var longitude: String?
    public var elevationM: String?
    public var forecast: String?
    public var timeFrom: String?
    public var timeTo: String?
    public var changeIndicator: String?
    public var timeBecoming: String?
    public var probability: String?
    public var windDirDegrees: String?
    public var windSpeedKts: String?
    public var windGustKts: String?
    public var windShearHeightAboveGroundFt: String?
    public var windShearDirDegrees: String?
    public var windShearSpeedKts: String?
    public var visibilityStatuteMiles: String?
    public var altimeterInHg: String?
    public var vertVisFt: String?
    public var weatherString: String?
    public var notDecoded: String?
    public var skyCondition: [SkyCondition?]?
    public var turbulenceCondition: String?
    public var icingCondition: [IcingCondition?]?
    public var temperature: String?
    public var validTime: String?
    public var surfaceTempC: String?
    public var maxTempC: String?
    public var minTempC: String?
}


public struct SkyCondition: Equatable {
    public var skyCover: String?
    public var cloudBaseFtAgl: String?
}

public struct IcingCondition {
    
    public var icingIntensity: String?
    public var icingMinAltFtAgl: String?
    public var icingMaxAltFtAgl: String?
}
