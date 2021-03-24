//
//  TurbulanceConditionField.swift
//  
//
//  Created by Caleb Wells on 3/17/21.
//

import Foundation

public enum TurbulanceConditionField: String, CaseIterable {
    case turbulenceCondition = "turbulence_condition"
    case intensity = "turbulence_intensity"
    case minAltFtAGL = "turbulence_min_alt_ft_agl"
    case maxAltFtAGL = "turbulence_max_alt_ft_agl"
}
