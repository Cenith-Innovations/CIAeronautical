//
//  File.swift
//  
//
//  Created by Jorge Alvarez on 7/17/23.
//
import SwiftUI

public struct NotamFlag: Hashable {
    
    public enum FlagType: String {
        
        /// Red
        case aerodrome = "AERODROME"
        case closed = "RWY CLOSED"
        
        /// Blue
        case wet = "WET"
        
        /// Approach Flag
        case ils = "ILS"
        
        /// Approach Flag. This one shouldn't use rawValue for label. Should use NotamFlag.subTypeString? Can include GS/GP/DME/LOC
        case ilsSubType = ""
        
        /// Approach Flag. Has single space at beginning to make unique from other version
        case tacan = " TACAN"
        
        /// NAVAID Flag
        case vortac = "VORTAC"
        
        /// NAVAID Flag
        case tacanNav = "TACAN"
    }
    
    public let flagType: FlagType
    public let notamId: String?
    public let ident: String?
    public let subTypeString: String?
    /// We can read through this message to see if we have a timeframe / secondary date
    public let message: String?
    
    // MARK: - Computed Properties
    
    public var isFlagActive: Bool {
        // read through message (based on type?) and return bool
        switch flagType {
        case .aerodrome:
            return NotamFlag.isTimeFrameActive(message: message)
        case .closed, .ils, .ilsSubType, .tacan, .tacanNav, .vortac:
            return NotamFlag.closedForTimeFrame(message: message)
        default:
            return true
        }
    }
    
    // TODO: add secondaryDate property that's assigned when making flag?
    
    public var icon: (name: String, color: Color) {
        switch flagType {
            
        case .aerodrome:
            return ("a.square.fill", Color.red)
        case .closed:
            return ("xmark.octagon.fill", Color.red)
        case .wet:
            return ("drop.circle.fill", Color.blue)
        case .ils, .ilsSubType, .tacan, .vortac, .tacanNav:
            return ("exclamationmark.triangle.fill", Color.yellow)
        }
    }
    
    static public let closedWords = Set(["CLSD", "CLOSED", "CLSD.", "CLOSED."])
    static public let wetWords = Set(["WET", "WET."])
    
    /// Ex: "15/33". This is how runway names appear in NOTAMS
//    public var slashName: String? {
//        guard let low = lowIdent, let high = highIdent else { return nil }
//        return "\(low)/\(high)"
//    }
//
//    /// Ex: "15 - 33". This is how most runways names are displayed in app
//    public var dashName: String? {
//        guard let low = lowIdent, let high = highIdent else { return nil }
//        return "\(low) - \(high)"
//    }
    
