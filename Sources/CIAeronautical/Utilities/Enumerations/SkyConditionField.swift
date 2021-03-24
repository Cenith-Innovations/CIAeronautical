//
//  SkyConditionField.swift
//  
//
//  Created by Caleb Wells on 3/17/21.
//

import Foundation

public enum SkyConditionField: String, CaseIterable {
    case skyCondition = "sky_condition"
    case skyCover = "sky_cover" //SKC|CLR|CAVOK|FEW|SCT|BKN|OVC|OVX
    case cloudBaseFtAGL = "cloud_base_ft_agl" //Only exists for - 'FEW','SCT','BKN', 'OVC'
    case cloudType = "cloud_type"
}
