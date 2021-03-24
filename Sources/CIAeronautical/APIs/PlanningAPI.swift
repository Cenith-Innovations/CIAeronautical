// ********************** PlanningAPI *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 12/23/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** PlanningAPI *********************************


import SwiftUI
import Combine

@available(tvOS 13.0, *)
@available(iOS 13.0, *)
@available(OSX 10.15, *)
public class PlanningAPI: ObservableObject {
    
    public init(airfieldIcaos: [String] = []) {
        self.airfieldIcaos = airfieldIcaos
    }
    /// Set this when instantiating the Planning API if you want to pull info accross multiple Processors for the ICAOs in here.
    @Published public var airfieldIcaos: [String] = []
    
    /// Publisher that contains NOTAMs
    /// 👉 - This one is still a work in progress. I've decided to go full Object Oriented Programming with this one. Im casting each notam String as a NOTAM object. I need to write the parsers to pull out the different fields.
    /// ### Example use in your View
    ///```
    ///ForEach(planningAPI.notams_[icao] ?? [], id: \.self) { notam in
    ///   Text(notam.startDate?.description ?? "No Date")
    ///}
    ///```
    @Published public var notams: [String: [Notam]] = [:]
    
    // MARK: - 🔅 Publishers: METARs
    /// Publisher that contains the METAR for the input ICAO.
    @Published public var metar = Metar()

    /// Temp Holder for metars to get rid of duplicates. The intended public Publisher is the Array of Metars
//    @Published private var metarSet: Set<Metar> = []
    
    /// Publisher that holds Metars corresponding to AirfieldIcaos
    @Published public var metars: [Metar] = []
    
    // MARK: - 🔅 Publishers: TAF
    /// Publisher that contains the TAFs for the input ICAO.
    @Published public var tafs: [Taf] = []
    
    // MARK: - 🔅 Publishers: AHAS
    /// Publisher that contains the BirdConditions for the input area.
    @Published public var ahas: [Ahas] = []
    
    /// Clears all of the publishers.
    public func clearAll() {
        notams = [:]
        metar = Metar()
        tafs = []
    }
    
    private let session: URLSession = { URLSession(configuration: .default) }()
    
    /// Pulls all of the planning info for a given ICAO. NOTE: the AHAS is pulled for the current time in this function.
    /// - Parameter icao: ICAO identifier for the airfield.
    public func getAllInfoFor(_ icao: String) {
        getMetarFor(icao)
        getTafFor(icao)
        getNotamsFor([icao])
        getBirdConditionCurrentFor(icao)
    }
    