    /// Takes in a Notam and returns an optional NotamFlag, even if not active. Returns an error type NotamFlag if any important pieces are missing
    static public func makeFlag(text: String?, notamId: String?, notamType: NOTAM.NotamType, facilityDesignator: String?) -> NotamFlag? {
            
        // TODO: return an ErrorFlag if we're missing any important pieces
        guard let message = text else { return nil }
        
        var flag: NotamFlag?
            
        let firstWords = Set(["AERODROME", "AERODOME", "RWY", "RUNWAY", "AD"])
        let aerodromeWords = Set(["AERODROME", "AERODOME", "AD"])
        let runwayWords =  Set(["RWY", "RUNWAY"])
        let outageWords = Set(["U/S", "U/S.", "OTS", "OTS,", "OTS.", "OUT", "UNSERVICEABLE", "UNSERVICEABLE."])
            
        // go through every word in notam and check for 3 words in sequence
        let notamsArray = Array(message.uppercased().replacingOccurrences(of: "\n", with: " ").split(separator: " "))
        
        var i = 0
        let count = notamsArray.count
        
        while i < count {
            
            let curr = "\(notamsArray[i])"
            
            // Main words to check: AERODROME OR RWY/RUNWAY for closures and wet runways. ILS OR TACAN/VORTAC
            
            // 1. AERODROME, RWY, or RUNWAY
            if firstWords.contains(curr) {
                
                // AERODROME
                if aerodromeWords.contains(curr) && i + 1 < count {
                    let next = "\(notamsArray[i+1])"
                    if closedWords.contains(next) {
                        // Aerodrome Flag
                        let flagToAdd = NotamFlag(flagType: .aerodrome, notamId: notamId, ident: nil, subTypeString: nil, message: message)
                        flag = flagToAdd
                    }
                    
                    else if i + 2 < count {
                        let wordAfterNext = "\(notamsArray[i+2])"
                        if closedWords.contains(wordAfterNext) {
                            // Aerodrome Flag
                            let flagToAdd = NotamFlag(flagType: .aerodrome, notamId: notamId, ident: nil, subTypeString: nil, message: message)
                            flag = flagToAdd
                        }
                    }
                }
                
                // RUNWAY or RWY keywords
                if runwayWords.contains(curr) && i + 2 < count {
                    
                    let secondWord = "\(notamsArray[i+1])"
                    let thirdWord = "\(notamsArray[i+2])"
                    
                    if isRunwayClosed(second: secondWord, third: thirdWord, message: message, notamType: notamType) {
                        // only add notams that are NOT a taxiway type and are active
                        let runwayName = getRunwayEnds(text: secondWord)
                        
                        // flag ident is either whole or single depending on which one is nil
                        var ident = runwayName.single
                        if let wholeName = runwayName.whole { ident = wholeName }
                        
                        let flagToAdd = NotamFlag(flagType: .closed, notamId: notamId, ident: ident, subTypeString: nil, message: message)
                        // TODO: instead of a mixed array of NotamFlags, use Flags struct instead?
                        flag = flagToAdd
                    }
                    
                    // Wet Flag
                    else if isRunwayWet(message: message, notamType: notamType) {
                        let runwayName = getRunwayEnds(text: secondWord)
                        var ident = runwayName.single
                        if let wholeName = runwayName.whole { ident = wholeName }
                        let flagToAdd = NotamFlag(flagType: .wet, notamId: notamId, ident: ident, subTypeString: nil, message: message)
                        flag = flagToAdd
                    }
                }
            }
            
            // 2. Approach and Nav flags words
            if curr == "ILS" && i + 3 < count {
                
                // should be RWY or RUNWAY
                let secondWord = "\(notamsArray[i+1])"
                // should be ident
                let thirdWord = "\(notamsArray[i+2])"
                // should be U/S or type of ILS outage (LOC/GS/DME)
                let fourthWord = "\(notamsArray[i+3])"
                
                if runwayWords.contains(secondWord) {
                    if outageWords.contains(fourthWord) {
                        // ILS
                        let flagToAdd = NotamFlag(flagType: .ils, notamId: notamId, ident: thirdWord, subTypeString: nil, message: message)
                        flag = flagToAdd
                    }
                    
                    // try getting next word if possible (now it should be outage word or nothing)
                    else if i + 4 < count {
                        let fifthWord = "\(notamsArray[1+4])"
                        if outageWords.contains(fifthWord) {
                            // ILS SUBTYPE (LOC/GS/DME)
                            let flagToAdd = NotamFlag(flagType: .ilsSubType, notamId: notamId, ident: thirdWord, subTypeString: fourthWord, message: message)
                            flag = flagToAdd
                        }
                    }
                }
                
                // Needs ILS keyword then RWY or RUNWAY, then ident then if next is multi or none its ILS.
                // "ILS RWY XX U/S"
                // ILS RWY XX GS U/S
                // ILS RWY XX LOC U/S
                // ILS RWY XX LOC/GP/DME U/S
                
            }
            
            // TACAN RWY XX U/S
            if curr == "TACAN" && i + 1 < count {
                // could be U/S or RWY
                let secondWord = "\(notamsArray[i+1])"
                if outageWords.contains(secondWord) && notamType != .procedure {
                    // TACAN (Nav version)
                    let flagToAdd = NotamFlag(flagType: .tacanNav, notamId: notamId, ident: facilityDesignator, subTypeString: nil, message: message)
                    flag = flagToAdd
                }
                
                // if nav but has subtype (AZM or DME)
                else if i + 2 < count {
                    let subTypeWord = "\(notamsArray[i+1])"
                    let outageWord = "\(notamsArray[i+2])"
                    
                    if outageWords.contains(outageWord) && notamType != .procedure {
                        // TACAN (Nav version)
                        let flagToAdd = NotamFlag(flagType: .tacanNav, notamId: notamId, ident: facilityDesignator, subTypeString: subTypeWord, message: message)
                        flag = flagToAdd
                    }
                }
                
                // TACAN (Approach version)
                else if i + 3 < count && runwayWords.contains(secondWord) {
                    // should be ident
                    let thirdWord = "\(notamsArray[i+2])"
                    // should U/S
                    let fourthWord = "\(notamsArray[i+3])"
                    if outageWords.contains(fourthWord) {
                        let flagToAdd = NotamFlag(flagType: .tacan, notamId: notamId, ident: thirdWord, subTypeString: nil, message: message)
                        flag = flagToAdd
                    }
                }
            }
            
            // Nav
            // VORTAC U/S
            if curr == "VORTAC" && i + 1 < count {
                // could be U/S
                let secondWord = "\(notamsArray[i+1])"
                if outageWords.contains(secondWord) && notamType != .procedure {
                    let flagToAdd = NotamFlag(flagType: .vortac, notamId: notamId, ident: facilityDesignator, subTypeString: nil, message: message)
                    flag = flagToAdd
                }
                
                else if i + 2 < count {
                    let wordAfterNext = "\(notamsArray[i+2])"
                    if outageWords.contains(wordAfterNext) && notamType != .procedure {
                        let flagToAdd = NotamFlag(flagType: .vortac, notamId: notamId, ident: facilityDesignator, subTypeString: nil, message: message)
                        flag = flagToAdd
                    }
                }
            }
            
            i += 1
        }
                
        return flag
    }
    
