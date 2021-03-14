// ********************** MetarParser *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** MetarParser *********************************


import Foundation

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
        let str = String(data: data, encoding: .utf8)
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
                skyConditions.append(SkyCondition(skyCover: attributeDict[metarField(.skyCover)],
                                                  cloudBaseFtAgl: attributeDict[metarField(.cloudBaseFtAGL)]))
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
                               observationTime: metar[MetarField.observationTime.rawValue],
                               latitude: metar[MetarField.latitude.rawValue],
                               longitude: metar[MetarField.longitude.rawValue],
                               tempC: metar[MetarField.tempC.rawValue],
                               dewPointC: metar[MetarField.dewPointC.rawValue],
                               windDirDegrees: metar[MetarField.windDirDegrees.rawValue],
                               windSpeedKts: metar[MetarField.windSpeedKts.rawValue],
                               windGustKts: metar[MetarField.windGustKts.rawValue],
                               visibilityStatuteMiles: metar[MetarField.visibilityStatuteMiles.rawValue],
                               altimeterInHg: metar[MetarField.altimeterInHg.rawValue],
                               seaLevelPressureMb: metar[MetarField.seaLevelPressureMb.rawValue],
                               qualityControlFlags: metar[MetarField.qualityControlFlags.rawValue],
                               wxString: metar[MetarField.wxString.rawValue],
                               skyCondition: skyConditions,
                               flightCategory: metar[MetarField.flightCategory.rawValue],
                               threeHrPressureTendencyMb: metar[MetarField.threeHrPressureTendencyMb.rawValue],
                               maxTempPastSixHoursC: metar[MetarField.maxTempPastSixHoursC.rawValue],
                               minTempPastSixHoursC: metar[MetarField.minTempPastSixHoursC.rawValue],
                               maxTemp24HrC: metar[MetarField.maxTemp24HrC.rawValue],
                               minTemp24HrC: metar[MetarField.minTemp24HrC.rawValue],
                               precipIn: metar[MetarField.precipIn.rawValue],
                               precipLast3HoursIn: metar[MetarField.precipLast3HoursIn.rawValue],
                               precipLast6HoursIn: metar[MetarField.precipLast6HoursIn.rawValue],
                               precipLast24HoursIn: metar[MetarField.precipLast24HoursIn.rawValue],
                               snowIn: metar[MetarField.snowIn.rawValue],
                               vertVisFt: metar[MetarField.vertVisFt.rawValue],
                               metarType: metar[MetarField.metarType.rawValue],
                               elevationM: metar[MetarField.elevationM.rawValue])
                print(wx.observationTime)
                metars.append(wx)
    }}}
    
    fileprivate func metarField(_ mf: MetarField) -> String {
        return mf.rawValue
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
        currentValue = nil
        currentMetar = nil
        results = nil
    }
}
