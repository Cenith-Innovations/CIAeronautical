// ********************** StringOptional+Extensions *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** StringOptional+Extensions *********************************


import Foundation

public extension Optional where Wrapped == String {
    
    func removeAllCharOf(_ str: String) -> String? {
        let charR = Character(str)
        var returnCharecters: [Character] = []
        guard let selfStr = self else {return nil}
        for char in selfStr {
            if char != charR {
                returnCharecters.append(char)
            }}
        return String(returnCharecters)
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
            if let date = self {return df.date(from: date)}
        }
        return nil
    }
    
    /// Returns a Date in UTC
    var weatherStringToDate: Date? {
        guard let str = self else { return nil }
        return DateFormatter.weatherDateFormatter.date(from: str)
    }
}