    static public func isRunwayWet(message: String, notamType: NOTAM.NotamType) -> Bool {
        
        // TODO: check if we find wetWords anywhere after RWY XX (Ex: RWY 15 RSC WET WITH ..., RWY 15 FICON BLAH BLAH WET)
        if notamType != .taxiway {
            let notamsArray = Array(message.uppercased().split(separator: " "))
            for word in notamsArray {
                if wetWords.contains("\(word)") { return true }
            }
        }
        
        return false
    }

    static public func isRunwayClosed(second: String, third: String, message: String, notamType: NOTAM.NotamType) -> Bool {
        
        // check that third word is closed
        if second.contains("/") {
            if closedWords.contains(third) && notamType != .taxiway {
                return true
            }
        }
        
        return false
    }
    
    /// Checks passed in word to see if it can be a number between 1-31. First strips it of any non number characters
    public static func hasDayInt(word: String) -> Int? {
                
        // strip off non num characters
        let result = word.filter("0123456789".contains)
        
        // make into an Int if possible
        if let dayInt = Int(result), 1...31 ~= dayInt {
            return dayInt
        }
        
        return nil
    }
    
    /// Tries to return hour and minutes for a passed in String. Returns nil if word contains "L" or if we can't make into pair of Ints. Ex: "1400Z)." -> (hour: 14, mins: 0)"
    public static func hasZuluHourMins(word: String) -> (hour: Int, mins: Int)? {
        
        // Ignore "L" hours/mins since we can't really use local time, zulu only
        guard word.contains("Z") else { return nil }
        
        // strip of non num characters
        let result = word.filter("0123456789".contains)
        
        // check if count == 4
        // first 2 chars and last 2 chars should both be made into Ints
        let charsArray = Array(result)
        if charsArray.count == 4, let hours = Int("\(charsArray[0])\(charsArray[1])"), let mins = Int("\(charsArray[2])\(charsArray[3])") {
            return (hours, mins)
        }
        
        return nil
    }
    
    public static func possibleYearComp(word: String) -> Int? {
        
        // strip of non num characters
        let result = word.filter("0123456789".contains)
        
        // check if count == 4
        // first 2 chars should be made into Int
        let charsArray = Array(result)
        if charsArray.count == 4, let century = Int("\(charsArray[0])\(charsArray[1])"), century == 20, let year = Int(String(charsArray)) {
            return year
        }
        
        return nil
    }
    
    /// Takes in a String that could be hour/mins word with "Z" or "L" at the end. Returns hour and mins or nil if we can't make into those components
    public static func hourMinsWithTimezone(word: String) -> (hour: Int, mins: Int)? {
        
        // make sure we have a "Z" or "L"
        guard word.contains("Z") || word.contains("L") else { return nil }
        
        // strip off non num characters
        let result = word.filter("0123456789".contains)
        
        let charsArray = Array(result)
        
        // check if count == 4
        // first 2 chars and last 2 chars should both be made into Ints
        if charsArray.count == 4, let hour = Int("\(charsArray[0])\(charsArray[1])"), let mins = Int("\(charsArray[2])\(charsArray[3])") {
        
            // make sure we have valid hour and mins
            if 0..<24 ~= hour && 0..<60 ~= mins {
                return (hour, mins)
            }
        }
        
        return nil
    }
    
