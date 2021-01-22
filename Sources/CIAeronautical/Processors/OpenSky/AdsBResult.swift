// ********************** AdsBResult *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 1/22/21, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AdsBResult *********************************


import Foundation
import CoreLocation

/**
 Model of what gets returned from OpenSky.
 Full description see - [OpenSky REST API](https://opensky-network.org/apidoc/rest.html)
 */
public struct AdsBResult: Codable {

    
    /// Unique ICAO 24-bit address of the transponder in hex string representation.
    public var icao24 : String?
    
    /// Callsign of the vehicle (8 chars). Can be null if no callsign has been received.
    public var callSign : String?
    
    /// Country name inferred from the ICAO 24-bit address.
    public var originCountry : String?
    
    /// Unix timestamp (seconds) for the last position update. Can be null if no position report was received by OpenSky within the past 15s.
    public var timePosition : Int?
    
    /// Unix timestamp (seconds) for the last update in general. This field is updated for any new, valid message received from the transponder.
    public var lastContact : Int?
    
    /// WGS-84 longitude in decimal degrees. Can be null.
    public var longitude : Float?
    
    /// WGS-84 latitude in decimal degrees. Can be null.
    public var latitude : Float?
    
    /// Barometric altitude in meters. Can be null.
    public var baroAltitude : Float?
    
    /// Boolean value which indicates if the position was retrieved from a surface position report.
    public var onGround : Bool?
    
    /// Velocity over ground in m/s. Can be null.
    public var velocity : Float?
    
    /// True track in decimal degrees clockwise from north (north=0°). Can be null.
    public var trueTrack : Float?
    
    /// Vertical rate in m/s. A positive value indicates that the airplane is climbing, a negative value indicates that it descends. Can be null.
    public var verticalRate : Float?
    
    /// IDs of the receivers which contributed to this state vector. Is null if no filtering for sensor was used in the request.
    public var sensors : String? //TODO: This needs to be fixed I think.
    
    /// Geometric altitude in meters. Can be null.
    public var geoAltitude : Float?
    
    /// The transponder code aka Squawk. Can be null.
    public var squawk : String?
    
    /// Whether flight status indicates special purpose indicator.
    public var spi : Bool?
    
    /// Origin of this state’s position: 0 = ADS-B, 1 = ASTERIX, 2 = MLAT
    public var positionSource : Int?
    
}

