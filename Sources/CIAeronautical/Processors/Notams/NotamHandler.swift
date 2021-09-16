// ********************** NotamHandler *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/17/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** NotamHandler *********************************


import Foundation

/// A structured way to handle NOTAMs
public struct NotamHandler {
    public static func removeNewLinesAndSpaces(notam: String) -> String {
        return notam.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
    }
    
    ///Returns list of closed runways from an array of notams
    public static func getIDFrom(_ notam: String) -> String? {
        let n = removeNewLinesAndSpaces(notam: notam)
        
        let regex = #"([A-Z]{1}[0-9]{4}/[0-9]{2})"#
        if let range = n.range(of: regex, options: .regularExpression, range: nil, locale: nil) {
            let startIndex = n.index(range.lowerBound, offsetBy: 0)
            let endIndex = n.index(range.upperBound, offsetBy: 0)
            return String(n[startIndex..<endIndex])
        }
        return nil
    }
    
    ///Returns list of All closed runways from an array of notams
    public static func getAllClosedRunways(notam: String) -> [String] {
        var runways: [String] = []
        var n = removeNewLinesAndSpaces(notam: notam)
        
        if let twyStart = n.range(of: "TWY")?.upperBound {
            if let clsdEnd = n.range(of: "CLSD")?.lowerBound{
                if twyStart <= clsdEnd {
                    let range = twyStart...clsdEnd
                    n.removeSubrange(range)
                }
            }
        }
        
        if let startIndex = n.range(of: "RWY")?.upperBound {
            if let endIndex = n.range(of: "CLSD")?.lowerBound {
                let closedRunway = n[startIndex..<endIndex]
                let runway = String(closedRunway).components(separatedBy: "/")
                
                for rwy in runway {
                    runways.append(rwy)
                }
            }
        }
        
        var closedRwys: [String] = []
        for runway in runways {
            closedRwys.append(runway)
        }
        return closedRwys
    }
    
    public static func getRVRoutOfServiceForRWYs(notam: String) -> String? {
        let n = removeNewLinesAndSpaces(notam: notam)
        guard let rvrRange = n.range(of: "RVROUTOFSERVICE") else { return nil }
        let startIndex = n.index(rvrRange.lowerBound, offsetBy: -3)
        let endIndex = rvrRange.lowerBound
        return String(n[startIndex..<endIndex])
    }
    
    public static func getSetOfRVRoutOfServiceForRWYs(notam: String) -> Set<String> {
        var rvr: [String] = []
        let n = removeNewLinesAndSpaces(notam: notam)
        guard let rvrRange = n.range(of: "RVROUTOFSERVICE") else { return Set(rvr) }
        let startIndex = n.index(rvrRange.lowerBound, offsetBy: -3)
        let endIndex = rvrRange.lowerBound
        rvr.append(String(n[startIndex..<endIndex]))
        return Set(rvr)
    }
    
    ///Returns list of closed runways from an array of notams
    public static func getStartandEndTimes(notam: String) -> (start: String, end: String) {
        var start = ""
        var end = ""
        let n = removeNewLinesAndSpaces(notam: notam)
        if let center = n.range(of: "UNTIL") {
            //Start:
            let sEndIndex = center.lowerBound
            let sStartIndex = n.index(sEndIndex, offsetBy: -14)
            start = String(n[sStartIndex..<sEndIndex])
            let eStartIndex = center.upperBound
            let eEndIndex = n.index(eStartIndex, offsetBy: 14)
            end = String(n[eStartIndex..<eEndIndex])
        }
        return (start: start, end: end)
    }
    
    ///Returns Created Date
    public static func getCreationDate(notam: String) -> Date? {
        let n = removeNewLinesAndSpaces(notam: notam)
        guard let creationRange = n.range(of: "CREATED:") else { return nil }
        let startIndex = n.index(creationRange.upperBound, offsetBy: 0)
        let endIndex = n.endIndex
        let created = String(n[startIndex..<endIndex])
        return created.getDateFrom(ofType: .notam)
    }
    
