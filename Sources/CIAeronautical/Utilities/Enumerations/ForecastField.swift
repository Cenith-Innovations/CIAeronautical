//
//  ForecastField.swift
//  
//
//  Created by Caleb Wells on 3/17/21.
//

import Foundation

public enum ForecastField: String, CaseIterable {
    case forecast = "forecast"
    case forecastTimeFrom = "fcst_time_from"
    case forecastTimeTo = "fcst_time_to"
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
}
