// ********************** String+Extensions *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/17/20, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** String+Extensions *********************************


import Foundation

public extension String {
    
    func indices(of: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: of, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = of.distance(from: of.startIndex,
                                             to: of.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
    
    func ranges(of: String) -> [Range<String.Index>] {
        let _indices = indices(of: of)
        let count = of.count
        return _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }
    
    ///This translates Dates from various API's into Date()
    func getDateFrom(ofType: DateFormat) -> Date? {
        let df = DateFormatter()
        df.dateFormat = ofType.value
        df.timeZone = TimeZone(abbreviation: "UTC")
        switch ofType {
        case .reference:
            let refDate = "19700101000000"
            return df.date(from: refDate)
        default:
            return df.date(from: self)
    }}
    
    /// Turns Notam date Strings into a Date. Ex: "10/08/2022 1215" into Date. Also works if String ends in "EST"
    func notamDate() -> Date? {
        var str = self
        if str.contains("EST") { str = str.replacingOccurrences(of: "EST", with: "") }
        return DateFormatter.notamFaaDateFormatter.date(from: str)
    }
}
