// ********************** Ahas *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Ahas *********************************


import Foundation

public enum AhasField: String, CaseIterable {
    case route = "Route"
    case segment = "Segment"
    case hour = "Hour"
    case dateTime = "DateTime"
    case nextRadRisk = "NEXRADRISK"
    case soarRisk = "SOARRISK"
    case ahasRisk = "AHASRISK"
    case basedOn = "BasedON"
    case tiDepth = "TIDepth"
    case alt1 = "Alt1"
    case alt2 = "Alt2"
    case alt3 = "Alt3"
    case alt4 = "Alt4"
    case alt5 = "Alt5"
}

public struct Ahas: Loopable, Hashable {
    public var route: String?
    public var segment: String?
    public var hour: String? //Z time
    public var dateTime: Date?
    public var nextRadRisk: String?
    public var soarRisk: String?
    public var ahasRisk: String?
    public var basedOn: String?
    public var tiDepth: String? //Height AGL on webPage
    public var alt1: String?
    public var alt2: String?
    public var alt3: String?
    public var alt4: String?
    public var alt5: String?
    public var dateFetched: Date
    
    /// 00, 06, 12, 18, 24, 30, 36, 42, 48, 54
    /// Returns if Ahas is old enough to need fetching again. Checks if we're inside same 6 minute interval or if dateFetched is older than 5 minutes
    public var needsRefresh: Bool {
        
        let diff = Date().timeIntervalSinceReferenceDate - dateFetched.timeIntervalSinceReferenceDate
        if diff < 120 {
            print("fetched ahas less than 2 mins ago")
            return false
        }
        print("its been longer than 2 minutes since \(route ?? "-") fetching ahas")
        
        return true
        // TODO: use dateTime minute and hour to know if we should refresh ahas
        guard let dateTime = dateTime else {
            // check dateFetched instead
            // TODO: change later
            return true
        }
        let cal = Calendar.current
        
        // Return true if:
        // 1. if dateFetched is more than 6 minutes old
        // 2. OR if currHour AND currMin aren't inside hour AND minute range we have (its 12:08 and we have 12:00 dateTime)
        
        // get hour and mins from each date
        let dateTimeComps = cal.dateComponents([.hour, .minute], from: dateTime)
        let dateHour = dateTimeComps.hour
        let dateMins = dateTimeComps.minute
        
        let currDateComps = cal.dateComponents([.hour, .minute], from: Date())
        let currHour = currDateComps.hour
        let currMins = currDateComps.minute
        
        // hours match
        if let dateHour = dateHour, let currHour = currHour, dateHour == currHour {
            
        }
        
        return false
    }
}
