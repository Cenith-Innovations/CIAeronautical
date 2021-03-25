// ********************** MetarParser *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** MetarParser *********************************


import Foundation
import CIFoundation

/// Class to download and process METARs
public class MetarParser: NSObject, XMLParserDelegate {
    private let metar = MetarField.metarMain.rawValue
    private let metarKeys = MetarField.allCases.map { $0.rawValue }
    private var results: [[String: String]]?
    private var currentMetar: [String: String]?
    private var currentValue: String?
    var metars: [Metar] = []
    
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
        if elementName == metar {
            currentMetar = [:]
            skyConditions = []
        } else if metarKeys.contains(elementName) {
            if elementName == metarField(.skyCondition) {
                skyConditions.append(SkyCondition(skyCover: attributeDict[skyConditionField(.skyCover)],
                                                  cloudBaseFtAgl: attributeDict[skyConditionField(.cloudBaseFtAGL)].toDouble))
            }
            currentValue = ""
    }}
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    var skyConditions: [SkyCondition?] = []
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == metar {
            results!.append(currentMetar!)
            currentMetar = nil
        } else if metarKeys.contains(elementName) {
            currentMetar![elementName] = currentValue
            currentValue = nil
    }}
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        if let resultMetars = results {
            for metar in resultMetars {
                let wx = Metar(rawText: metar[MetarField.rawText.rawValue],
                               stationId: metar[MetarField.stationId.rawValue],
                               observationTime: metar[MetarField.observationTime.rawValue].metarTafStringToDate,
                               latitude: metar[MetarField.latitude.rawValue].toDouble,
                               longitude: metar[MetarField.longitude.rawValue].toDouble,
                               tempC: metar[MetarField.tempC.rawValue].toDouble,
                               dewPointC: metar[MetarField.dewPointC.rawValue].toDouble,
                               windDirDegrees: metar[MetarField.windDirDegrees.rawValue].toDouble,
                               windSpeedKts: metar[MetarField.windSpeedKts.rawValue].toDouble,
                               windGustKts: metar[MetarField.windGustKts.rawValue].toDouble,
                               visibilityStatuteMiles: metar[MetarField.visibilityStatuteMiles.rawValue].toDouble,
                               altimeterInHg: metar[MetarField.altimeterInHg.rawValue].toDouble,
                               seaLevelPressureMb: metar[MetarField.seaLevelPressureMb.rawValue].toDouble,
                               qualityControlFlags: metar[MetarField.qualityControlFlags.rawValue],
                               wxString: metar[MetarField.wxString.rawValue],
                               skyCondition: skyConditions,
                               flightCategory: metar[MetarField.flightCategory.rawValue],
                               threeHrPressureTendencyMb: metar[MetarField.threeHrPressureTendencyMb.rawValue],
                               maxTempPastSixHoursC: metar[MetarField.maxTempPastSixHoursC.rawValue].toDouble,
                               minTempPastSixHoursC: metar[MetarField.minTempPastSixHoursC.rawValue].toDouble,
                               maxTemp24HrC: metar[MetarField.maxTemp24HrC.rawValue].toDouble,
                               minTemp24HrC: metar[MetarField.minTemp24HrC.rawValue].toDouble,
                               precipIn: metar[MetarField.precipIn.rawValue].toDouble,
                               precipLast3HoursIn: metar[MetarField.precipLast3HoursIn.rawValue].toDouble,
                               precipLast6HoursIn: metar[MetarField.precipLast6HoursIn.rawValue].toDouble,
                               precipLast24HoursIn: metar[MetarField.precipLast24HoursIn.rawValue].toDouble,
                               snowIn: metar[MetarField.snowIn.rawValue].toDouble,
                               vertVisFt: metar[MetarField.vertVisFt.rawValue].toDouble,
                               metarType: metar[MetarField.metarType.rawValue],
                               elevationM: metar[MetarField.elevationM.rawValue].toDouble)
                metars.append(wx)
    }}}
    
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
