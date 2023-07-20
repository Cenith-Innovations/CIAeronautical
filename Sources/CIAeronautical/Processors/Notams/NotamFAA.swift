//
//  NotamFAA.swift
//  
//
//  Created by Jorge Alvarez on 10/19/22.
//

import Foundation
import SwiftUI

public struct NotamsResponse: Decodable {
    public let startRecordCount: Int?
    public let endRecordCount: Int?
    public let totalNotamCount: Int?
    public let error: String?
    public let notamList: [NOTAM]?
}

public struct NOTAM: Decodable, Hashable {
    
    // MARK: - NotamType
    
    public enum NotamType: Int {
        case tfr// = "TFR"
        case runway// = "Runway"
        case obstacle// = "Obstacle"
        case taxiway// = "Taxiway"
        case airport// = "Airport"
        case procedure// = "Instrument Procedure"
        case airspace// = "Airspace"
        case birds// = "Birds"
        case unknown// = "Unknown"
        case none// = "None"
    }
    
    // MARK: - Properties
    
    public let facilityDesignator: String?
    public let icaoId: String?
    public let icaoMessage: String?
    public let traditionalMessage: String?
    public let featureName: String?
    public let notamNumber: String?
    
    public let issueDate: String?
    public let createdDate: Date?
    
    public let startDate: String?
    public let effectiveDate: Date?
    
    public let endDate: String?
    public let expirationDate: Date?
    
    public let message: String?
    public let comment: URL?
    
    public var cleanText: String?
    
    public let dateFetched = Date()
    
    public var type: NotamType = .none
    
    public var rawText: String?
    
    // MARK: - Custom Properties
    
    /// Made using facilityIndicator and notamNumber since we can get 2 notams with same notamNumber but different facilityIndicators. Ex: "KLAS06/005"
    public var id: String?
    
    public var flag: NotamFlag?
    
    // MARK: - Computed Properties
    
    /// Returns whether or not cleanText contains any warning words.
    public var hasWarnings: Bool {
        
        let notam = self.cleanText ?? ""
        let words = notam.split(separator: " ")
        let count = words.count
        var i = 0
        
        while i < count {
            let word = "\(words[i])"
            
            if NOTAM.redWords.contains(word) {
                            
                // OUT OF SERVICE?
                if word == "OUT" {
                    if (i + 2) < count && words[i+1] == "OF" && words[i+2].contains("SERVICE") {
                        return true
                    } else {
                        i += 1
                        continue
                    }
                }
                
                // Every other warning
                else {
                    return true
                }
            }
            i += 1
        }
        
        return false
    }
    
    /// Returns Tuple containing Strings to be displayed after effective and expiration Dates to display when they'll be active / duration
    public func duration() -> (effectiveString: String, expirationString: String) {
        
        guard let startDate = effectiveDate, let endDate = expirationDate else { return ("", "") }
        
        let now = Date().timeIntervalSinceReferenceDate
        let start = startDate.timeIntervalSinceReferenceDate
        let end = endDate.timeIntervalSinceReferenceDate
        
        // current
        if now < end && now >= start {
            let diff = end - now
            let mins = diff / 60
            let hours = mins / 60
            let days = hours / 24
            let daysString = days >= 1 ? "\(Int(days))d" : ""
            let expirationString = "(In: \(daysString) \(Int(hours) % 24)h \( Int(mins) % 60)m)"
            return ("(ACTIVE)", expirationString)
        }
        
        // future
        else if start >= now {
            // seconds difference
            let diff = end - start
            let startsInDiff = start - now
            
            let startsMins = startsInDiff / 60
            let startsHours = startsMins / 60
            let startsDays = startsHours / 24
            let startsDaysString = startsDays >= 1 ? "\(Int(startsDays))d" : ""
            let effectiveString = "(In: \(startsDaysString) \(Int(startsHours) % 24)h \( Int(startsMins) % 60)m)"
            
            let mins = diff / 60
            let hours = mins / 60
            let days = hours / 24
            let daysString = days >= 1 ? "\(Int(days))d" : ""
            let expirationString = "(Duration: \(daysString) \(Int(hours) % 24)h \( Int(mins) % 60)m)"
            
            return (effectiveString, expirationString)
        }
        
        // past (don't show duration?)
        return ("", "")
        
    }
    
    // MARK: - CodingKeys
    
    public enum CodingKeys: String, CodingKey {
        case facilityDesignator, icaoId, icaoMessage, traditionalMessage, featureName, notamNumber, issueDate, startDate, endDate, comment
        case message = "traditionalMessageFrom4thWord"
    }
    
    // MARK: - Init
    
