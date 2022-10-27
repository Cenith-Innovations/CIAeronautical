//
//  WX.swift
//  
//
//  Created by Jorge Alvarez on 10/26/22.
//

import SwiftUI

public struct WX {
    
    // TODO: move this to Color+Extension?
    public static let colors: [WX.FlightCategory: Color] = [.none: Color.gray,
                                                       .vfr: Color.green,
                                                       .mvfr: Color.blue,
                                                       .ifr: Color.red,
                                                       .lifr: Color(UIColor.magenta)]
    
    // TODO: add all the other wx
    public static let wxDict = ["VA": "Volcanic Ash",
                                "FC": "Funnel Cloud(s)",
                                "SS": "Sandstorm",]
    
    public enum FlightCategory: String {
        case vfr = "VFR"
        case mvfr = "MVFR"
        case ifr = "IFR"
        case lifr = "LIFR"
        case none = "NA"
    }
    
    public enum SkyCover: String {
        /// No clouds detected below 12,000 feet
        case clear = "CLR"
        case skyClear = "SKC"
        case few = "FEW"
        case scattered = "SCT"
        /// Broken and Overcast can be ceilings
        case broken = "BKN"
        /// Broken and Overcast can be ceilings
        case overcast = "OVC"
    }

    public static func lowestCeiling(clouds: [SkyCondition]?) -> SkyCondition? {
        
        // Clouds unavailable, can't calculate flight category
        guard let clouds = clouds else { return nil }
        
        let ceilings = clouds.filter { $0.skyCover == SkyCover.broken.rawValue || $0.skyCover == SkyCover.overcast.rawValue }
        
        // No ceilings
        if ceilings.isEmpty { return nil }
        
        var lowest: SkyCondition? = ceilings.first
        
        for ceiling in ceilings {
            guard let ceilingCloudBase = ceiling.cloudBaseFtAgl, let lowestCloudBase = lowest?.cloudBaseFtAgl else { continue }
            if ceilingCloudBase <= lowestCloudBase { lowest = ceiling }
        }
        
        return lowest
    }
    
    public static func visFlightCategory(vis: Double?) -> FlightCategory {
        guard let vis = vis else { return .none }
        
        if vis < 1 { return .lifr }
        
        if vis >= 1 && vis < 3 { return .ifr }
        
        if vis >= 3 && vis <= 5 { return .mvfr }
        
        if vis > 5 { return .vfr }
        
        return .none
    }
        
    public static func cloudsFlightCategory(clouds: [SkyCondition]?) -> FlightCategory {
        guard let clouds = clouds else { return .none }
        
        let lowest = lowestCeiling(clouds: clouds)
        
        guard let ceiling = lowest?.cloudBaseFtAgl else { return .vfr }
        
        print("lowest ceiling: \(ceiling)")
        
        if ceiling < 500 { return .lifr }
        
        if ceiling >= 500 && ceiling < 1000 { return .ifr }
        
        if ceiling >= 1000 && ceiling <= 3000 { return .mvfr }
        
        if ceiling > 3000 { return .vfr }
        
        return .none
    }
    
    static func calculatedFlightCategory(vis: Double?, clouds: [SkyCondition]?) -> (flightCategory: FlightCategory,
                                                                                    visCategory: FlightCategory,
                                                                                    cloudCategory: FlightCategory) {
        
        guard let vis = vis, let clouds = clouds else { return (.none, .none, .none) }
        
        let visRule = visFlightCategory(vis: vis)
        let cloudRule = cloudsFlightCategory(clouds: clouds)
        
        // LIFR
        if visRule == .lifr || cloudRule == .lifr { return (.lifr, visRule, cloudRule) }
        
        // IFR
        if visRule == .ifr || cloudRule == .ifr { return (.ifr, visRule, cloudRule) }
        
        // MVFR
        if visRule == .mvfr || cloudRule == .mvfr { return (.mvfr, visRule, cloudRule) }
        
        // VFR
        if visRule == .vfr && cloudRule == .vfr { return (.vfr, visRule, cloudRule) }
        
        // NA
        return (.none, .none, .none)
    }
}
