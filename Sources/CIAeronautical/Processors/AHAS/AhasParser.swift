// ********************** AhasParser *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AhasParser *********************************


import Foundation

public class AhasParser: NSObject, XMLParserDelegate {
    private let ahasKeys = AhasField.allCases.map { $0.rawValue }
    private var results: [[String:String]]?
    private var currentAhas: [String:String]?
    private var currentValue: String?
    var ahas: [Ahas] = []
    var currTableInt = 0
    
    convenience init(data: Data) {
        self.init()
        let parser = XMLParser(data: data)
        parser.delegate = self
        _ = parser.parse()
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        results = []
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Table\(currTableInt == 0 ? "" : "\(currTableInt)")" {
            currentAhas = [:]
        } else if ahasKeys.contains(elementName) {
            currentValue = ""
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Table\(currTableInt == 0 ? "" : "\(currTableInt)")" {
            results!.append(currentAhas!)
            currTableInt += 1
            currentAhas = nil
        } else if ahasKeys.contains(elementName) {
            currentAhas![elementName] = currentValue
            currentValue = nil
        }
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        if let resultAhas = results {
            for ahas in resultAhas {
                
                // try .ahas12Hr DateFormat first
                var ahasDateTime = ahas[AhasField.dateTime.rawValue].getDateFrom(ofType: .ahas12Hr)
                
                // if ahasDateTime is nil (couldn't decode using .ahas12Hr DateFormat), try .ahas instead
                if ahasDateTime == nil {
                    ahasDateTime = ahas[AhasField.dateTime.rawValue].getDateFrom(ofType: .ahas)
                }
                
                let bird = Ahas(route: ahas[AhasField.route.rawValue],
                                segment: ahas[AhasField.segment.rawValue],
                                hour: ahas[AhasField.hour.rawValue],
                                dateTime: ahasDateTime,
                                nextRadRisk: ahas[AhasField.nextRadRisk.rawValue],
                                soarRisk: ahas[AhasField.soarRisk.rawValue],
                                ahasRisk: ahas[AhasField.ahasRisk.rawValue]?.uppercased(),
                                basedOn: ahas[AhasField.basedOn.rawValue],
                                tiDepth: ahas[AhasField.tiDepth.rawValue],
                                alt1: ahas[AhasField.alt1.rawValue],
                                alt2: ahas[AhasField.alt2.rawValue],
                                alt3: ahas[AhasField.alt3.rawValue],
                                alt4: ahas[AhasField.alt4.rawValue],
                                alt5: ahas[AhasField.alt5.rawValue])
                self.ahas.append(bird)
            }}}
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
        currentValue = nil
        currentAhas = nil
        results = nil
    }
    
}
