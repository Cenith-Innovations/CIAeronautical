// ********************** MetarField *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** MetarField *********************************


import Foundation

///Decoder for METAR raw string downloads
public enum MetarField: String, CaseIterable {
    case metarMain = "METAR"
    case rawText = "raw_text"
    case stationId = "station_id"
    case observationTime = "observation_time"
    case latitude = "latitude"
    case longitude = "longitude"
    case tempC = "temp_c"
    case dewPointC = "dewpoint_c"
    case windDirDegrees = "wind_dir_degrees"
    case windSpeedKts = "wind_speed_kt"
    case windGustKts = "wind_gust_kt"
    case visibilityStatuteMiles = "visibility_statute_mi"
    case altimeterInHg = "altim_in_hg"
    case seaLevelPressureMb = "sea_level_pressure_mb"
    case qualityControlFlags = "quality_control_flags"
    case wxString = "wx_string"
    case skyCondition = "sky_condition"
    case flightCategory = "flight_category"
    case threeHrPressureTendencyMb = "three_hr_pressure_tendency_mb"
    case maxTempPastSixHoursC = "maxT_c"
    case minTempPastSixHoursC = "minT_c"
    case maxTemp24HrC = "maxT24hr_c"
    case minTemp24HrC = "minT24hr_c"
    case precipIn = "precip_in"
    case precipLast3HoursIn = "pcp3hr_in"
    case precipLast6HoursIn = "pcp6hr_in"
    case precipLast24HoursIn = "pcp24hr_in"
    case snowIn = "snow_in"
    case vertVisFt = "vert_vis_ft"
    case metarType = "metar_type"
    case elevationM = "elevation_m"
}