    ///Returns list of closed runways from an array of notams
    public static func getRXClosedRwysFrom(notam: String) -> Set<String>? {
        let n = removeNewLinesAndSpaces(notam: notam)
        let regex = #"(RWY[0-9A-Z]{3}/[0-9A-Z]{3}CLSD)"#
        if let range = n.range(of: regex, options: .regularExpression, range: nil, locale: nil) {
            let startIndex = n.index(range.lowerBound, offsetBy: 3)
            let endIndex = n.index(range.upperBound, offsetBy: -4)
            return Set(String(n[startIndex..<endIndex]).components(separatedBy: "/"))
        }
        return nil
    }
    
    ///Returns an array of Notam Creation numbers
    public static func getRXNotamNumber(notam: String) -> Set<String>? {
        let n = removeNewLinesAndSpaces(notam: notam)
        let regex = #"(([A-Z][0-9]{4}/[0-9]{2}))"#
        if let range = n.range(of: regex, options: .regularExpression, range: nil, locale: nil) {
            let startIndex = n.index(range.lowerBound, offsetBy: 0)
            let endIndex = n.index(range.upperBound, offsetBy: 0)
            print(String(n[startIndex..<endIndex]).components(separatedBy: "/"))
            return Set(String(n[startIndex..<endIndex]).components(separatedBy: "/"))
        }
        return nil
    }
    
    ///Returns start end dates for notams
    public static func getRXStartandEndTimes(notam: String) -> (start: Date?, end: Date?) {
        let n = removeNewLinesAndSpaces(notam: notam)
        let regex = #"(.{13}UNTIL.{13})"#
        if let range = n.range(of: regex, options: .regularExpression, range: nil, locale: nil) {
            let startIndex = n.index(range.lowerBound, offsetBy: 0)
            let endIndex = n.index(range.upperBound, offsetBy: 0)
            let times = (String(n[startIndex..<endIndex]).components(separatedBy: "UNTIL"))
            let start = removeNewLinesAndSpaces(notam: times[0])
            let end = removeNewLinesAndSpaces(notam: times[1])
            return (start: start.getDateFrom(ofType: .notam), end: end.getDateFrom(ofType: .notam))
        }
        return (start: nil, end: nil)
    }
    
    ///Returns RWY ID's for notamed wet RWY
    public static func getRXWetRwy(notam: String) -> String? {
        let n = removeNewLinesAndSpaces(notam: notam)
        let regexWET = #"(RWY.{1,}FICON.{1,}WET)"#
        let regexRWY = #"(RWY.{1,}FICON)"#
        if let _ = n.range(of: regexWET, options: .regularExpression, range: nil, locale: nil) {
            if let rangeRWY = n.range(of: regexRWY, options: .regularExpression, range: nil, locale: nil) {
                let startIndex = n.index(rangeRWY.lowerBound, offsetBy: 3)
                let endIndex = n.index(rangeRWY.upperBound, offsetBy: -5)
                return String(n[startIndex..<endIndex])
            }
        }
        return nil
    }
    
    ///Returns RWY ID's for notamed wet RWY
    public static func getRXWetRunways(notam: String) -> [String] {
        let n = removeNewLinesAndSpaces(notam: notam)
        let regexRWY_ = #"(RWY.*WET)"#
        if let _ = n.range(of: regexRWY_, options: .regularExpression, range: nil, locale: nil) {
            let a = n.components(separatedBy: "WET")
            let b = a[0].components(separatedBy: "RWY")
            let c = b[1].components(separatedBy: "/")
            let d = c.filter({$0.count <= 3 })
            return d
        }
        return []
    }
    
    public static func getWetRwys1(from notam: String) -> String? {
        let n = removeNewLinesAndSpaces(notam: notam)
        let regex = "WET"
        let pred = NSPredicate(format: "SELF CONTAINS %@", regex)
        
        if pred.evaluate(with: notam) {
            let regexRWY = #"(RWY.{1,}FICON)"#
            if let rangeRWY = n.range(of: regexRWY, options: .regularExpression, range: nil, locale: nil) {
                let startIndex = n.index(rangeRWY.lowerBound, offsetBy: 3)
                let endIndex = n.index(rangeRWY.upperBound, offsetBy: -5)
                return String(n[startIndex..<endIndex])
            }
        }
        return nil
    }
}
