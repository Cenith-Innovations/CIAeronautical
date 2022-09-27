// ********************** Notam *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/17/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Notam *********************************


import Foundation

/// NOTAM
public struct Notam: Identifiable, Loopable, Hashable {
    
    public var rawText: String?
    public var id: String?
    public var creationDate: Date?
    public var startDate: Date?
    public var endDate: Date?
    public var closedRunways: [String]?
    public var rvrOutOfService: String?
    
    init(notam: String) {
        let times = NotamHandler.getRXStartandEndTimes(notam: notam)
        id = NotamHandler.getIDFrom(notam)
        rawText = notam
        creationDate = NotamHandler.getCreationDate(notam: notam)
        startDate = times.start
        endDate = times.end
        // TODO: causes crash sometimes. See method for details
//        closedRunways = NotamHandler.getAllClosedRunways(notam: notam)
        rvrOutOfService = NotamHandler.getRVRoutOfServiceForRWYs(notam: notam)
    }
    // TODO: Tie the properties below
    var stateCode: String?    //ISO 3-Letter code of the State
    var stateName: String?    //Name of the State
    var entity: String?        //First 2 letters of the Q-code, if available
    var status: String?        //Last 2 letters of the Q-code, if available
    var qCode: String?        //Q-code of the NOTAM, if available
    var area: String?        //Decoded category first 2 letters of the Q-code
    var subArea: String?        //Decoded area of first 2 letters of the Q-code
    var condition: String?    //Decoded sub-area of first 2 letters of the Q-code
    var subject: String?        //Decoded area of last 2 letters of the Q-code
    var modifier: String?    //Decoded sub-area of last 2 letters of the Q-code
    var message: String?        //Message part of the NOTAM, if available

    var isIcao: String?        //If the NOTAM is compliant with Doc ABC. If false, no Q-code decoding is available
    var type: String?        //Location type, either airspace or airport
    var criticality: Int?    //The criticality level of the NOTAM as assessed by NORM. Criticality is a number between 0 (garbage) and 4 (critical). -1 if not assessed.
    
}