    public init(facilityDesignator: String?, icaoId: String?, icaoMessage: String?, traditionalMessage: String?, featureName: String?, notamNumber: String?, issueDate: String?, createdDate: Date?, startDate: String?, effectiveDate: Date?, endDate: String?, expirationDate: Date?, message: String?, comment: URL?, cleanText: String? = nil, type: NotamType, rawText: String? = nil, id: String? = nil) {
        self.facilityDesignator = facilityDesignator
        self.icaoId = icaoId
        self.icaoMessage = icaoMessage
        self.traditionalMessage = traditionalMessage
        self.featureName = featureName
        self.notamNumber = notamNumber
        self.issueDate = issueDate
        self.createdDate = createdDate
        self.startDate = startDate
        self.effectiveDate = effectiveDate
        self.endDate = endDate
        self.expirationDate = expirationDate
        self.message = message
        self.comment = comment
        self.cleanText = cleanText
        self.type = type
        self.rawText = rawText
        self.id = id
        
        // flag
        flag = NotamFlag.makeFlag(text: message,
                                  notamId: id,
                                  notamType: type,
                                  facilityDesignator: facilityDesignator)
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // facilityDesignator
        facilityDesignator = try? container.decode(String.self, forKey: .facilityDesignator)
        
        // icaoId
        icaoId = try? container.decode(String.self, forKey: .icaoId)
        
        // icaoMessage
        icaoMessage = try? container.decode(String.self, forKey: .icaoMessage)
        
        // traditionalMessage
        traditionalMessage = try? container.decode(String.self, forKey: .traditionalMessage)
        
        // featureName
        featureName = try? container.decode(String.self, forKey: .featureName)
        
        // notamNumber
        notamNumber = try? container.decode(String.self, forKey: .notamNumber)
        
        // issueDate
        issueDate = try? container.decode(String.self, forKey: .issueDate)
        
        // createdDate
        createdDate = issueDate?.notamDate()
        
        // startDate
        startDate = try? container.decode(String.self, forKey: .startDate)
        
        // effectiveDate
        effectiveDate = startDate?.notamDate()
        
        // endDate
        endDate = try? container.decode(String.self, forKey: .endDate)
        
        // expirationDate
        expirationDate = endDate?.notamDate()
        
        // TODO: if message ends with "...", try using E) part of icaoMessage, if icaoMessage is nil, use traditionalMessage?
        // TODO: sometimes traditionalMessage and icaoMessage can have different raw text from response, like removing "NAV"
        // message
        let tempMessage = try? container.decode(String.self, forKey: .message)
        message = tempMessage
        
        // rawText
        if let icaoText = icaoMessage, icaoText.count > 14 {
            rawText = icaoText
        }
        if let domestic = traditionalMessage, domestic.count > 14 {
            rawText = domestic
        }
        
        // comment
        comment = try? container.decode(URL.self, forKey: .comment)
        
        // TODO: assign this last so we can give it an error/unknown type if something goes wrong above
        // TODO: also send "message" property so we can check it for bird keywords?
        // type
        type = qCode(icaoMessage: icaoMessage, featureName: featureName)
        
        // cleanText
        if let notam = message {
            cleanText = cleanNotam(notam: notam)
        }
        
        // id
        if let facility = facilityDesignator, let number = notamNumber {
            id = facility + number
        }
        
        // flag
        flag = NotamFlag.makeFlag(text: message,
                                  notamId: id,
                                  notamType: type,
                                  facilityDesignator: facilityDesignator)
    }
    
    // MARK: - Helpers
    
    public var isNotamAndFlagActive: Bool {
        return isActive && flag?.isFlagActive == true
    }
    
    // TODO: use this for notams view that divides notams into sections based on timestamp
    public var isActive: Bool {

        let startDate = effectiveDate ?? .distantPast
        let endDate = expirationDate ?? .distantFuture
        
        // Future (if startDate is greater than right now)
        if startDate.timeIntervalSinceReferenceDate > Date().timeIntervalSinceReferenceDate {
            return false
        }
        
        // Expired (if endDate is less than right now)
        else if endDate.timeIntervalSinceReferenceDate < Date().timeIntervalSinceReferenceDate {
            return false
        }
        
        // Current/Active
        return true
    }
    
    public func qCode(icaoMessage: String?, featureName: String?) -> NotamType {
        
        // type is unknown if we can't even get icaoMessage, which contains the Q Code
        guard let qString = icaoMessage else { return .unknown }

        let stringArray = Array(qString)
        var i = 0
        let count = stringArray.count

        while i < count {
            let letter = stringArray[i]
            
            // look for a "Q" immediately followed by a ")"
            if letter == "Q", (i+1) < count, stringArray[i+1] == ")" {
                // then look for next q and its next 2 characters after that
                var j = i + 1
                while j < count {
                    let char = stringArray[j]
                    if char == "Q", (j+4) < count {
                        let firstLetter = "\(stringArray[j+1])"
                        let secondLetter = "\(stringArray[j+2])"
                        return getType(first: firstLetter, second: secondLetter, feature: featureName)
                    }
                    j += 1
                }
            }
            
            i += 1
        }
        
        return .none
    }
    
