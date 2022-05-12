// ********************** MetarParser *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** MetarParser *********************************


import Foundation
import CIFoundation

/// Class to download and process METARs
public class MetarParser: NSObject, ObservableObject, XMLParserDelegate {
    private let metar = MetarField.metarMain.rawValue
    private let metarKeys = MetarField.allCases.map { $0.rawValue }
    private var results: [[String: String]]?
    private var currentMetar: [String: String]?
    private var currentValue: String?
    public var metars: [Metar] = []
    
    convenience init(data: Data) {
        self.init()
        //        let str = String(data: data, encoding: .utf8)
        let parser = XMLParser(data: data)
        parser.delegate = self
        let _ = parser.parse()
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        results = []
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == metar {
            currentMetar = [:]
            skyConditions = []
        } else if metarKeys.contains(elementName) {
            if elementName == metarField(.skyCondition) {
                skyConditions.append(SkyCondition(skyCover: attributeDict[skyConditionField(.skyCover)],
                                                  cloudBaseFtAgl: attributeDict[skyConditionField(.cloudBaseFtAGL)].toDouble))
            }
            currentValue = ""
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    var skyConditions: [SkyCondition?] = []
    var skyConditionsDict: [String: [SkyCondition?]] = [:]
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == metar {
            results!.append(currentMetar!)
            
            // package up skyConditions for metar that ended into a dictionary we'll use at the end
            if let stationId = currentMetar!["station_id"] {
                skyConditionsDict[stationId] = skyConditions
            }
            
            currentMetar = nil
        } else if metarKeys.contains(elementName) {
            currentMetar?[elementName] = currentValue
            currentValue = nil
        }
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        if let resultMetars = results {
            for metar in resultMetars {
                let wx = Metar(rawText: metar[MetarField.rawText.rawValue] ?? "",
                               stationId: metar[MetarField.stationId.rawValue] ?? "",
                               observationTime: metar[MetarField.observationTime.rawValue].metarTafStringToDate ?? Date(),
                               latitude: metar[MetarField.latitude.rawValue].toDouble ?? 0,
                               longitude: metar[MetarField.longitude.rawValue].toDouble ?? 0,
                               tempC: metar[MetarField.tempC.rawValue].toDouble ?? 0,
                               dewPointC: metar[MetarField.dewPointC.rawValue].toDouble ?? 0,
                               windDirDegrees: metar[MetarField.windDirDegrees.rawValue].toDouble ?? 0,
                               windSpeedKts: metar[MetarField.windSpeedKts.rawValue].toDouble ?? 0,
                               windGustKts: metar[MetarField.windGustKts.rawValue].toDouble ?? 0,
                               visibilityStatuteMiles: metar[MetarField.visibilityStatuteMiles.rawValue].toDouble ?? 0,
                               altimeterInHg: metar[MetarField.altimeterInHg.rawValue].toDouble ?? 0,
                               seaLevelPressureMb: metar[MetarField.seaLevelPressureMb.rawValue].toDouble ?? 0,
                               qualityControlFlags: metar[MetarField.qualityControlFlags.rawValue] ?? "",
                               wxString: metar[MetarField.wxString.rawValue] ?? "",
                               skyCondition: skyConditionsDict[metar[MetarField.stationId.rawValue] ?? ""] ?? [],
                               flightCategory: metar[MetarField.flightCategory.rawValue] ?? "",
                               threeHrPressureTendencyMb: metar[MetarField.threeHrPressureTendencyMb.rawValue] ?? "",
                               maxTempPastSixHoursC: metar[MetarField.maxTempPastSixHoursC.rawValue].toDouble ?? 0,
                               minTempPastSixHoursC: metar[MetarField.minTempPastSixHoursC.rawValue].toDouble ?? 0,
                               maxTemp24HrC: metar[MetarField.maxTemp24HrC.rawValue].toDouble ?? 0,
                               minTemp24HrC: metar[MetarField.minTemp24HrC.rawValue].toDouble ?? 0,
                               precipIn: metar[MetarField.precipIn.rawValue].toDouble ?? 0,
                               precipLast3HoursIn: metar[MetarField.precipLast3HoursIn.rawValue].toDouble ?? 0,
                               precipLast6HoursIn: metar[MetarField.precipLast6HoursIn.rawValue].toDouble ?? 0,
                               precipLast24HoursIn: metar[MetarField.precipLast24HoursIn.rawValue].toDouble ?? 0,
                               snowIn: metar[MetarField.snowIn.rawValue].toDouble ?? 0,
                               vertVisFt: metar[MetarField.vertVisFt.rawValue].toDouble ?? 0,
                               metarType: metar[MetarField.metarType.rawValue] ?? "",
                               elevationM: metar[MetarField.elevationM.rawValue].toDouble ?? 0)
                metars.append(wx)
            }
        }
    }
    
    fileprivate func metarField(_ mf: MetarField) -> String {
        return mf.rawValue
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
        currentMetar = nil
        results = nil
    }
}
