//
//  File.swift
//  
//
//  Created by Jorge Alvarez on 4/25/22.
//

import Foundation
import SwiftUI
import Combine

@available(tvOS 13.0, *)
@available(iOS 13.0, *)
@available(OSX 10.15, *)

public class WeatherController: ObservableObject {
    
    required public init(airfieldIcaos: [String] = []) {
        self.airfieldIcaos = airfieldIcaos
    }
    /// Set this when instantiating the Planning API if you want to pull info accross multiple Processors for the ICAOs in here.
    @Published public var airfieldIcaos: [String] = []

    @Published public var notams: [String: [Notam]] = [:]
    @Published public var notamsLastFetchedDate: Date?
    
    /// Publisher that holds Metars corresponding to AirfieldIcaos
    @Published public var metars: [String: Metar] = [:]
    @Published public var metarsLastFetchedDate: Date?
    
    /// Publisher that contains the TAFs for the input ICAO.
    @Published public var tafs: [String: Taf] = [:]
    @Published public var tafsLastFetchedDate: Date?
    
    /// Publisher that contains the BirdConditions for the input area.
    @Published public var ahas: [Ahas] = []
    
    /// Clears all of the publishers.
    public func clearAll() {
        notams = [:]
        metars = [:]
        tafs = [:]
    }
    
    /// Retrieves METARs, TAFs, and NOTAMS for passed in array of icaos
    public func getAllWeather(icaos: [String]) {
        getAllMetars(icaos: icaos)
        getAllTafs(icaos: icaos)
        getAllNotams(icaos: icaos)
    }
    
    // MARK: METAR
    
    public func getAllMetars(icaos: [String]) {
        
        let airfieldsString = icaos.joined(separator: ",")
        
        // TODO: create URL same way PlanningAPI does it?
        let url = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=xml&hoursBeforeNow=2&mostRecentForEachStation=true&stationString=\(airfieldsString)")!
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let xmlData = data {
                let currentMetars = MetarParser(data: xmlData).metars
                var tempMetarsDict = [String: Metar]()
                for metar in currentMetars {
                    guard let icao = metar.stationId else { continue }
                    tempMetarsDict[icao] = metar
                }
                
                DispatchQueue.main.async {
                    self.metars = tempMetarsDict
                    self.metarsLastFetchedDate = Date()
                }
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }
        }
        task.resume()
    }
    
    // MARK: TAF
    
    public func getAllTafs(icaos: [String]) {
        let airfieldsString = icaos.joined(separator: ",")
        let times = Date.getDateForTaf(nowPlusHours: 8)
        let df = DateFormatter()
        df.dateFormat = DateFormat.reference.value
        let start = "\(Int(times.now!.timeIntervalSince1970.rounded()))"
        let end = "\(Int(times.endTime!.timeIntervalSince1970.rounded()))"
        let url = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=tafs&format=xml&endTime=\(end)&startTime=\(start)&requestType=retrieve&mostRecentForEachStation=true&stationString=\(airfieldsString)")!
        print("\(#function) url: \(url)")
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let xmlData = data {
                let currentTafs = TafParser(data: xmlData).tafs
                var tempTafsDict = [String: Taf]()
                
                for taf in currentTafs {
                    guard let icao = taf.stationId else { continue }
                    tempTafsDict[icao] = taf
                }
    
                DispatchQueue.main.async {
                    self.tafs = tempTafsDict
                    self.tafsLastFetchedDate = Date()
                }
            } else if let requestError = error {
                print("Error fetching tafs: \(requestError)")
            } else {
                print("Unexpected error with request")
            }
        }
        task.resume()
    }
    
    // MARK: NOTAM
    
    /// Retrieves the notams for the corresponding array of icao.
    /// - Parameter icaos: an array of desired icao.
    public func getAllNotams(icaos: [String]) {
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
                self.notamsLastFetchedDate = Date()
            }
        }
        task.resume()

    }
    
    // MARK: AHAS

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
        
    private func getBirdCondition(area: String, month: String, day: String, hourZ: String, duration: Int?) {
        let url = AhasWebAPI.AhasURL(area: area, month: month, day: day, hour: hourZ, parameters: nil)
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
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