    // MARK: - 🔅 METAR
    /// Downloads the current METAR for the Airfield
    /// - Parameter icao: ICAO
    public func getMetarFor(_ icao: String) {
        let url = AddsWeatherAPI().weatherURL(type: .metar, icao: "\(icao)")
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request) { (data, response, error) -> Void in
            if let XMLData = data {
                let currentMetars = MetarParser(data: XMLData).metars
                if currentMetars.count > 0 {
                    DispatchQueue.main.async {
                        self.metar = currentMetars[0]
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
    
    public func getMetarsForAirfields() {
        for icao in airfieldIcaos {
            let url = AddsWeatherAPI().weatherURL(type: .metar, icao: "\(icao)")
            let request = URLRequest(url: url)
            let task = self.session.dataTask(with: request) { (data, response, error) -> Void in
                if let XMLData = data {
                    let currentMetars = MetarParser(data: XMLData).metars
                    if currentMetars.count > 0 {
                        DispatchQueue.main.async {
                            let newMetar = currentMetars[0]
                            
                            if self.metars.count == self.airfieldIcaos.count {
                                for i in 0..<self.metars.count {
                                    if self.metars[i].stationId == newMetar.stationId {
                                        self.metars.remove(at: i)
                                        self.metars.insert(newMetar, at: i)
                                    }
                                }
                            } else {
                                self.metars.append(newMetar)
                            }
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
    
    // MARK: - 🔅 TAFs
    /// Gets the current TAFs for the Airfield
    /// - Parameter icao: ICAO
    public func getTafFor(_ icao: String) {
        let url = AddsWeatherAPI().weatherURL(type: .taf, icao: "\(icao)")
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            if let XMLData = data {
                DispatchQueue.main.async {
                    self.tafs = TafParser(data: XMLData).tafs
                }
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }
        }
        task.resume()
    }
    
    // MARK: - 🔅 NOTAMs
    /// Retrieves the notams for the corresponding array of icao.
    /// - Parameter icaos: an array of desired icao.
    public func getNotamsFor(_ icaos: [String]) {
        let stations = icaos.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let url = URL(string: "https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let stationData = (stations.reduce("") {$0 + " " + $1 }).trimmingCharacters(in: .whitespacesAndNewlines)
        let postData = "Report=Report&actionType=notamRetrievalByICAOs&retrieveLocId=\(stationData)"
        request.httpBody = postData.data(using: .utf8)
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Data not found, error encountered: \(error!)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Recieved non-200 response, something is ill-formed with the POST request")
                return
            }
            let responseString = String(decoding: data, as: UTF8.self)
            let currentNotams = NotamParser(htmlData: responseString).notams
            DispatchQueue.main.async {
                //Object Oriented
                var tempNotams:[String: [Notam]] = [:]
                for (icao, notamList) in currentNotams {
                    var notams: [Notam] = []
                    for notam in notamList {
                        notams.append(Notam(notam: notam))
                    }
                    tempNotams[icao] = notams
                }
                self.notams = tempNotams
            }
        }
        task.resume()

    }
    
    // MARK: - 🔅 Bird Conditions - AHAS
    /// Goes and fetches the current bird condition for an area. The areas are defined in AhasInputs.swift.
    /// - Parameter area: Area as defined in AhasInputs.swift
    public func getBirdConditionCurrentFor(area: String) {
        self.getBirdCondition(area: area,
                              month: Date.getAhasDateComponents().month,
                              day: Date.getAhasDateComponents().day,
                              hourZ: Date.getAhasDateComponents().hourZ,
                              duration: nil)
    }
    
    
    /// Goes and fetches the current bird condition for an ICAO.
    /// - Parameter icao: Airfield ICAO
    public func getBirdConditionCurrentFor(_ icao: String) {
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        self.getBirdCondition(area: area,
                              month: Date.getAhasDateComponents().month,
                              day: Date.getAhasDateComponents().day,
                              hourZ: Date.getAhasDateComponents().hourZ,
                              duration: nil)
    }
    
    
    /// Goes and fetches the current and future bird condition for an ICAO.
    /// - Parameters:
    ///   - icao: Airfield ICAO
    ///   - numberOfHours: Hours into the future you want to get the bird condition
    public func getBirdConditionFutureFor(icao: String, numberOfHours: Int) {
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        self.getBirdCondition(area: area,
                              month: Date.getAhasDateComponents().month,
                              day: Date.getAhasDateComponents().day,
                              hourZ: Date.getAhasDateComponents().hourZ,
                              duration: numberOfHours)
    }
    
    
    /// Goes and fetches the current and future bird condition for an area as defined in AhasInputs.swift.
    /// - Parameters:
    ///   - area: Area as defined in AhasInputs.swift
    ///   - numberOfHours: Hours into the future you want to get the bird condition.
    public func getBirdConditionFutureFor(area: String, numberOfHours: Int) {
        self.getBirdCondition(area: area,
                              month: Date.getAhasDateComponents().month,
                              day: Date.getAhasDateComponents().day,
                              hourZ: Date.getAhasDateComponents().hourZ,
                              duration: numberOfHours)
    }
    
    
    /// Goes and fetches the current and future bird condition for an VR Route.
    /// - Parameters:
    ///   - ahasSearchable: Any of the myriad ways to search for an area covered by the AHAS website… The most complicated way to find info that no one gives a shit about anyway.
    ///   - numberOfHours: Hours into the future you want to get the bird condition.
    public func getBirdConditionCurrentFor(ahasSearchable: AhasSearchable, numberOfHours: Int) {
        self.getBirdCondition(area: ahasSearchable.description,
                              month: Date.getAhasDateComponents().month,
                              day: Date.getAhasDateComponents().day,
                              hourZ: Date.getAhasDateComponents().hourZ,
                              duration: numberOfHours)
    }
    
    private func getBirdCondition(area: String, month: String, day: String, hourZ: String, duration: Int?) {
        let url = AhasWebAPI.AhasURL(area: area, month: month, day: day, hour: hourZ, parameters: nil)
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request) { (data, response, error) -> Void in
            if let XMLData = data {
                let birdCondition = AhasParser(data: XMLData).ahas
                DispatchQueue.main.async {
                    self.ahas = birdCondition
                }
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }}
        task.resume()
    }
    
    
}
