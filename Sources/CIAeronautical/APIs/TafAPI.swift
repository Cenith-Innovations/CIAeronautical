// ********************** TafAPI *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** TafAPI *********************************


import Foundation
import Combine

@available(iOS 13.0, *)
@available(OSX 10.15, *)
/// Classy way to download the TAF
public class TafAPI: ObservableObject {
    
    public init() { }
    
    @Published public var store: [Taf] = []
    
    private let session: URLSession = { URLSession(configuration: .default) }()
    
    /// Gets the current TAFs for the Airfield
    /// - Parameter icao: ICAO
    public func getTafFor(icao: String) {
        let url = AddsWeatherAPI().weatherURL(type: .taf, icao: "\(icao)")
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            if let XMLData = data {
                self.store = TafParser(data: XMLData).tafs
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }
        }
        task.resume()
    }
}
