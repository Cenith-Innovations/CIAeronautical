// ********************** TafParser *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** TafParser *********************************


import Foundation

/// Parses the TAF and decodes the TAF
public class TafParser: NSObject, XMLParserDelegate {
    private let taf = TafField.tafMain.rawValue
    private let tafKeys = TafField.allCases.map { $0.rawValue }
    private let forecastKeys = ForecastField.allCases.map { $0.rawValue }
    private let skyConditionKeys = SkyConditionField.allCases.map { $0.rawValue }
    private let turbulanceKeys = TurbulanceConditionField.allCases.map { $0.rawValue }
    private let icingKeys = IcingConditionField.allCases.map { $0.rawValue }
    private var results: [[String: String]]?
    private var currentTaf: [String: String]?
    private var currentValue: String?
    var tafs: [Taf] = []
    
    private var forecast: Forecast?
    private var currentForecast: [String: String]?
    private var forecasts: [Forecast] = []
    private var skyConditions: [SkyCondition] = []
    private var turbulanceConditions: [TurbulanceCondition] = []
    private var icingConditions: [IcingCondition] = []
    
    // Now Forecasts come in when receiving multiple TAFs
    private var forecastsDict = [String: [Forecast]]()
    
    convenience init(data: Data) {
        self.init()
        let parser = XMLParser(data: data)
        parser.delegate = self
        let _ = parser.parse()
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        results = []
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == taf {
            currentTaf = [:]
            currentForecast = [:]
            forecasts = []
            skyConditions = []
            turbulanceConditions = []
            icingConditions = []
        } else if tafKeys.contains(elementName) {
            if elementName == ForecastField.forecast.rawValue {
                forecast = Forecast()
            }
        } else if elementName == skyConditionField(.skyCondition) {
            skyConditions.append(SkyCondition(skyCover: attributeDict[skyConditionField(.skyCover)],
                                              cloudBaseFtAgl: attributeDict[skyConditionField(.cloudBaseFtAGL)].toDouble,
                                              cloudType: attributeDict[skyConditionField(.cloudType)]))
            
        } else if elementName == turbulanceConditionField(.turbulenceCondition) {
            turbulanceConditions.append(TurbulanceCondition(intensity: attributeDict[turbulanceConditionField(.intensity)],
                                                            minAltFtAgl: attributeDict[turbulanceConditionField(.minAltFtAGL)]?.toDouble,
                                                            maxAltFtAgl: attributeDict[turbulanceConditionField(.maxAltFtAGL)].toDouble))
        } else if elementName == icingConditionField(.icingCondition) {
            icingConditions.append(IcingCondition(intensity: attributeDict[icingConditionField(.intensity)],
                                                  minAltFtAgl: attributeDict[icingConditionField(.minAltFtAGL)]?.toDouble,
                                                  maxAltFtAgl: attributeDict[icingConditionField(.maxAltFtAGL)]?.toDouble))
        }
        currentValue = ""
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case _ where elementName == taf:
            results!.append(currentTaf!)
            
            // package up Forecasts to match with this taf later
            if let stationId = currentTaf!["station_id"] {
                forecastsDict[stationId] = forecasts
            }
            
            currentTaf = nil
        case _ where elementName == ForecastField.forecast.rawValue:
            forecast = Forecast(forecastTimeFrom: currentForecast?[forecastField(.forecastTimeFrom)].metarTafStringToDate, forecastTimeTo: currentForecast?[forecastField(.forecastTimeTo)].metarTafStringToDate, changeIndicator: currentForecast?[forecastField(.changeIndicator)], timeBecoming: currentForecast?[forecastField(.timeBecoming)].metarTafStringToDate, probability: currentForecast?[forecastField(.probability)].toInt, windDirDegrees: currentForecast?[forecastField(.windDirDegrees)].toDouble, windSpeedKts: currentForecast?[forecastField(.windSpeedKts)].toDouble, windGustKts: currentForecast?[forecastField(.windGustKts)].toDouble, windShearHeightFtAGL: currentForecast?[forecastField(.windShearHeightAboveGroundFt)].toInt, windShearDirDegrees: currentForecast?[forecastField(.windShearDirDegrees)].toDouble, windShearSpeedKts: currentForecast?[forecastField(.windShearSpeedKts)].toDouble, visibilityStatuteMiles: currentForecast?[forecastField(.visibilityStatuteMiles)].toDouble, altimeterInHg: currentForecast?[forecastField(.altimeterInHg)].toDouble, verticleVisFt: currentForecast?[forecastField(.vertVisFt)].toDouble, wxString: currentForecast?[forecastField(.weatherString)], notDecoded: currentForecast?[forecastField(.notDecoded)], skyConditions: skyConditions, turbulenceCondition: turbulanceConditions, icingConditions: icingConditions)
            forecasts.append(forecast!)
            forecast = nil
        case _ where tafKeys.contains(elementName):
            currentTaf![elementName] = currentValue
            currentValue = nil
            
        case _ where forecastKeys.contains(elementName) && elementName != forecastField(.forecast):
            currentForecast![elementName] = currentValue
            currentValue = nil
        default:
            break
        }
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        if let resultTafs = results {
            for taf in resultTafs {
                let wx = Taf(rawText: taf[tafField(.rawText)],
                             stationId: taf[tafField(.stationId)],
                             issueTime: taf[tafField(.issueTime)].metarTafStringToDate,
                             bulletinTime: taf[tafField(.bulletinTime)].metarTafStringToDate,
                             validTimeFrom: taf[tafField(.validTimeFrom)].metarTafStringToDate,
                             validTimeTo: taf[tafField(.validTimeTo)].metarTafStringToDate,
                             remarks: taf[tafField(.remarks)],
                             latitude: taf[tafField(.latitude)].toDouble,
                             longitude: taf[tafField(.longitude)].toDouble,
                             elevationM: taf[tafField(.elevationM)].toDouble,
                             forecast: forecastsDict[taf[tafField(.stationId)] ?? ""],
                             temperature: taf[tafField(.temperature)].toDouble,
                             validTime: taf[tafField(.validTime)].metarTafStringToDate,
                             surfaceTempC: taf[tafField(.surfcaeTempC)].toDouble,
                             maxTempC: taf[tafField(.maxTempC)].toDouble,
                             minTempC: taf[tafField(.minTempC)].toDouble)
                tafs.append(wx)
            }
        }
    }
    
    fileprivate func tafField(_ f: TafField) -> String {
        return f.rawValue
    }
    
    fileprivate func forecastField(_ f: ForecastField) -> String {
        return f.rawValue
    }
    
    fileprivate func skyConditionField(_ f: SkyConditionField) -> String {
        return f.rawValue
    }
    
    fileprivate func turbulanceConditionField(_ f: TurbulanceConditionField) -> String {
        return f.rawValue
    }
    
    fileprivate func icingConditionField(_ f: IcingConditionField) -> String {
        return f.rawValue
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
        currentValue = nil
        currentTaf = nil
        results = nil
    }
}
