// ********************** AhasAPI *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AhasAPI *********************************


import Foundation
import Combine

@available(OSX 10.15, *)
/// Classy way to download the AHAS bird conditions.
public class AhasAPI: ObservableObject {
    
    /// A shared instance of the AhasAPI, used to link the @Published ahasStore so your user-interface will automatically update when this updates with a new AHAS BirdCondition.
    public static var shared = AhasAPI()
    
    /// New School way of getting the Ahas
    public var store = PassthroughSubject<[Ahas], Never>()
    
    /// Goes and fetches the current bird condition for an area. The areas are defined in AhasInputs.swift.
    /// - Parameter area: Area as defined in AhasInputs.swift
    public static func getBirdConditionCurrentFor(area: String) {
        AhasAPI.shared.getBirdCondition(area: area,
                                        month: Date.getAhasDateComponents().month,
                                        day: Date.getAhasDateComponents().day,
                                        hourZ: Date.getAhasDateComponents().hourZ,
                                        duration: nil)
    }
    
    
    /// Goes and fetches the current bird condition for an ICAO.
    /// - Parameter icao: Airfield ICAO
    public static func getBirdConditionCurrentFor(icao: String) {
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        AhasAPI.shared.getBirdCondition(area: area,
                                        month: Date.getAhasDateComponents().month,
                                        day: Date.getAhasDateComponents().day,
                                        hourZ: Date.getAhasDateComponents().hourZ,
                                        duration: nil)
    }
    
    
    /// Goes and fetches the current and future bird condition for an ICAO.
    /// - Parameters:
    ///   - icao: Airfield ICAO
    ///   - numberOfHours: Hours into the future you want to get the bird condition
    public static func getBirdConditionFutureFor(icao: String, numberOfHours: Int) {
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        AhasAPI.shared.getBirdCondition(area: area,
                                        month: Date.getAhasDateComponents().month,
                                        day: Date.getAhasDateComponents().day,
                                        hourZ: Date.getAhasDateComponents().hourZ,
                                        duration: numberOfHours)
    }
    
    
    /// Goes and fetches the current and future bird condition for an area as defined in AhasInputs.swift.
    /// - Parameters:
    ///   - area: Area as defined in AhasInputs.swift
    ///   - numberOfHours: Hours into the future you want to get the bird condition.
    public static func getBirdConditionFutureFor(area: String, numberOfHours: Int) {
        AhasAPI.shared.getBirdCondition(area: area,
                                        month: Date.getAhasDateComponents().month,
                                        day: Date.getAhasDateComponents().day,
                                        hourZ: Date.getAhasDateComponents().hourZ,
                                        duration: numberOfHours)
    }
    
    
    /// Goes and fetches the current and future bird condition for an VR Route.
    /// - Parameters:
    ///   - ahasSearchable: Any of the myriad ways to search for an area covered by the AHAS website… The most complicated way to find info that no one gives a shit about anyway.
    ///   - numberOfHours: Hours into the future you want to get the bird condition.
    public static func getBirdConditionCurrentFor(ahasSearchable: AhasSearchable, numberOfHours: Int) {
        AhasAPI.shared.getBirdCondition(area: ahasSearchable.description,
                                        month: Date.getAhasDateComponents().month,
                                        day: Date.getAhasDateComponents().day,
                                        hourZ: Date.getAhasDateComponents().hourZ,
                                        duration: numberOfHours)
    }
    
    
    private let session: URLSession = { URLSession(configuration: .default) }()
    
    public func getBirdCondition(area: String, month: String, day: String, hourZ: String, duration: Int?) {
        let url = AhasWebAPI.AhasURL(area: area, month: month, day: day, hour: hourZ, parameters: nil)
        print(url)
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request) { (data, response, error) -> Void in
            if let XMLData = data {
                let birdCondition = AhasParser(data: XMLData).ahas
                DispatchQueue.main.async {
                    AhasAPI.shared.store.send(birdCondition)
                }
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }}
        task.resume()
    }
    
    
}
