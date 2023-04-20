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

    /// Notams for DINS endpoint. Unused now
    @Published public var notams: [String: [Notam]] = [:]
    @Published public var notamsLastFetchedDate: Date?
    
//    @Published public var notamsFaa: [String: [NOTAM]] = [:]
    /// Publisher that holds NOTAMS for all icaos (FAA ones, not DINS)
    @Published public var notamsFaa = [String: [NOTAM]]()
    @Published public var notamsFaaLastFetchedDate: Date? { didSet { print("updated last fetched date") } }
    @Published public var isLoadingAllNotamsFaa = false
    @Published public var notamsFaaAreCurrent = false
    
    /// Publisher that holds Metars corresponding to AirfieldIcaos
    @Published public var metars: [String: Metar] = [:]
    @Published public var metarsLastFetchedDate: Date?
    
    /// Publisher that contains the TAFs for the input ICAO.
    @Published public var tafs: [String: Taf] = [:]
    @Published public var tafsLastFetchedDate: Date?
    
    /// Publisher that contains the BirdConditions for the input area.
    @Published public var ahas: [String: [Ahas]] = [:]
    
    /// Publisher that contains the AQIs (current observations) for the input ICAO. Current observations only need to be fetched once an hour
    @Published public var airQualities: [String: [AirQuality]] = [:]
    @Published public var isFetchingAirQuality = false
    
    /// Publisher that contains the AQIs Forecasts for the input ICAO. Forecasts only need to be fetched once a day
    @Published public var airForecasts = [String: [String: [AirQuality]]]()
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
        if !AirQuality.forecastNeedsRefresh(currentDayString: date, forecasts: airForecasts[icao]?[date + " "]) {
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
                        self?.airForecasts[icao] = AirQuality.weeklyForecasts(forecasts: airForecastsArray)
                        
                        // TODO: if we get no forecast for this ICAO, use reporting area from its current observation?
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
        getAllNotamsFAA(icaos: icaos)
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
    
    /// Checks notamsLastFetchedDate to see if we can make another request to get newest notamsFaa
    public var notamsFaaNeedRefresh: Bool {
        if let lastDate = notamsFaaLastFetchedDate {
            print("notamsFaaLastFetchedDate: \(lastDate)")
            let diff = Date().timeIntervalSinceReferenceDate - lastDate.timeIntervalSinceReferenceDate
            print("notams diff = \(diff)")
            if diff < 120 {
                print("fetched notamsFaa less than 2 mins ago")
                return false
            }
            print("its been longer than 2 minutes since fetching this notamsFaa")
        }
        
        return true
    }
    
    /// Returns a dictionary of all NOTAMS for input ICAOS. Also takes in offset and total NOTAMS count integers and list of previous NOTAMS to recursively chain together next
    /// page's worth of NOTAMS since FAA endpoint only returns 30 results at a time. This is a backup for our server's NOTAMS endpoint.
    public func getAllNotamsFAA(icaos: [String], offset: Int = 0, prevNotams: [NOTAM] = [], total: Int = 0) {
        print(#function)
        guard notamsFaaNeedRefresh else {
            print("returning early since notamsFaa are less than 2 mins old")
            return
        }
        
        let url = URL(string: "https://notams.aim.faa.gov/notamSearch/search")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let icaosString = icaos.joined(separator: ",")
        // TODO: only send relevant parameters?
        // TODO: strip first "K" from each icao and use that for search string so we can get back some nearby locations too
        let postData = "searchType=0&designatorsForLocation=\(icaosString)&designatorForAccountable=&latDegrees=&latMinutes=0&latSeconds=0&longDegrees=&longMinutes=0&longSeconds=0&radius=10&sortColumns=5+false&sortDirection=true&designatorForNotamNumberSearch=&notamNumber=&radiusSearchOnDesignator=false&radiusSearchDesignator=&latitudeDirection=N&longitudeDirection=W&freeFormText=&flightPathText=&flightPathDivertAirfields=&flightPathBuffer=4&flightPathIncludeNavaids=true&flightPathIncludeArtcc=false&flightPathIncludeTfr=true&flightPathIncludeRegulatory=false&flightPathResultsType=All+NOTAMs&archiveDate=&archiveDesignator=&offset=\(offset)&filters=Keywords:+Aerodrome-AD~Aerodrome-APRON~Aerodrome-CONSTRUCTION~Aerodrome-RWY~Aerodrome-SVC~Aerodrome-TWY~Airspace-AIRSPACE~Airspace-CARF~Airspace-TFR~Chart-CHART~Communication-AD~Communication-COM~GPS-GPS~International-INTERNATIONAL~Military-MILITARY~Navaid-AD~Navaid-AIRSPACE~Navaid-COM~Navaid-NAV~Navaid-RWY~Navaid-SVC~Obstruction-OBST~Other-(O)~Procedure-FDC/Other~Procedure-IAP~Procedure-ODP~Procedure-SID~Procedure-SPECIAL~Procedure-STAR~Procedure-VFP~Route-ROUTE~Security-SECURITY~Services-SVC"
        
        request.httpBody = postData.data(using: .utf8)
        
        // dont set to true if already true to avoid redundant ui redraws
        if !self.isLoadingAllNotamsFaa { self.isLoadingAllNotamsFaa = true }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    do {
                        let notamsResponse = try JSONDecoder().decode(NotamsResponse.self, from: data)
                        
                        if let notamList = notamsResponse.notamList, let total = notamsResponse.totalNotamCount {
                            let newOffset = offset + 30
                            if newOffset > total {
                                let allNotams = notamList + prevNotams
                                var tempNotams = [String: [NOTAM]]()
                                for notam in allNotams {
                                    guard let icao = notam.icaoId else { continue }
                                    if tempNotams[icao] == nil {
                                        tempNotams[icao] = [notam]
                                    } else {
                                        tempNotams[icao]!.append(notam)
                                    }
                                }
                                
                                self?.notamsFaa = tempNotams
                                self?.isLoadingAllNotamsFaa = false
                                self?.notamsFaaLastFetchedDate = Date()
                                print("got all notams")
                                return
                            } else {
                                self?.getAllNotamsFAA(icaos: icaos,
                                                      offset: newOffset,
                                                      prevNotams: notamList + prevNotams,
                                                      total: total)
                            }
                        }
                    } catch {
                        print("error decoding notam faa")
                        self?.isLoadingAllNotamsFaa = false
                    }
                } else {
                    print("no data notams faa")
                    self?.isLoadingAllNotamsFaa = false
                }
            }
        }
        task.resume()
    }
    
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
            }
        }
        task.resume()

    }
    
    // MARK: AHAS

    // TODO: Make an AHASController class instead?
    // TODO: every function that gets AHAS should first check if the one that's beind replaced is within the 6min time frame
    // TODO: create function that returns whether or not request should be ignored
    
    /// Goes and fetches the current bird condition for an ICAO.
    /// - Parameter icao: Airfield ICAO
    // TODO: also not used anymore
    public func getBirdConditionCurrentFor(_ icao: String) {
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        self.getBirdCondition(area: area,
                              month: Date.getAhasDateComponents().month,
                              day: Date.getAhasDateComponents().day,
                              hourZ: Date.getAhasDateComponents().hourZ)
    }
        
    // TODO: this one isn't used anymore
    private func getBirdCondition(area: String, month: String, day: String, hourZ: String) {
        let url = AhasWebAPI.AhasURL(area: area, month: month, day: day, hour: hourZ, hr12Risk: true)
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            if let XMLData = data {
                let birdCondition = AhasParser(data: XMLData).ahas
                DispatchQueue.main.async {
                    // if dateTime minutes is 00 AND current minute is not 0-6
                    // that means we need to get current AHAS and replace first result with that
                    
//                    self?.ahas[icao] = birdCondition
                }
            } else if let requestError = error {
                print("Error fetching metar: \(requestError)")
            } else {
                print("Unexpected error with request")
            }}
        task.resume()
    }
    
    /// Gets AHAS for given array of ICAO by starting a request for all after reseting ahasDict and ahasFetchedDate
    public func getAllAhasChained(icaos: [String]) {
        
        // reset dict first
        ahasDict = [:]
        
        // set new date
        ahasFetchedDate = Date()
        
        for icao in icaos {
            print("fetching Ahas for \(icao)...")
//            getAhas12HR(icao: icao)
            getAhasCurrentOnly(icao: icao)
//            getAhasFor(icao: icao)
        }
    }
    
    /// Adds fetched Ahas into ahasDict
    private func getAhasFor(icao: String) {
        
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        let url = AhasWebAPI.AhasURL(area: area,
                                     month: Date.getAhasDateComponents().month,
                                     day: Date.getAhasDateComponents().day,
                                     hour: Date.getAhasDateComponents().hourZ,
                                     hr12Risk: true)
        
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
    
    /// Gets next 12 hours of AHAS. Sometimes the current hour result is only for the start of the hour, so we need to get current hour only to get more recent info
    public func getAhas12HR(icao: String) {
        
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        let url = AhasWebAPI.AhasURL(area: area,
                                     month: Date.getAhasDateComponents().month,
                                     day: Date.getAhasDateComponents().day,
                                     hour: Date.getAhasDateComponents().hourZ,
                                     hr12Risk: true)
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            if let XMLData = data {
                let birdCondition = AhasParser(data: XMLData).ahas
                DispatchQueue.main.async {
                    
                    // if first one's Date minutes is 00 AND current mins is greater than 6, fetch current Ahas only
                    if let first = birdCondition.first, let firstDate = first.dateTime {
                        let firstDateComps = Calendar.current.dateComponents([.minute], from: firstDate)
                        let currentDateComps = Calendar.current.dateComponents([.minute], from: Date())
                        print("firstDate mins: \(firstDateComps.minute ?? -1) currDate mins: \(currentDateComps.minute ?? -1)")
                        if let firstMins = firstDateComps.minute, let currMins = currentDateComps.minute, firstMins == 0, currMins > 6 {
                            self?.getAhasCurrentOnly(icao: icao)
                        }
                    }
                    self?.ahas[icao] = birdCondition
                }
            } else if let requestError = error {
                print("Error fetching ahas: \(requestError)")
            } else {
                print("Unexpected error with request")
            }}
        task.resume()
    }
    
    /// Only used when 12 hr endpoint isn't returning the most recent hour's current bird risk. Usually only happens mid day for some reason
    public func getAhasCurrentOnly(icao: String) {
        
        let area = AHASInputs.hiddenInputs[icao] ?? ""
        let url = AhasWebAPI.AhasURL(area: area,
                                     month: Date.getAhasDateComponents().month,
                                     day: Date.getAhasDateComponents().day,
                                     hour: Date.getAhasDateComponents().hourZ,
                                     hr12Risk: false)
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            if let XMLData = data {
                let birdCondition = AhasParser(data: XMLData).ahas
                DispatchQueue.main.async {
                    if let risks = self?.ahas[icao], let first = birdCondition.first, !risks.isEmpty {
                        self?.ahas[icao]?[0] = first
                    }
                }
            } else if let requestError = error {
                print("Error fetching ahas: \(requestError)")
            } else {
                print("Unexpected error with request")
            }}
        task.resume()
    }
}
