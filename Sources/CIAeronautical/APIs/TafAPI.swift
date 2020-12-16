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
    
    /// A shared instance of the TafAPI, used to link the @Published tafStore so your user-interface will automatically update when this updates with a new TAF.
    static public var shared = TafAPI()
    
    /// New School way of getting the TAF
    public var store = PassthroughSubject<[Taf], Never>()
    @Published var store_: [Taf] = []
    
    private static let session: URLSession = { URLSession(configuration: .default) }()
    
    /// Gets the current TAFs for the Airfield
    /// - Parameter icao: ICAO
    public static func getTafFor(icao: String) {
        let url = AddsWeatherAPI().weatherURL(type: .taf, icao: "\(icao)")
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            print(response)
            if let XMLData = data {
                let currentTafs = TafParser(data: XMLData).tafs
                TafAPI.shared.store.send(currentTafs)
                // TODO:⚠️ Theres a better way to do this
//                print("Hi there")
//                _ = TafAPI.shared.store
//                    .receive(on: RunLoop.main)
//                    .sink(receiveValue: { tafs in
//                        print("OMG")
//                        print(tafs)
//                    })
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }
        }
        task.resume()
    }
}
