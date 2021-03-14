// ********************** Metar *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Metar *********************************


import Foundation

/// METAR... Meteorological conditions
public struct Metar: Hashable ,Loopable {
//
//
//    public static func == (lhs: Metar, rhs: Metar) -> Bool {
//
//        let df = DateFormatter()
//        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
//        let lhsDate = df.date(from: lhs.observationTime!)!
//        let rhsDate = df.date(from: lhs.observationTime!)!
//        print("************* DATES ******************")
//        print(lhsDate)
//        print(rhsDate)
//        print("************************************")
//        return lhsDate > rhsDate
//    }
//
//    public init(rawText: String? = nil, stationId: String? = nil, observationTime: String? = nil, latitude: String? = nil, longitude: String? = nil, tempC: String? = nil, dewPointC: String? = nil, windDirDegrees: String? = nil, windSpeedKts: String? = nil, windGustKts: String? = nil, visibilityStatuteMiles: String? = nil, altimeterInHg: String? = nil, seaLevelPressureMb: String? = nil, qualityControlFlags: String? = nil, wxString: String? = nil, skyCondition: [SkyCondition?]? = nil, flightCategory: String? = nil, threeHrPressureTendencyMb: String? = nil, maxTempPastSixHoursC: String? = nil, minTempPastSixHoursC: String? = nil, maxTemp24HrC: String? = nil, minTemp24HrC: String? = nil, precipIn: String? = nil, precipLast3HoursIn: String? = nil, precipLast6HoursIn: String? = nil, precipLast24HoursIn: String? = nil, snowIn: String? = nil, vertVisFt: String? = nil, metarType: String? = nil, elevationM: String? = nil) {
//        self.rawText = rawText
//        self.stationId = stationId
//        self.observationTime = observationTime
//        self.latitude = latitude
//        self.longitude = longitude
//        self.tempC = tempC
//        self.dewPointC = dewPointC
//        self.windDirDegrees = windDirDegrees
//        self.windSpeedKts = windSpeedKts
//        self.windGustKts = windGustKts
//        self.visibilityStatuteMiles = visibilityStatuteMiles
//        self.altimeterInHg = altimeterInHg
//        self.seaLevelPressureMb = seaLevelPressureMb
//        self.qualityControlFlags = qualityControlFlags
//        self.wxString = wxString
//        self.skyCondition = skyCondition
//        self.flightCategory = flightCategory
//        self.threeHrPressureTendencyMb = threeHrPressureTendencyMb
//        self.maxTempPastSixHoursC = maxTempPastSixHoursC
//        self.minTempPastSixHoursC = minTempPastSixHoursC
//        self.maxTemp24HrC = maxTemp24HrC
//        self.minTemp24HrC = minTemp24HrC
//        self.precipIn = precipIn
//        self.precipLast3HoursIn = precipLast3HoursIn
//        self.precipLast6HoursIn = precipLast6HoursIn
//        self.precipLast24HoursIn = precipLast24HoursIn
//        self.snowIn = snowIn
//        self.vertVisFt = vertVisFt
//        self.metarType = metarType
//        self.elevationM = elevationM
//    }
//
    public func hash(into hasher: inout Hasher) {
        hasher.combine(stationId)
    }
    public var id = UUID()
    public var rawText: String?
    public var stationId: String?
    public var observationTime: String?
    public var latitude: String?
    public var longitude: String?
    public var tempC: String?
    public var dewPointC: String?
    public var windDirDegrees: String?
    public var windSpeedKts: String?
    public var windGustKts: String?
    public var visibilityStatuteMiles: String?
    public var altimeterInHg: String?
    public var seaLevelPressureMb: String?
    public var qualityControlFlags: String?
    public var wxString: String?
    public var skyCondition: [SkyCondition?]?
    public var flightCategory: String?
    public var threeHrPressureTendencyMb: String?
    public var maxTempPastSixHoursC: String?
    public var minTempPastSixHoursC: String?
    public var maxTemp24HrC: String?
    public var minTemp24HrC: String?
    public var precipIn: String?
    public var precipLast3HoursIn: String?
    public var precipLast6HoursIn: String?
    public var precipLast24HoursIn: String?
    public var snowIn: String?
    public var vertVisFt: String?
    public var metarType: String?
    public var elevationM: String?
}
