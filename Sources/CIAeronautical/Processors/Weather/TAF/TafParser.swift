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
    private var results: [[String: String]]?
    private var currentTaf: [String: String]?
    private var currentValue: String?
    var tafs: [Taf] = []
    
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
        } else if tafKeys.contains(elementName) {
            currentValue = ""
        }}
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == taf {
            results!.append(currentTaf!)
            currentTaf = nil
        } else if tafKeys.contains(elementName) {
            currentTaf![elementName] = currentValue
            currentValue = nil
        }}
    
    public func parserDidEndDocument(_ parser: XMLParser) {
    if let resultTafs = results {
        for taf in resultTafs {
            let wx = Taf(rawText: taf[tafField(.rawText)],
                         stationId: taf[tafField(.stationId)],
                         issueTime: taf[tafField(.issueTime)],
                         bulletinTime: taf[tafField(.bulletinTime)],
                         validTimeFrom: taf[tafField(.validTimeFrom)],
                         validTimeTo: taf[tafField(.validTimeTo)],
                         remarks: taf[tafField(.remarks)],
                         latitude: taf[tafField(.latitude)],
                         longitude: taf[tafField(.longitude)],
                         elevationM: taf[tafField(.elevationM)],
                         forecast: taf[tafField(.forecast)],
                         timeFrom: taf[tafField(.timeFrom)],
                         timeTo: taf[tafField(.timeTo)],
                         changeIndicator: taf[tafField(.changeIndicator)],
                         timeBecoming: taf[tafField(.timeBecoming)],
                         probability: taf[tafField(.probability)],
                         windDirDegrees: taf[tafField(.windDirDegrees)],
                         windSpeedKts: taf[tafField(.windSpeedKts)],
                         windGustKts: taf[tafField(.windGustKts)],
                         windShearHeightAboveGroundFt: taf[tafField(.windShearHeightAboveGroundFt)],
                         windShearDirDegrees: taf[tafField(.windShearDirDegrees)],
                         windShearSpeedKts: taf[tafField(.windShearSpeedKts)],
                         visibilityStatuteMiles: taf[tafField(.visibilityStatuteMiles)],
                         altimeterInHg: taf[tafField(.altimeterInHg)],
                         vertVisFt: taf[tafField(.vertVisFt)],
                         weatherString: taf[tafField(.weatherString)],
                         notDecoded: taf[tafField(.notDecoded)],
                         skyCondition: taf[tafField(.skyCondition)],
                         turbulenceCondition: taf[tafField(.turbulenceCondition)],
                         icingCondition: taf[tafField(.icingCondition)],
                         temperature: taf[tafField(.temperature)],
                         validTime: taf[tafField(.validTime)],
                         surfaceTempC: taf[tafField(.surfcaeTempC)],
                         maxTempC: taf[tafField(.maxTempC)],
                         minTempC: taf[tafField(.minTempC)])
            tafs.append(wx)
        }}}
    
    fileprivate func tafField(_ tf: TafField) -> String {
        return tf.rawValue
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
        currentValue = nil
        currentTaf = nil
        results = nil
    }
}
