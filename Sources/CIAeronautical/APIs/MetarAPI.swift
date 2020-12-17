// ********************** MetarAPI *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** MetarAPI *********************************


import Foundation
import Combine

/// MetarDownLoader downloads the current metar from ADDS
@available(iOS 13.0, *)
@available(OSX 10.15, *)
public class MetarAPI: ObservableObject {
    
    /// A shared instance of the MetarAPI, used to link the @Published metarStore so your user-interface will automatically update when this updates with a new METAR.
    public static var shared = MetarAPI()
    
    /// New School way of getting the METAR
    @Published public var store = Metar()
    
    private static let session: URLSession = { URLSession(configuration: .default) }()
    
    /// Downloads the current METAR for the Airfield
    /// - Parameter icao: ICAO
    public static func getMetarFor(icao: String) {
        let url = AddsWeatherAPI().weatherURL(type: .metar, icao: "\(icao)")
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request) { (data, response, error) -> Void in
            if let XMLData = data {
                let currentMetars = MetarParser(data: XMLData).metars
                if currentMetars.count > 0 {
                    MetarAPI.shared.store = currentMetars[0]
                }
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }
        }
        task.resume()
    }
}