    // TODO: try breaking up each word again by replacing non-letters with blank space
    // TODO: and then checking each sub word since words can be multiple contractions or have typos, then put back together
    private func cleanNotam(notam: String) -> String {
        
        var result = ""
        
        // remove /n and make into an Array of words
        let words = notam.replacingOccurrences(of: "\n", with: " ").split(separator: " ")
        let count = words.count
        
        // TODO: make sure it still works with periods
        for i in 0..<count {
            let word = "\(words[i])"
        
            if let cleanWord = NOTAM.contractionsDict[word] {
                result += "\(cleanWord). "
            }
            
            else if let cleanWordPeriod = NOTAM.contractionsDict[word + "."] {
                result += "\(cleanWordPeriod) "
            }
            
            else if word.contains("/") {
                result += "\(multiContractions(word: word)) "
            }
            
            else {
                result += "\(word) "
            }
        }
                
        return result
    }
    
    /// Replaces passed in word with translated version (if applicable)
    private func multiContractions(word: String) -> String {
        var results = [String]()
        
        // break up word where we find "/"
        
        // ex: "TAR/SSR"
        let multiword = word.split(separator: "/")
        
        for contraction in multiword {
            
            if let translation = NOTAM.contractionsDict["\(contraction)"], translation.count > 1 {
                results.append(translation)
            }
            
            // if it doesn't have period inside, try adding one
            else if let translation = NOTAM.contractionsDict["\(contraction)."], translation.count > 1 {
                results.append(translation)
            }
            
            else {
                results.append("\(contraction)")
            }
        }
        
        return results.joined(separator: "/")
    }
    
    private func getType(first: String, second: String, feature: String?) -> NotamType {
        let both = first.uppercased() + second.uppercased()
        // 1. TFR/Warning: Any W- or T-. RT
        // 2. Runway: MR, ML, MT
        // 3. Obstacle: OB, OL
        // 4. Taxiway: Any other M-
        // 5. Airport: C-, F-, L-, N-, S-
        // 6. Instrument Procedure: I-, P-
        // 7. Airspace: A-
        // 8. Birds: X- AND BASH or BIRD(S) keyword
        
        // TFR/Warning
        if first == "W" || first == "T" || both == "RT" { return .tfr }
        
        // Runway
        if both == "MR" || both == "ML" || both == "MT" { return .runway }
        
        // Obstacle
        if both == "OB" || both == "OL" { return .obstacle }
        
        // Taxiway
        if first == "M" { return .taxiway }
        
        // Airport
        if first == "C" || first == "F" || first == "L" || first == "N" || first == "S" { return .airport }
        
        // Instrument Procedure
        if first == "I" || first == "P" || feature == "Procedure" { return .procedure }
        
        // Airspace
        if first == "A" { return .airspace }
        
        // Birds
        let birdWords = Set(["BASH", "BIRD", "BIRDS"])
        guard let text = rawText else { return .none }
        let words = text.replacingOccurrences(of: "\n", with: "").split(separator: " ")
        for word in words {
            let currWord = "\(word)"
            if birdWords.contains(currWord) {
                return .birds
            }
        }
        
        // TODO: Unknown (if icaoMessage is empty, or if any dates can't be read)
        
        return .none
    }
    
    // TODO: instead of having periods after each word, add something that removes non-letters from each word and then adds back those characters that were removed?

    // TODO: short assault landing zone runways do not match what we have in DAFIF
    /// Takes in an array of NotamFlag, a runway's low and high idents and returns the flags that belong to that runway
    static public func flagsForRunway(flags: [NotamFlag], lowIdent: String?, highIdent: String?) -> [NotamFlag] {
        guard let low = lowIdent, let high = highIdent else { return [] }
        var results = [NotamFlag]()
        for flag in flags {
            let both = "\(low)/\(high)"
            if flag.ident == both || flag.ident == low || flag.ident == high {
                results.append(flag)
            }
        }
        return results
    }
    
    /// CLOSED, UNSERVICEABLE, OUT, OTS
    public static let redWords: Set<String> = ["CLOSED.", "CLOSED",
                                               "UNSERVICEABLE", "UNSERVICEABLE.",
                                               "OUT", "OUT OF SERVICE", "OUT OF SERVICE.",
                                               "CLSD.", "CLSD",
                                               "OTS", "OTS.",
                                               "U/S", "U/S.",
                                               "UNUSBL", "UNUSBL.",
                                               "UNMNT", "UNMNT."]
    
