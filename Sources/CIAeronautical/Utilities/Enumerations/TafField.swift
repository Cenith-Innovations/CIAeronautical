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
    case temperature = "temperature"
    case validTime = "valid_time"
    case surfcaeTempC = "sfc_temp_c"
    case maxTempC = "max_temp_c"
    case minTempC = "min_temp_c"
}
