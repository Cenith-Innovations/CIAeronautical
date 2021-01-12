// ********************** File *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 12/24/20, for CIAeronautical
// * Elmo <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Approach *********************************


import Foundation

public enum ApproachCategory {
    case a, b, c, d, e
}

public enum ApproachType {
    case precision, nonPrecision
}

public protocol Weather {
    
    /// Thousands of Feet
    var ceiling: Double { get set }
    
    /// Statute Miles
    var visibility: Double { get set }
}

public protocol AirfieldSystemStatus {
    var rvrOutOfService: Bool { get set }
}

public protocol Approach {
    var minimums: [ApproachCategory : Weather] { get set }
    var type: ApproachType { get set }
    
}

public protocol ApproachFilter {
    /* MARK: 👉 Add the NOTAM Parsing ability to:
     - RVR out of service
     - Runway Closed
     -
     */
    //    func isWeatherGoodEnoughForApproach(weather: Weather, approachCat: ApproachCategory, ApprocahName: ) -> Bool
    var isUsable: Bool { get set }
}

public protocol Aircraft {
    var approachCatCapable: [ApproachCategory] { get set }
    var minRunwayLength: Double? { get set }
    
}

public protocol PilotLimitations {
    var pilotWeatherMinimums: Weather { get set }
}

public struct NotamFilter: ApproachFilter {
    
    public var isUsable: Bool
    
    init(notams: [Notam], approach: Approach, category: ApproachCategory, type: ApproachType) {
        func usableApproach(notam: [Notam]) -> Bool {
            
//            for notam in notams {
//                if notam.closedRunways
//            }
            
            return true
        }
        self.isUsable = usableApproach(notam: notams)
    }
    
}

public struct WeatherFilter: ApproachFilter {
    
    public var isUsable: Bool = false
    
    init(weather: Weather, approach: Approach, category: ApproachCategory, type: ApproachType) {
        
        func usableApproach(actual: Weather, approach: Approach, category: ApproachCategory, type: ApproachType) -> Bool {
            guard let requiredWx = approach.minimums[category] else { return false }
            
            switch type {
            case .precision:
                if actual.visibility < requiredWx.visibility  { return false }
                return true
            case .nonPrecision:
                if actual.visibility < requiredWx.visibility  { return false }
                if actual.ceiling < requiredWx.ceiling { return false }
                return true
            }
        }
        self.isUsable = usableApproach(actual: weather, approach: approach, category: category, type: type)
    }
}