    public static let contractionsDict = ["ABN.": "AIRPORT BEACON",
                                   "ABV.": "ABOVE",
                                   "ACC.": "AREA CONTROL CENTER (ARTCC)",
                                   "ACCUM.": "ACCUMULATE",
                                   "ACFT.": "AIRCRAFT",
                                   "ACR.": "AIR CARRIER",
                                   "ACT.": "ACTIVE",
                                   "ADJ.": "ADJACENT",
                                   "ADZD.": "ADVISED",
                                   "AFD.": "AIRPORT FACILITY DIRECTORY",
                                   "AGL.": "ABOVE GROUND LEVEL",
                                   "ALS.": "APPROACH LIGHTING SYSTEM",
                                   "ALT.": "ALTITUDE",
                                   "ALTM.": "ALTIMETER",
                                   "ALTN.": "ALTERNATE",
                                   "ALTNLY.": "ALTERNATELY",
                                   "ALSTG.": "ALTIMETER SETTING",
                                   "AMDT.": "AMENDMENT",
                                   "AMGR.": "AIRPORT MANAGER",
                                   "AMOS.": "AUTOMATIC METEOROLOGICAL OBSERVING SYSTEM",
                                   "AP.": "AIRPORT",
                                   "APCH.": "APPROACH",
                                   "AP LGT.": "AIRPORT LIGHTING",
                                   "APP.": "APPROACH CONTROL",
                                   "ARFF.": "AIRCRAFT RESCUE AND FIRE FIGHTING",
                                   "ARR.": "ARRIVE/ARRIVAL",
                                   "ASOS.": "AUTOMATIC SURFACE OBSERVING SYSTEM",
                                   "ASPH.": "ASPHALT",
                                   "ATC.": "AIR TRAFFIC CONTROL",
                                   "ATCCC.": "AIR TRAFFIC CONTROL COMMAND CENTER",
                                   "ATIS.": "AUTOMATIC TERMINAL INFORMATION SERVICE",
                                   "AUTOB.": "AUTOMATIC WEATHER REPORTING SYSTEM",
                                   "AUTH.": "AUTHORITY",
                                   "AVBL.": "AVAILABLE",
                                   "AWOS.": "AUTOMATIC WEATHER OBSERVING/REPORTING SYSTEM",
                                   "AWY.": "AIRWAY",
                                   "AZM.": "AZIMUTH",
                                   "BA FAIR.": "BRAKING ACTION FAIR",
                                   "BA NIL.": "BRAKING ACTION NIL",
                                   "BA POOR.": "BRAKING ACTION POOR",
                                   "BC.": "BACK COURSE",
                                   "BCN.": "BEACON",
                                   "BERM.": "SNOWBANK(S) CONTAINING EARTH/GRAVEL",
                                   "BLW.": "BELOW",
                                   "BND.": "BOUND",
                                   "BRG.": "BEARING",
                                   "BYD.": "BEYOND",
                                   "CASS.": "CLASS A AIRSPACE",
                                   "CAT.": "CATEGORY",
                                   "CBAS.": "CLASS B AIRSPACE",
                                   "CBSA.": "CLASS B SURFACE AREA",
                                   "CCAS.": "CLASS C AIRSPACE",
                                   "CCLKWS.": "COUNTERCLOCKWISE",
                                   "CCSA.": "CLASS C SURFACE AREA",
                                   "CD.": "CLEARANCE DELIVERY",
                                   "CDAS.": "CLASS D AIRSPACE",
                                   "CDSA.": "CLASS D SURFACE AREA",
                                   "CEAS.": "CLASS E AIRSPACE",
                                   "CESA.": "CLASS E SURFACE AREA",
                                   "CFR.": "CODE OF FEDERAL REGULATIONS",
                                   "CGAS.": "CLASS G AIRSPACE",
                                   "CHAN.": "CHANNEL",
                                   "CHG.": "CHANGE OR MODIFICATION",
                                   "CIG.": "CEILING",
                                   "CK.": "CHECK",
                                   "CL.": "CENTRE LINE",
                                   "CLKWS.": "CLOCKWISE",
                                   "CLR.": "CLEARANCE/CLEAR(S)/CLEARED TO",
                                   "CLSD.": "CLOSED",
                                   "CMB.": "CLIMB",
                                   "CMSND.": "COMMISSIONED",
                                   "CNL.": "CANCEL",
                                   "CNTRLN.": "CENTERLINE",
                                   "COM.": "COMMUNICATIONS",
                                   "CONC.": "CONCRETE",
                                   "CPD.": "COUPLED",
                                   "CRS.": "COURSE",
                                   "CTC.": "CONTACT",
                                   "CTL.": "CONTROL",
                                   "DALGT.": "DAYLIGHT",
                                   "DCMSN.": "DECOMMISSION",
                                   "DCMSND.": "DECOMMISSIONED",
                                   "DCT.": "DIRECT",
                                   "DEGS.": "DEGREES",
                                   "DEP.": "DEPART/DEPARTURE",
                                   "DEP PROC.": "DEPARTURE PROCEDURE",
                                   "DH.": "DECISION HEIGHT",
                                   "DISABLD.": "DISABLED",
                                   "DIST.": "DISTANCE",
                                   "DLA.": "DELAY/DELAYED",
                                   "DLT.": "DELETE",
                                   "DLY.": "DAILY",
                                   "DMSTN.": "DEMONSTRATION",
                                   "DP.": "DEWPOINT TEMPERATURE",
                                   "DRFT.": "SNOWBANK(S) CAUSED BY WIND ACTION",
                                   "DSPLCD.": "DISPLACED",
                                   "E.": "EAST",
                                   "EB.": "EASTBOUND",
                                   "EFAS.": "EN ROUTE FLIGHT ADVISORY SERVICE",
                                   "ELEV.": "ELEVATION",
                                   "ENG.": "ENGINE",
                                   "ENRT.": "EN ROUTE",
                                   "ENTR.": "ENTIRE",
                                   "EXC.": "EXCEPT",
                                   "FAC.": "FACILITY/FACILITIES",
                                   "FAF.": "FINAL APPROACH FIX",
                                   "FAN MKR.": "FAN MARKER",
                                   "FDC.": "FLIGHT DATA CENTER",
                                   "FI/T.": "FLIGHT INSPECTION TEMPORARY",
                                   "FI/P.": "FLIGHT INSPECTION PERMANENT",
                                   "FM.": "FROM",
                                   "FNA.": "FINAL APPROACH",
                                   "FPM.": "FEET PER MINUTE",
                                   "FREQ.": "FREQUENCY",
                                   "FRH.": "FLY RUNWAY HEADING",
                                   "FRI.": "FRIDAY",
                                   "FRZN.": "FROZEN",
                                   "FSS.": "AUTOMATED/FLIGHT SERVICE STATION",
                                   "FT.": "FOOT/FEET",
                                   "GC.": "GROUND CONTROL",
                                   "GCA.": "GROUND CONTROL APPROACH",
                                   "GCO.": "GROUND COMMUNICATIONS OUTLET",
                                   "GOVT.": "GOVERNMENT",
                                   "GP.": "GLIDE PATH",
                                   "GPS.": "GLOBAL POSITIONING SYSTEM",
                                   "GRVL.": "GRAVEL",
                                   "GS.": "GLIDESLOPE",
                                   "HAA.": "HEIGHT ABOVE AIRPORT",
                                   "HAT.": "HEIGHT ABOVE TOUCHDOWN",
                                   "HDG.": "HEADING",
                                   "HEL.": "HELICOPTER",
                                   "HELI.": "HELIPORT",
                                   "HIRL.": "HIGH INTENSITY RUNWAY LIGHTS",
                                   "HIWAS.": "HAZARDOUS INFLIGHT WEATHER ADVISORY SERVICE",
                                   "HLDG.": "HOLDING",
                                   "HOL.": "HOLIDAY",
                                   "HP.": "HOLDING PATTERN",
                                   "HR.": "HOUR",
                                   "IAF.": "INITIAL APPROACH FIX",
                                   "IAP.": "INSTRUMENT APPROACH PROCEDURE",
                                   "INBD.": "INBOUND",
                                   "ID.": "IDENTIFICATION",
                                   "IDENT.": "IDENTITY/IDENTIFIER/IDENTIFICATION",
                                   "IF.": "INTERMEDIATE FIX",
                                   "IM.": "INNER MARKER",
                                   "IMC.": "INSTRUMENT METEOROLOGICAL CONDITIONS",
                                   "INDEFLY.": "INDEFINITELY",
                                   "INFO.": "INFORMATION",
                                   "INOP.": "INOPERATIVE",
                                   "INSTR.": "INSTRUMENT",
                                   "INT.": "INTERSECTION",
                                   "INTL.": "INTERNATIONAL",
                                   "INTST.": "INTENSITY",
                                   "IR.": "ICE ON RUNWAY(S)",
                                   "KT.": "KNOTS",
                                   "LAA.": "LOCAL AIRPORT ADVISORY",
                                   "LAT.": "LATITUDE",
                                   "LAWRS.": "LIMITED AVIATION WEATHER REPORTING STATION",
                                   "LB.": "POUND(S)",
                                   "LC.": "LOCAL CONTROL",
                                   "LCTD.": "LOCATED",
                                   "LDA.": "LOCALIZER TYPE DIRECTIONAL AID",
                                   "LGT.": "LIGHT/LIGHTING",
                                   "LGTD.": "LIGHTED",
                                   "LIRL.": "LOW INTENSITY RUNWAY LIGHTS",
                                   "LLWAS.": "LOW LEVEL WIND SHEAR ALERT SYSTEM",
                                   "LM.": "COMPASS LOCATOR AT ILS MIDDLE MARKER",
                                   "LDG.": "LANDING",
                                   "LLZ.": "LOCALIZER",
                                   "LO.": "COMPASS LOCATOR AT ILS OUTER MARKER",
                                   "LONG.": "LONGITUDE",
                                   "LRN.": "LONG RANGE NAVIGATION",
                                   "LSR.": "LOOSE SNOW ON RUNWAY(S)",
                                   "LT.": "LEFT TURN",
                                   "MAG.": "MAGNETIC",
                                   "MAINT.": "MAINTAIN/MAINTENANCE",
                                   "MALS.": "MEDIUM INTENSITY APPROACH LIGHT SYSTEM",
                                   "MALSF.": "MEDIUM INTENSITY APPROACH LIGHT SYSTEM WITH SEQUENCED FLASHERS",
                                   "MALSR.": "MEDIUM INTENSITY APPROACH LIGHT SYSTEM WITH RUNWAY ALIGNMENT INDICATOR LIGHTS",
                                   "MAPT.": "MISSED APPROACH POINT",
                                   "MBST.": "MICROBURST",
                                   "MCA.": "MINIMUM CROSSING ALTITUDE",
                                   "MDA.": "MINIMUM DESCENT ALTITUDE",
                                   "MEA.": "MINIMUM EN ROUTE ALTITUDE",
                                   "MED.": "MEDIUM",
                                   "MIN.": "MINUTE(S)",
                                   "MIRL.": "MEDIUM INTENSITY RUNWAY LIGHTS",
                                   "MKR.": "MARKER",
                                   "MLS.": "MICROWAVE LANDING SYSTEM",
                                   "MM.": "MIDDLE MARKER",
                                   "MNM.": "MINIMUM",
                                   "MNT.": "MONITOR/MONITORING/MONITORED",
                                   "MOC.": "MINIMUM OBSTRUCTION CLEARANCE",
                                   "MON.": "MONDAY",
                                   "MRA.": "MINIMUM RECEPTION ALTITUDE",
                                   "MSA.": "MINIMUM SAFE/SECTOR ALTITUDE",
                                   "MSAW.": "MINIMUM SAFE ALTITUDE WARNING",
                                   "MSG.": "MESSAGE",
                                   "MSL.": "MEAN SEA LEVEL",
                                   "MU.": "MU METERS",
                                   "MUD.": "MUD",
                                   "MUNI.": "MUNICIPAL",
                                   "N.": "NORTH",
                                   "NA.": "NOT AUTHORIZED",
                                   "NAV.": "NAVIGATION",
                                   "NB.": "NORTHBOUND",
                                   "NDB.": "NONDIRECTIONAL RADIO BEACON",
                                   "NE.": "NORTHEAST",
                                   "NGT.": "NIGHT",
                                   "NM.": "NAUTICAL MILE(S)",
                                   "NMR.": "NAUTICAL MILE RADIUS",
                                   "NONSTD.": "NONSTANDARD",
                                   "NOPT.": "NO PROCEDURE TURN REQUIRED",
                                   "NR.": "NUMBER",
                                   "NTAP.": "NOTICE TO AIRMEN PUBLICATION",
                                   "NW.": "NORTHWEST",
                                   "OBSC.": "OBSCURED/OBSCURE/OBSCURING",
                                   "OBST.": "OBSTRUCTION/OBSTACLE",
                                   "OM.": "OUTER MARKER",
                                   "OPR.": "OPERATE/OPERATOR/OPERATIVE",
                                   "OPS.": "OPERATION(S)",
                                   "ORIG.": "ORIGINAL",
                                   "OTS.": "OUT OF SERVICE",
                                   "OVR.": "OVER",
                                   "PAEW.": "PERSONNEL AND EQUIPMENT WORKING",
                                   "PAX.": "PASSENGER(S)",
                                   "PAPI.": "PRECISION APPROACH PATH INDICATOR",
                                   "PAR.": "PRECISION APPROACH RADAR",
                                   "PARL.": "PARALLEL",
                                   "PAT.": "PATTERN",
                                   "PCL.": "PILOT CONTROLLED LIGHTING",
                                   "PERM.": "PERMANENT",
                                   "PJE.": "PARACHUTE JUMPING EXERCISE",
                                   "PLA.": "PRACTICE LOW APPROACH",
                                   "PLW.": "PLOW/PLOWED",
                                   "PN.": "PRIOR NOTICE REQUIRED",
                                   "PPR.": "PRIOR PERMISSION REQUIRED",
                                   "PRN.": "PSUEDO RANDOM NOISE",
                                   "PROC.": "PROCEDURE",
                                   "PROP.": "PROPELLER",
                                   "PSR.": "PACKED SNOW ON RUNWAY(S)",
                                   "PTCHY.": "PATCHY",
                                   "PTN.": "PROCEDURE TURN",
                                   "PVT.": "PRIVATE",
                                   "RAIL.": "RUNWAY ALIGNMENT INDICATOR LIGHTS",
                                   "RAMOS.": "REMOTE AUTOMATIC METEOROLOGICAL OBSERVING SYSTEM",
                                   "RCAG.": "REMOTE COMMUNICATION AIR/GROUND FACILITY",
                                   "RCL.": "RUNWAY CENTER LINE",
                                   "RCLL.": "RUNWAY CENTER LINE LIGHTS",
                                   "RCO.": "REMOTE COMMUNICATION OUTLET",
                                   "REC.": "RECEIVE/RECEIVER",
                                   "REIL.": "RUNWAY END IDENTIFIER LIGHTS",
                                   "RELCTD.": "RELOCATED",
                                   "REP.": "REPORT",
                                   "RLLS.": "RUNWAY LEAD-IN LIGHT SYSTEM",
                                   "RMNDR.": "REMAINDER",
                                   "RMK.": "REMARK(S)",
                                   "RNAV.": "AREA NAVIGATION",
                                   "RPLC.": "REPLACE",
                                   "RQRD.": "REQUIRED",
                                   "RRL.": "RUNWAY REMAINING LIGHTS",
                                   "RSR.": "EN ROUTE SURVEILLANCE RADAR",
                                   "RSVN.": "RESERVATION",
                                   "RT.": "RIGHT TURN",
                                   "RTE.": "ROUTE",
                                   "RTR.": "REMOTE TRANSMITTER/RECEIVER",
                                   "RTS.": "RETURN TO SERVICE",
                                   "RUF.": "ROUGH",
                                   "RVR.": "RUNWAY VISUAL RANGE",
                                   "RVRM.": "RUNWAY VISUAL RANGE MIDPOINT",
                                   "RVRR.": "RUNWAY VISUAL RANGE ROLLOUT",
                                   "RVRT.": "RUNWAY VISUAL RANGE TOUCHDOWN",
                                   "RWY.": "RUNWAY",
                                   "S.": "SOUTH",
                                   "SA.": "SAND/SANDED",
                                   "SAT.": "SATURDAY",
                                   "SAWRS.": "SUPPLEMENTARY AVIATION WEATHER REPORTING STATION",
                                   "SB.": "SOUTHBOUND",
                                   "SDF.": "SIMPLIFIED DIRECTIONAL FACILITY",
                                   "SE.": "SOUTHEAST",
                                   "SFL.": "SEQUENCE FLASHING LIGHTS",
                                   "SIMUL.": "SIMULTANEOUS/SIMULTANEOUSLY",
                                   "SIR.": "PACKED/COMPACTED SNOW AND ICE ON RUNWAYS()",
                                   "SKED.": "SCHEDULED/SCHEDULE",
                                   "SLR.": "SLUSH ON RUNWAY(S)",
                                   "SN.": "SNOW",
                                   "SNBNK.": "SNOWBANK(S) CAUSED BY PLOWING (WINDROW(S))",
                                   "SNGL.": "SINGLE",
                                   "SPD.": "SPEED",
                                   "SSALF.": "SIMPLIFIED SHORT APPROACH LIGHTING WITH SEQUENCE FLASHERS",
                                   "SSALR.": "SIMPLIFIED SHORT APPROACH LIGHTING WITH RUNWAY ALIGNMENT INDICATOR LIGHTS",
                                   "SSALS.": "SIMPLIFIED SHORT APPROACH LIGHTING SYSTEM",
                                   "SSR.": "SECONDARY SURVEILLANCE RADAR",
                                   "STA.": "STRAIGHT-IN APPROACH",
                                   "STAR.": "STANDARD TERMINAL ARRIVAL",
                                   "SUN.": "SUNDAY",
                                   "SVC.": "SERVICE",
                                   "SVN.": "SATELLITE VEHICLE NUMBER",
                                   "SW.": "SOUTHWEST",
                                   "SWEPT.": "SWEPT/BROOM(ED)",
                                   "TAR.": "TERMINAL AREA SURVEILLANCE RADAR",
                                   "TDWR.": "TERMINAL DOPPLER WEATHER RADAR",
                                   "TDZ.": "TOUCHDOWN ZONE",
                                   "TDZ LGT.": "TOUCHDOWN ZONE LIGHTS",
                                   "TEMPO.": "TEMPORARY/TEMPORARILY",
                                   "TFC.": "TRAFFIC",
                                   "TFR.": "TEMPORARY FLIGHT RESTRICTION",
                                   "THN.": "THIN",
                                   "THR.": "THRESHOLD",
                                   "THRU.": "THROUGH",
                                   "THU.": "THURSDAY",
                                   "TIL.": "UNTIL",
                                   "TKOF.": "TAKEOFF",
                                   "TM.": "TRAFFIC MANAGEMENT",
                                   "TMPA.": "TRAFFIC MANAGEMENT PROGRAM ALERT",
                                   "TRML.": "TERMINAL",
                                   "TRNG.": "TRAINING",
                                   "TRSN.": "TRANSITION",
                                   "TSNT.": "TRANSIENT",
                                   "TUE.": "TUESDAY",
                                   "TWR.": "AIRPORT CONTROL TOWER",
                                   "TWY.": "TAXIWAY",
                                   "U/S.": "OUT OF SERVICE",
                                   "UAV.": "UNMANNED AIR VEHICLES",
                                   "UFN.": "UNTIL FURTHER NOTICE",
                                   "UNAVBL.": "UNAVAILABLE",
                                   "UNLGTD.": "UNLIGHTED",
                                   "UNMKD.": "UNMARKED",
                                   "UNMNT.": "UNMONITORED",
                                   "UNREL.": "UNRELIABLE",
                                   "UNUSBL.": "UNUSABLE",
                                   "VASI.": "VISUAL APPROACH SLOPE INDICATOR SYSTEM",
                                   "VDP.": "VISUAL DESCENT POINT",
                                   "VIA.": "BY WAY OF",
                                   "VICE.": "INSTEAD/VERSUS",
                                   "VIS.": "VISIBILITY",
                                   "VMC.": "VISUAL METEOROLOGICAL CONDITIONS",
                                   "VOL.": "VOLUME",
                                   "W.": "WEST",
                                   "WB.": "WESTBOUND",
                                   "WED.": "WEDNESDAY",
                                   "WEF.": "WITH EFFECT FROM / EFFECTIVE FROM",
                                   "WI.": "WITHIN",
                                   "WIE.": "WITH IMMEDIATE EFFECT / EFFECTIVE IMMEDIATELY",
                                   "WKDAYS.": "MONDAY THROUGH FRIDAY",
                                   "WKEND.": "SATURDAY AND SUNDAY",
                                   "WND.": "WIND",
                                   "WPT.": "WAYPOINT",
                                   "WS.": "WIND SHEAR",
                                   "WSR.": "WET SNOW ON RUNWAY(S)",
                                   "WTR.": "WATER ON RUNWAY(S)",
                                   "WX.": "WEATHER"]
    
