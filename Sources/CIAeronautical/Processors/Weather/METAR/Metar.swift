// ********************** Metar *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Metar *********************************


import Foundation

/// METAR... Meteorological conditions
public struct Metar: Hashable ,Loopable {
    public  init(id: UUID = UUID(), rawText: String? = nil, stationId: String? = nil, observationTime: Date? = nil, latitude: Double? = nil, longitude: Double? = nil, tempC: Double? = nil, dewPointC: Double? = nil, windDirDegrees: Double? = nil, windSpeedKts: Double? = nil, windGustKts: Double? = nil, visibilityStatuteMiles: Double? = nil, altimeterInHg: Double? = nil, seaLevelPressureMb: Double? = nil, qualityControlFlags: String? = nil, wxString: String? = nil, skyCondition: [SkyCondition] = [], flightCategory: String? = nil, threeHrPressureTendencyMb: String? = nil, maxTempPastSixHoursC: Double? = nil, minTempPastSixHoursC: Double? = nil, maxTemp24HrC: Double? = nil, minTemp24HrC: Double? = nil, precipIn: Double? = nil, precipLast3HoursIn: Double? = nil, precipLast6HoursIn: Double? = nil, precipLast24HoursIn: Double? = nil, snowIn: Double? = nil, vertVisFt: Double? = nil, metarType: String? = nil, elevationM: Double? = nil) {
        self.id = id
        self.rawText = rawText
        self.stationId = stationId
        self.observationTime = observationTime
        self.latitude = latitude
        self.longitude = longitude
        self.tempC = tempC
        self.dewPointC = dewPointC
        self.windDirDegrees = windDirDegrees
        self.windSpeedKts = windSpeedKts
        self.windGustKts = windGustKts
        self.visibilityStatuteMiles = visibilityStatuteMiles
        self.altimeterInHg = altimeterInHg
        self.seaLevelPressureMb = seaLevelPressureMb
        self.qualityControlFlags = qualityControlFlags
        self.wxString = wxString
        self.skyCondition = skyCondition
        self.flightCategory = flightCategory
        self.threeHrPressureTendencyMb = threeHrPressureTendencyMb
        self.maxTempPastSixHoursC = maxTempPastSixHoursC
        self.minTempPastSixHoursC = minTempPastSixHoursC
        self.maxTemp24HrC = maxTemp24HrC
        self.minTemp24HrC = minTemp24HrC
        self.precipIn = precipIn
        self.precipLast3HoursIn = precipLast3HoursIn
        self.precipLast6HoursIn = precipLast6HoursIn
        self.precipLast24HoursIn = precipLast24HoursIn
        self.snowIn = snowIn
        self.vertVisFt = vertVisFt
        self.metarType = metarType
        self.elevationM = elevationM
    }
    
    
    public static var DummySkyConditions: [SkyCondition] = [
        SkyCondition(skyCover: "OVC", cloudBaseFtAgl: 500),
        SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 700)
    ]
    
    public static var DummyMETAR = Metar(rawText: "KBAB 130158Z AUTO 33009KT 10SM CLR 17/M01 A3008 RMK AO2 SLP189 T01661006 $", stationId: "KBAB", observationTime: Date(), latitude: 45.0, longitude: -121.0, tempC: 10.3, dewPointC: 2.2, windDirDegrees: 35, windSpeedKts: 10, windGustKts: 10, visibilityStatuteMiles: 10, altimeterInHg: 30.01, seaLevelPressureMb: 0, qualityControlFlags: "\n        TRUE\n        TRUE\n        TRUE\n      ", wxString: nil, skyCondition: Metar.DummySkyConditions, flightCategory: "VFR", threeHrPressureTendencyMb: nil, maxTempPastSixHoursC: 0, minTempPastSixHoursC: 0, maxTemp24HrC: 0, minTemp24HrC: 0, precipIn: 0, precipLast3HoursIn: 0, precipLast6HoursIn: 0, precipLast24HoursIn: 0, snowIn: 0, vertVisFt: 0, metarType: nil, elevationM: 0)

    public func hash(into hasher: inout Hasher) {
        hasher.combine(stationId)
    }
    
    public var id = UUID()
    public var rawText: String?
    public var stationId: String?
    public var observationTime: Date?
    public var latitude: Double?
    public var longitude: Double?
    public var tempC: Double?
    public var dewPointC: Double?
    public var windDirDegrees: Double?
    public var windSpeedKts: Double?
    public var windGustKts: Double?
    public var visibilityStatuteMiles: Double?
    public var altimeterInHg: Double?
    public var seaLevelPressureMb: Double?
    public var qualityControlFlags: String?
    public var wxString: String?
    public var skyCondition: [SkyCondition]
    public var flightCategory: String?
    public var threeHrPressureTendencyMb: String?
    public var maxTempPastSixHoursC: Double?
    public var minTempPastSixHoursC: Double?
    public var maxTemp24HrC: Double?
    public var minTemp24HrC: Double?
    public var precipIn: Double?
    public var precipLast3HoursIn: Double?
    public var precipLast6HoursIn: Double?
    public var precipLast24HoursIn: Double?
    public var snowIn: Double?
    public var vertVisFt: Double?
    public var metarType: String?
    public var elevationM: Double?
    
}
