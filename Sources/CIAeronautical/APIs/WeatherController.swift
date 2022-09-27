//
//  AirDataSource.swift
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
    
    /// Publisher that contains the AQIs (current observations) for the input ICAO. Current observations only need to be fetched once an hour
    @Published public var airQualities: [String: [AirQuality]] = [:]
    @Published public var isFetchingAirQuality = false
    
    /// Publisher that contains the AQIs Forecasts for the input ICAO. Forecasts only need to be fetched once a day
    @Published public var airForecasts: [String: [AirQuality]] = [:]
    @Published public var isFetchingAirForecast = false
    
    /// Publisher that contains the an airfields data source for air quality
    @Published public var airDataSources: [String: AirDataSource] = [:]
        
    // DragonBoard
    /// Date when all ahas were last fetched
    @Published public var ahasFetchedDate: Date?
    /// Publisher that contains AHAS for each icao
    @Published public var ahasDict: [String: Ahas?] = [:]
        
    /// API key passed in when initializing. Eventually will be stored in our own server
    let airNowAPIKey: String
    
    public init(key: String) {
        print("WeatherController init")
        airNowAPIKey = key
    }
    
    deinit {
        print("WeatherController deinit")
    }
    
    // MARK: - AQI (Air Quality Index)
    
    /// Only fetches AirDataSource if the we haven't already fetched one for the given ICAO.
    public func getAirDataSource(icao: String, reportingArea: String, stateCode: String) {
        
        guard airDataSources[icao] == nil else { return }
        
        let area = reportingArea.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: "https://airnowgovapi.com/andata/dataproviders?reportingArea=\(area)&stateCode=\(stateCode)")!
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    do {
                        let airDataSource = try JSONDecoder().decode(AirDataSource.self, from: data)
                        self?.airDataSources[icao] = airDataSource
                    } catch {
                        print("error decoding AirDataSource")
                    }
                } else {
                    print("Error getting AirDataSource")
                }
            }
        }
        task.resume()
    }
    
    /// Fetches Air Qualities for given location and then calls method that fetches that locations air data source.
    public func getAirQualityForecast(icao: String, lat: Double, long: Double) {
        
        let currentDayString = Date.yearMonthDayString(date: Date())
        guard let date = currentDayString else { return }
        
        // if it DOESNT need refresh, return
        if !AirQuality.forecastNeedsRefresh(currentDayString: date, forecasts: airForecasts[icao]) {
            print("Air forecasts do NOT need refresh, returning early")
            return
        }
        
        let url = URL(string: "https://www.airnowapi.org/aq/forecast/latLong/?format=application/json&latitude=\(lat)&longitude=\(long)&date=\(date)&API_KEY=\(airNowAPIKey)")!
        
        isFetchingAirForecast = true
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let airForecastsArray = try JSONDecoder().decode([AirQuality].self, from: data)
                        self?.airForecasts[icao] = airForecastsArray
                        
                        // TODO: value for key should be another [String: [AirQuality]] dictionary
                        // TODO: key for inner dictionary should just be raw date comps sent
                        var innerDict = [String: [AirQuality]]()
                        for forecast in airForecastsArray {
                            guard let forecastDay = forecast.dateForecast else {
                                continue
                            }
                            
                            if innerDict[forecastDay] == nil {
                                innerDict[forecastDay] = [forecast]
                            } else {
                                innerDict[forecastDay]!.append(forecast)
                            }
                        }
                        
                        // TODO: sort each inner array value by categoryNumber?
                        
                        // fetch data source here, since it only needs to be fetched once every app lifecycle
                        if let area = airForecastsArray.first?.reportingArea, let state = airForecastsArray.first?.stateCode {
                            self?.getAirDataSource(icao: icao, reportingArea: area, stateCode: state)
                        }
                    } catch {
                        print("error decoding aq forecasts")
                    }
                } else {
                    print("Error getting AQ forecasts")
                }
                self?.isFetchingAirForecast = false
            }
        }
        task.resume()
    }
    
    /// Fetches current AirQuality for given ICAO. Rate limiting handled per device, will need to be handled server side once project scale grows
    public func getAirQualityCurrent(icao: String, lat: Double, long: Double) {
                
        // return early if he already fetched airQuality for current hour and its been less than 1 hour since we last fetched it
        if let aqs = airQualities[icao], let highestAq = AirQuality.highestAqi(aqs: aqs), !highestAq.observationNeedsRefresh {
            print("selected aq doesn't need refresh")
            return
        }
        
        let url = URL(string: "https://www.airnowapi.org/aq/observation/latLong/current/?format=application/json&latitude=\(lat)&longitude=\(long)&API_KEY=\(airNowAPIKey)")!
        
        isFetchingAirQuality = true
        
        self.airQualities[icao] = nil
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let airQualityArray = try JSONDecoder().decode([AirQuality].self, from: data)
                        self?.airQualities[icao] = airQualityArray.sorted(by: { $0.aqi ?? 0 > $1.aqi ?? 0 } )
                    } catch {
                        print("error decoding aq")
                    }
                } else {
                    print("Error getting AQ")
                }
                self?.isFetchingAirQuality = false
            }
        }
        task.resume()
    }
    
    /// Clears all of the publishers.
    public func clearAll() {
        notams = [:]
        metars = [:]
        tafs = [:]
        // TODO: clear ahas and airQualities?
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
        
        let url = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=xml&hoursBeforeNow=2&mostRecentForEachStation=true&stationString=\(airfieldsString)")!
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            if let xmlData = data {
                let currentMetars = MetarParser(data: xmlData).metars
                var tempMetarsDict = [String: Metar]()
                for metar in currentMetars {
                    guard let icao = metar.stationId else { continue }
                    tempMetarsDict[icao] = metar
                }
                
                DispatchQueue.main.async {
                    self?.metars = tempMetarsDict
                    self?.metarsLastFetchedDate = Date()
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
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            if let xmlData = data {
                let currentTafs = TafParser(data: xmlData).tafs
                var tempTafsDict = [String: Taf]()
                
                for taf in currentTafs {
                    guard let icao = taf.stationId else { continue }
                    tempTafsDict[icao] = taf
                }
    
                DispatchQueue.main.async {
                    self?.tafs = tempTafsDict
                    self?.tafsLastFetchedDate = Date()
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
        
        if let XMLString = String(data: postData.data(using: .utf8)!, encoding: String.Encoding.utf8)
        {
            print("notams post body XML = \(XMLString)")
        }
        
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Data not found, error encountered: \(error!)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Recieved non-200 response, something is ill-formed with the POST request")
                return
            }
            let responseString = String(decoding: data, as: UTF8.self)
            print("notams responseString = \(responseString)")
            
            if let JSONString = String(data: data, encoding: String.Encoding.utf8)
            {
                print("notams response xml = \(JSONString)")
            }
            
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
                self?.notams = tempNotams
                self?.notamsLastFetchedDate = Date()
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
        let task = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            if let XMLData = data {
                let birdCondition = AhasParser(data: XMLData).ahas
                DispatchQueue.main.async {
                    self?.ahas = birdCondition
                }
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }}
        task.resume()
    }
    
    public func getAllAhasChained(icaos: [String]) {
        
        // reset dict first
        ahasDict = [:]
        
        // set new date
        ahasFetchedDate = Date()
        
        for icao in icaos {
            print("fetching Ahas for \(icao)...")
            getAhasFor(icao: icao)
        }
    }
    
    /// Adds fetched Ahas into ahasDict
    private func getAhasFor(icao: String) {
        
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        let url = AhasWebAPI.AhasURL(area: area,
                                     month: Date.getAhasDateComponents().month,
                                     day: Date.getAhasDateComponents().day,
                                     hour: Date.getAhasDateComponents().hourZ,
                                     parameters: nil)
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            if let XMLData = data {
                let birdCondition = AhasParser(data: XMLData).ahas
                DispatchQueue.main.async {
                    self?.ahasDict[icao] = birdCondition.first
                }
            } else if let requestError = error {
                print("Error fetching ahas: \(requestError)")
            } else {
                print("Unexpected error with request")
            }}
        task.resume()
    }
}
