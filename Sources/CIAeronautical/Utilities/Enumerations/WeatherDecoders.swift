// ********************** WeatherDecoders *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 3/16/21, for 
// * Elmo <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** WeatherDecoders *********************************


import Foundation

/// TAF decoders
public enum TafField: String, CaseIterable {
    
    case tafMain = "TAF"
    case rawText = "raw_text"
    case stationId = "station_id"
    case issueTime = "issue_time"
    case bulletinTime = "bulletin_time"
    case validTimeFrom = "valid_time_from"
    case validTimeTo = "valid_time_to"
    case remarks = "remarks"
    case latitude = "latitude"
    case longitude = "longitude"
    case elevationM = "elevation_m"
    
    case temperature = "temperature"
    case validTime = "valid_time"
    case surfcaeTempC = "sfc_temp_c"
    case maxTempC = "max_temp_c"
    case minTempC = "min_temp_c"
}

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
    case metarType = "metar_type" //"METAR" or "SPECI"
    case elevationM = "elevation_m"
}

public enum ForecastField: String, CaseIterable {
    case forecast = "forecast"
    case forecastTimeFrom = "fcst_time_from"
    case forecastTimeTo = "fcst_time_to"
    case changeIndicator = "change_indicator"
    case timeBecoming = "time_becoming"
    case probability = "probability"
    case windDirDegrees = "wind_dir_degrees"
    case windSpeedKts = "wind_speed_kt"
    case windGustKts = "wind_gust_kt"
    case windShearHeightAboveGroundFt = "wind_shear_hgt_ft_agl"
    case windShearDirDegrees = "wind_shear_dir_degrees"
    case windShearSpeedKts = "wind_shear_speed_kt"
    case visibilityStatuteMiles = "visibility_statute_mi"
    case altimeterInHg = "altim_in_hg"
    case vertVisFt = "vert_vis_ft"
    case weatherString = "wx_string"
    case notDecoded = "not_decoded"
}

public enum SkyConditionField: String, CaseIterable {
    case skyCondition = "sky_condition"
    case skyCover = "sky_cover" //SKC|CLR|CAVOK|FEW|SCT|BKN|OVC|OVX
    case cloudBaseFtAGL = "cloud_base_ft_agl" //Only exists for - 'FEW','SCT','BKN', 'OVC'
    case cloudType = "cloud_type"
}

public enum TurbulanceConditionField: String, CaseIterable {
    case turbulenceCondition = "turbulence_condition"
    case intensity = "turbulence_intensity"
    case minAltFtAGL = "turbulence_min_alt_ft_agl"
    case maxAltFtAGL = "turbulence_max_alt_ft_agl"
}

public enum IcingConditionField: String, CaseIterable {
    case icingCondition = "icing_condition"
    case intensity = "icing_intensity"
    case minAltFtAGL = "icing_min_alt_ft_agl"
    case maxAltFtAGL = "icing_max_alt_ft_agl"
}
