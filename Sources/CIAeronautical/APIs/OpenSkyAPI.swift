// ********************** File *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 1/22/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** File *********************************


import Foundation
import Combine
import CoreLocation

/// Interface to go get all the pretty airplanes. Full description see - [OpenSky REST API](https://opensky-network.org/apidoc/rest.html)
public class OpenSkyAPI: ObservableObject {
    
    /// A shared instance of the OpenSkyAPI, used to link the @Published store so your user-interface will automatically update when this updates with new ADS-B info.
    public static var shared = OpenSkyAPI()
    @Published public var aircraft: [AdsBResult] = []
    
    /// This is where the good-stuff goes. Subscribe to these in your UI.
    public var store = PassthroughSubject<[AdsBResult], Never>()
    public var foreFlightTraffic = PassthroughSubject<[String], Never>()
    
    private let session = URLSession(configuration: .default)
    
    /// This goes out to OpenSky and gets all the ADS-B info for the desired query items.
    /// - Parameters:
    ///   - type: Search type. This can either be an Aircraft or a region. If it's an aircraft, then you have to fill in the icao24 field. If you go with region, there is a set of predefined regions as well as a user defined choice. If you go with a predefined region, leave the regionMin and regionMax fields nil, they take precedence over the predefined regions.
    ///   - time: The time in seconds since epoch (Unix time stamp to retrieve states for. Current time will be used if omitted.
    ///   - icao24: One or more ICAO24 transponder addresses represented by a hex string (e.g. abc9f3). To filter multiple ICAO24 append the property once for each address. If omitted, the state vectors of all aircraft are returned.
    public func getAdsBResults(type: SearchType, time: Int? = nil) {
        let url = OpenSkyWebAPI.url(type: type, time: time)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let adsBResults = data {
                self.loadJSONintoStore(adsBResults)
            } else if let requestError = error {
                print(requestError)
            } else {
                print("Unexpected error with request")
            }
        }
        task.resume()
    }
    
    /// Loads up all the return items into the OpenSkyAPI.shared.store.
    /// - Parameter data: returned data from the OpenSky website.
    private func loadJSONintoStore(_ data: Data) {
        var currentTraffic: [AdsBResult] = []
        var foreFlightFormatTraffic: [String] = []
        do  {
            let json = try JSON(data: data)
            for (_ ,state) in json["states"] {
                let result = AdsBResult(icao24: state[0].string, callSign: state[1].string, originCountry: state[2].string, timePosition: state[3].int, lastContact: state[4].int, longitude: state[5].float, latitude: state[6].float, baroAltitude: state[7].float, onGround: state[8].bool, velocity: state[9].float, trueTrack: state[10].float, verticalRate: state[11].float, sensors: state[12].string, geoAltitude: state[13].float, squawk: state[14].string, spi: state[15].bool, positionSource: state[16].int)
                
                currentTraffic.append(result)
                foreFlightFormatTraffic.append(ForeFlightTraffic(traffic: result).foreFlightTrafficString)
            }
        } catch {
                print("No Soup for YOU!")
        }
        
        DispatchQueue.main.async {
            self.store.send(currentTraffic)
            self.foreFlightTraffic.send(foreFlightFormatTraffic)
            self.aircraft = currentTraffic
        }
    }
}
