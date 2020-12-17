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
    
    public init() { }
    
    @Published public var store = Metar()
    
    private let session: URLSession = { URLSession(configuration: .default) }()
    
    /// Downloads the current METAR for the Airfield
    /// - Parameter icao: ICAO
    public func getMetarFor(icao: String) {
        let url = AddsWeatherAPI().weatherURL(type: .metar, icao: "\(icao)")
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request) { (data, response, error) -> Void in
            if let XMLData = data {
                let currentMetars = MetarParser(data: XMLData).metars
                if currentMetars.count > 0 {
                    DispatchQueue.main.async {
                        self.store = currentMetars[0]
                    }
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