    // TODO: make function that just takes in the 3-4 components and returns Date?
    public static func dateFromTimeFrameComps(dayInt: Int, monthInt: Int, hour: Int, mins: Int, currDate: Date) -> Date? {
    
        // check if hourMins is in Zulu or Local
        
        // make sure year is 4 digits when stripped and that first 2 chars are "20" (ex: 2023)
        
            let timezone = TimeZone(abbreviation: "UTC")!
            let cal = Calendar.current
            if let nextDateYear = Calendar.current.dateComponents([.year], from: currDate).year {
                let newDate = Calendar.current.date(from: DateComponents(calendar: cal,
                                                                         timeZone: timezone,
                                                                         year: nextDateYear,
                                                                         month: monthInt,
                                                                         day: dayInt,
                                                                         hour: hour,
                                                                         minute: mins))
                return newDate
            }
        
        
        return nil
    }
    
    /// Looks for a timeframe inside passed in message and only returns true if both Dates are valid and if current Date is within that range. Date entered is current date by default
    public static func isSingleDateTimeFrameActive(message: String?, expirationDate: Date, currDate: Date = Date()) -> Bool {
        
        // TODO: look for first valid date to use as the start time
        
        // 1. Day
        // 2. Month,
        // 3. Year OR hours/mins (look for 5th char for hours/mins and "20" for first 2 chars for year). Also remove non alpha-nums
        // 4. Check local timezone that's passed in
        
        guard let message = message else { return false }
                
        let words = Array(message.split(separator: " "))
        let count = words.count
        var i = 0
        var startDate: Date?
        
        var foundTimeframe = false
        
        let monthDict = ["JAN": 1, "JANUARY": 1,
                         "FEB": 2, "FEBRUARY": 2,
                         "MAR": 3, "MARCH": 3,
                         "APR": 4, "APRIL": 4,
                         "MAY": 5,
                         "JUN": 6, "JUNE": 6,
                         "JUL": 7, "JULY": 7,
                         "AUG": 8, "AUGUST": 8,
                         "SEP": 9, "SEPTEMBER": 9,
                         "OCT": 10, "OCTOBER": 10,
                         "NOV": 11, "NOVEMBER": 11,
                         "DEC": 12, "DECEMBER": 12]
        
        while i < count {
            
            let word = String(words[i])
            
            // look for start of timeframe (should be day Int portion)
            if let day = hasDayInt(word: word), i + 2 < count {
                // now look for next word which should be a month (abbr or spelled out)
                let monthKeyword = String(words[i+1])
                let thirdKeyword = String(words[i+2])
                
                // TODO: if i+2 is year, check if we can look at next word. If not, try with just year and use 0000Z as default
                // TODO: if i+2 is hour/mins, try out all comps. Try next word anyway? use current year as default or use Calendar method to see?
                
                if let month = monthDict[monthKeyword] {
                    // TODO: once we know we have a valid Day keyword followed by a valid Month keyword, then we can look for more
                    // TODO: make sure we at least also have the year or hour/mins
                    // TODO: plug in these components into function that returns Date?
                    // TODO: still set foundTimeframe to true just in case??
                    foundTimeframe = true
                    
                    
                    // we have hour/mins
                    if let possibleHourMins = hourMinsWithTimezone(word: thirdKeyword) {
                        startDate = dateFromTimeFrameComps(dayInt: day,
                                                           monthInt: month,
                                                           hour: possibleHourMins.hour,
                                                           mins: possibleHourMins.mins,
                                                           currDate: Date())
                        break
                    }
                    
                    // we have year
                    else if let year = possibleYearComp(word: thirdKeyword) {
                        startDate = dateFromTimeFrameComps(dayInt: day,
                                                           monthInt: month,
                                                           hour: 0,
                                                           mins: 0,
                                                           currDate: Date())
                        break
                    }
                    
                }
                
            }
            
            i += 1
        }
                
        if foundTimeframe {
            if let start = startDate {
                let now = Date()
                if now >= start && now < expirationDate {
                    print("start: \(start) end: \(expirationDate)")
                    return true
                }
            }
            
            return false
        }
        
        return true
    }
    
