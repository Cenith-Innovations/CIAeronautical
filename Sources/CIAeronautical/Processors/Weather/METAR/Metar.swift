// ********************** Metar *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Metar *********************************


import Foundation

/// METAR... Meteorological conditions
public struct Metar: Loopable {
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
    public var skyCondition: String?
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