    // added "WS": "WIND SHEAR"
    // added "MBST": "MICROBURST"
    // removed "VOR": "VHF OMNI-DIRECTIONAL RADIO RANGE"
    // removed "VORTAC": "VOR AND TACAN (COLLOCATED)"
    // removed "TACAN": "TACTICAL AIR NAVIGATION AID (AZIMUTH AND DME)"
    // removed "L": "LEFT"
    // removed "T": "TEMPERATURE"
    // TYPOS?: CENTRE LINE, FLIGHT INSPECTION TEMPORAY/PERMANENT
    // added "GS" = "GLIDESLOPE"
    // removed "IN.": "INCH/INCHES"
    // removed "ILS.": "INSTRUMENT LANDING SYSTEM"
    // removed "LOC.": "LOCAL/LOCALLY/LOCATION"
    // removed "DME.": "DISTANCE MEASURING EQUIPMENT"
    
    public static let addedContractions: Set<String> = ["GS",
                                           "MBST",
                                           "WS"]
    
    public static let removedContractions = ["DME": "DISTANCE MEASURING EQUIPMENT",
                                             "ILS": "INSTRUMENT LANDING SYSTEM",
                                             "IN": "INCH/INCHES",
                                             "L": "LEFT",
                                             "LOC": "LOCAL/LOCALLY/LOCATION/LOCALIZER",
                                             "T": "TEMPERATURE",
                                             "TACAN": "TACTICAL AIR NAVIGATION AID (AZIMUTH AND DME)",
                                             "VOR": "VHF OMNI-DIRECTIONAL RADIO RANGE",
                                             "VORTAC": "VOR AND TACAN (COLLOCATED)"]
}
