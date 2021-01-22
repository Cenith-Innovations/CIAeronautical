// ********************** OpenSky+Enums *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 1/22/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** OpenSky+Enums *********************************


import Foundation
import CoreLocation

/// Predefined regions to search by, with the ability to enter your own defined area.
public enum SearchArea {
    /// - min: CLLocation of the point that defines the lower left corner of the region.
    /// - max: CLLocation of the point that defines the upper right corner of the region.
    case userEntered(userArea: (min: CLLocation, max: CLLocation))
    case unitedStates
    case westernRegion
    case midRegion
    case easternRegion
}

/// Decide what you'd like to search by.
public enum SearchType {
    case aircraft(icao24: String)
    
    /// Predefined regions to search by, with the ability to enter your own defined area.
    case region(area: SearchArea)
    
    /// Search areas defined by a min corner to max corner value.
    /// - Parameter area: SearchArea
    /// - Returns: A set of coordinates used to search OpenSky for aircraft.
    public static func getCoordSetFor(area: SearchArea) -> (min: CLLocation, max: CLLocation) {
        switch area {
        case .unitedStates:
            return (min: CLLocation(latitude: 21, longitude: -127), max: CLLocation(latitude: 48, longitude: -50))
        case .westernRegion:
            return (min: CLLocation(latitude: 30, longitude: -127), max: CLLocation(latitude: 49, longitude: -103))
        case .midRegion:
            return (min: CLLocation(latitude: 26, longitude: -103), max: CLLocation(latitude: 49, longitude: -84))
        case .easternRegion:
            return (min: CLLocation(latitude: 24, longitude: -84), max: CLLocation(latitude: 49, longitude: -62))
        case .userEntered(let userArea):
            return (min: userArea.min, max: userArea.max)
        }
    }
    
}