    // TODO: replace this later with other aerodrome timeframe function
    /// Looks for a timeframe inside passed in message and only returns true if both Dates are valid and if current Date is within that range. Date entered is current date by default
    public static func isTimeFrameActive(message: String?, date: Date = Date()) -> Bool {
        
        guard let message = message else { return false }
                
        let words = Array(message.split(separator: " "))
        let count = words.count
        var i = 0
        var startDate: Date?
        var endDate: Date?
        var foundTimeframe = false
        
        let monthDict = ["JAN": 1, "JANUARY": 1,
                         "FEB": 2, "FEBRUARY": 2,
                         "MAR": 3, "MARCH": 3,
                         "APR": 4, "APRIL": 4,
                         "MAY": 5,
                         "JUN": 6, "JUNE": 6,
                         "JUL": 7, "JULY": 7,
                         "AUG": 8, "AUGUST": 8,
                         "SEP": 9, "SEPTEMBER": 9,
                         "OCT": 10, "OCTOBER": 10,
                         "NOV": 11, "NOVEMBER": 11,
                         "DEC": 12, "DECEMBER": 12]
        
        while i < count {
            
            let word = String(words[i])
            
            // look for start of timeframe (should be day Int portion)
            if let day = hasDayInt(word: word), i + 2 < count {
                // now look for next word which should be a month (abbr or spelled out)
                let monthKeyword = String(words[i+1])
                let hourMinKeyword = String(words[i+2])
                if let month = monthDict[monthKeyword] {
                    foundTimeframe = true
                    if let hoursMins = hasZuluHourMins(word: hourMinKeyword) {
                        let timezone = TimeZone(abbreviation: "UTC")!
                        let cal = Calendar.current
                        if let nextDateYear = Calendar.current.dateComponents([.year], from: date).year {
                            let newDate = Calendar.current.date(from: DateComponents(calendar: cal,
                                                                                     timeZone: timezone,
                                                                                     year: nextDateYear,
                                                                                     month: month,
                                                                                     day: day,
                                                                                     hour: hoursMins.hour,
                                                                                     minute: hoursMins.mins))
                            if startDate == nil {
                                startDate = newDate
                            } else {
                                endDate = newDate
                            }
                        }
                    }
                }
                
            }
            
            i += 1
        }
                
        if foundTimeframe {
            if let start = startDate, let end = endDate {
                let now = Date()
                if now >= start && now < end {
                    print("start: \(start) end: \(end)")
                    return true
                }
            }
            
            return false
        }
        
        return true
    }
    
