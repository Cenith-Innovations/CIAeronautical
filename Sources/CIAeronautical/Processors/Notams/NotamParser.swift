// ********************** NotamParser *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/17/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** NotamParser *********************************


import Foundation

public typealias NotamList = [String: [String]]

/// Classy way to parse the NOTAMs after they've been fetched.
public class NotamParser {
    
    private var htmlData: String
    private var rawNotamData: [String] = []
    private var rawNotamStation: [String] = []
    public var notams: NotamList = [:]
    
    public init(htmlData: String) {
        self.htmlData = htmlData
        parseNotams()
    }
    
    private var numberOfNotams: Int {
        let notamNumberString = "Number of NOTAMs:"
        guard let startIndex = self.htmlData.range(of: notamNumberString) else {
            print("Unable to find count of NOTAMs retrieved; Bad start index")
            return 0
        }
        let endOfReportString = "End of Report"
        guard let endIndex = self.htmlData.range(of: endOfReportString) else {
            print("Unable to find count of NOTAMs retrieved; Bad end index")
            return 0
        }
        
        var parsable = String(self.htmlData[startIndex.upperBound..<endIndex.lowerBound])
        parsable = parsable.replacingOccurrences(of: "&nbsp;", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let number = Int(parsable) else {
            print ("Unable to parse the number from the text")
            return 0
        }
        return number
    }
    
    private func parseNotams() {
        let totalNotams = numberOfNotams
        //This will wipe the data and allow us to insert into any position without an array error
        rawNotamData = (0..<totalNotams).map { _ in return ""}
        rawNotamStation = (0..<totalNotams).map { _ in return ""}
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.global(qos: .default).async {
            self.fillInRawStations()
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        DispatchQueue.global(qos: .default).async {
            self.fillInRawNotams()
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        
        var prevStation = ""
        var notamArray: [String] = []
        notams = [:]
        for i in 0..<rawNotamStation.count {
            if prevStation == "" { prevStation = rawNotamStation[i] }
            if rawNotamStation[i] != prevStation {
                var copyOfNotams: [String] = []
                copyOfNotams.append(contentsOf: notamArray)
                notams[prevStation] = copyOfNotams
                notamArray = []
                prevStation = rawNotamStation[i]
            }
            
            notamArray.append(rawNotamData[i])
        }
        notams[prevStation] = notamArray
    }
    
    private func fillInRawNotams() {
        let dataIndexes = htmlData.ranges(of: "<PRE>")
        print("Notams found: \(dataIndexes.count)")
        var count = 0
        for index in dataIndexes {
            let substring = htmlData[index.upperBound...]
            let endString = "</PRE>"
            guard let endIndex = substring.range(of: endString) else {
                print("Unable to find closing tag")
                count += 1
                continue
            }
            let notam = String(substring[index.upperBound..<endIndex.lowerBound])
            rawNotamData[count] = notam
            count += 1
        }
    }
    
    private func fillInRawStations() {
        let stationIndexes = htmlData.ranges(of: "notamSelect")
        var count = 0
        for index in stationIndexes {
            let substring = htmlData[index.upperBound...]
            let idString = "id=\""
            guard let startIndex = substring.range(of: idString) else {
                print("Start pattern did not match")
                count += 1
                continue
            }
            let endString = "\">"
            guard let endIndex = substring.range(of: endString) else {
                print("End pattern did not match")
                count += 1
                continue
            }
            let station = String(substring[startIndex.upperBound..<endIndex.lowerBound])
            rawNotamStation[count] = station
            count += 1
        }
    }
}

