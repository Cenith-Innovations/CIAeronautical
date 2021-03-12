// ********************** TafField *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** TafField *********************************


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
    case forecast = "forecast"
    case timeFrom = "time_from"
    case timeTo = "time_to"
    case changeIndicator = "change_indicator"
    case timeBecoming = "time_becoming"
    case probability = "probability"
    case windDirDegrees = "wind_dir_degrees"
    case windSpeedKts = "wind_speed_kt"
    case windGustKts = "wing_gust_kt"
    case windShearHeightAboveGroundFt = "wind_shear_hgt_ft_agl"
    case windShearDirDegrees = "wind_shear_dir_degrees"
    case windShearSpeedKts = "wind_shear_speed_kt"
    case visibilityStatuteMiles = "visibility_statute_mi"
    case altimeterInHg = "altim_in_hg"
    case vertVisFt = "vert_vis_ft"
    case weatherString = "wx_string"
    case notDecoded = "not_decoded"
    case skyCondition = "sky_condition"
    case turbulenceCondition = "turbulence_condition"
    case icingCondition = "icing_condition"
    case temperature = "temperature"
    case validTime = "valid_time"
    case surfcaeTempC = "sfc_temp_c"
    case maxTempC = "max_temp_c"
    case minTempC = "min_temp_c"
    case skyCover = "sky_cover"
    case cloudBaseFtAGL = "cloud_base_ft_agl"
    case icingIntensity = "icing_intensity"
    case icingMinAltFtAGL = "icing_min_alt_ft_agl"
    case icingMaxAltFtAGL = "icing_max_alt_ft_agl"
}