    // TODO: make this potentially return nil so we can tell if there was an error reading possible timeframe?
    // TODO: new format to watch out for: "AERODROME CLSD 27 MAY @ 0530L - 30 MAY @ 0530L" ???
    /// Returns true if passed in NOTAM message contains timeframe keywords AND we're in the timeframe now. Also returns true if there's no timeframe at all (or if error). Date entered is current date by default
    public static func closedForTimeFrame(message: String?, date: Date = Date()) -> Bool {
        
        // TODO: go through scooping up each weekday keyword we find into an Array?
        // TODO: also check if current word has "/" in it so we can break that up and add to Array (if all keywords)
        
        // TODO: stop checking if hour strings are always directly after first weekday keyword
        // TODO: twoTimes String should have a "-" in middle AND start/end Strings should use hasZuluHoursMins
        
        // TODO: add daylight savings offset (if in daylight savings time)
        // TODO: what if the times are like 2300 - 0200 ?
        
        // TODO: notamComps doesn't have to be outside of loop scope?

        guard let word = message else { return true }
                
        let daysDictionary: [String: Set<Int>] = ["SUN": [1], "SUNDAY": [1],
                                                  "MON": [2], "MONDAY": [2],
                                                  "TUE": [3], "TUESDAY": [3],
                                                  "WED": [4], "WEDNESDAY": [4],
                                                  "THU": [5], "THURSDAY": [5],
                                                  "FRI": [6], "FRIDAY": [6],
                                                  "SAT": [7], "SATURDAY": [7],
                                                  "DLY": [1,2,3,4,5,6,7], "DAILY": [1,2,3,4,5,6,7],
                                                  "WKDAYS": [2,3,4,5,6], "WEEKDAYS": [2,3,4,5,6],
                                                  "WKEND": [1,7], "WEEKEND": [1,7]]
        
        let words = Array(word.split(separator: " "))
        var hasTimeFrame = false
        var closedAtThisTime = false
        var i = 0
        let wordsCount = words.count
        
        let timezone = Calendar.current.timeZone
        let secondsToAdd = -Double(timezone.secondsFromGMT())
        let notamComps = Calendar.current.dateComponents([.weekday, .hour, .minute],
                                                           from: date.addingTimeInterval(secondsToAdd))
        
        var weekdayInts = [Int]()
        var timeFrameWord = ""
        
        while i < wordsCount {
            let wordString = "\(words[i])"
            
            // check for multi-days separated by "/"
            if wordString.contains("/") {
                // TODO: split by "/" and see if we can add all substrings to list of days mentioned
                let multiWords = Array(wordString.split(separator: "/"))
                for word in multiWords {
                    if let weekdayKeywordInts = daysDictionary["\(word)"] {
                        print("found weekday: \(word)")
                        for keyword in weekdayKeywordInts {
                            weekdayInts.append(keyword)
                        }
                    }
                }
                
                // now check word directly after multi-day String with "/"
                if !weekdayInts.isEmpty, i + 1 < wordsCount {
                    hasTimeFrame = true
                    let foundDays = Set(weekdayInts)
                    let twoTimes = Array(words[i+1].split(separator: "-"))
                    
                    guard let notamWeekday = notamComps.weekday, let notamHourInt = notamComps.hour, let notamMinInt = notamComps.minute, let nowTimeframe = Int("\(notamHourInt)\(notamMinInt < 10 ? "0\(notamMinInt)" : "\(notamMinInt)")") else {
                        return false
                    }
                    
                    if foundDays.contains(notamWeekday), twoTimes.count == 2, let start = Int(twoTimes[0]), let end = Int(twoTimes[1]) {
                        if withinTimeFrame(start: start, end: end, now: nowTimeframe)  {
                            closedAtThisTime = true
                            return true
                        } else { break }
                    } else { break }
                }
            }
            
            // if we find keyword AND its weekday Ints match the current day's weekday Int
            if let weekdays = daysDictionary[wordString], i + 1 < wordsCount {
                hasTimeFrame = true
                var j = i + 1
                
                // add first weekday we find (could be the only one or the first of many)
                for weekdayInt in weekdays {
                    weekdayInts.append(weekdayInt)
                }
                
                print("found single weekday: \(weekdayInts)")
                while j < wordsCount {
                    print("started counting weekdays")
                    let currWord = String(words[j])
                    if let newDay = daysDictionary[currWord] {
                        print("newDay: \(newDay)")
                        for dayInt in newDay {
                            weekdayInts.append(dayInt)
                        }
                    } else {
                        print("j was: \(j) when breaking out")
                        print("weekdayInts: \(Set(weekdayInts))")
                        // j should be index of timeframe
                        timeFrameWord = currWord
                        break
                    }
                    
                    j += 1
                }
                
                let twoTimes = Array(timeFrameWord.split(separator: "-"))
                let foundDays = Set(weekdayInts)
                
                guard let notamWeekday = notamComps.weekday, let notamHourInt = notamComps.hour, let notamMinInt = notamComps.minute, let nowTimeframe = Int("\(notamHourInt)\(notamMinInt < 10 ? "0\(notamMinInt)" : "\(notamMinInt)")") else {
                    return false
                }
                
                if foundDays.contains(notamWeekday), twoTimes.count == 2, let start = Int(twoTimes[0]), let end = Int(twoTimes[1]) {
                    if withinTimeFrame(start: start, end: end, now: nowTimeframe) {
                        closedAtThisTime = true
                    } else { break }
                } else { break }
            }
            
            i += 1
        }
                
        if hasTimeFrame && closedAtThisTime {
            return true
        }
        
        if !hasTimeFrame {
            return true
        }
        
        return false
    }
    
    static public func withinTimeFrame(start: Int, end: Int, now: Int) -> Bool {
        
        // if start is MORE than end (2200-0900)
        if start > end {
            return now >= start || now <= end
        }
        
        // if start is LESS than end (0000-2359)
        else {
            return now >= start && now <= end
        }
    }
    
    static public func getRunwayEnds(text: String?) -> (whole: String?, single: String?) {
        
        guard let idents = text else { return (nil, nil) }
        
        let splitWord = idents.split(separator: "/")
        
        // whole runway
        if splitWord.count == 2 {
            return ("\(splitWord[0])/\(splitWord[1])", nil)
        }
        
        // single runway end
        else {
            return (nil, idents)
        }
    }
    
    /// Takes in an array of Notams and returns only the active flags by looking for active Notams with active flags.
    public static func  allActiveFlags(notams: [NOTAM]) -> [NotamFlag] {
        
        var flags = [NotamFlag]()
        
        for notam in notams {
            
            // Only look at active notams that also have flags
            guard let notamFlag = notam.flag else { continue }
            
            // Add up notams that are active and have active flags
            if notam.isNotamAndFlagActive { flags.append(notamFlag) }
        }
        
        return flags
    }
}
