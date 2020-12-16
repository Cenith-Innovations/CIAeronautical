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

public struct Ahas: Loopable {
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
    
}
