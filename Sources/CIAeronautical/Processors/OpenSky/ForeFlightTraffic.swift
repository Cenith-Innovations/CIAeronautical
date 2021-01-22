// ********************** ForeFlightTraffic *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 1/22/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** ForeFlightTraffic *********************************


import Foundation


/** Generates the text string formatted for ForeFlight to read the traffic from OpenSky.
  ** [ForeFlight Info Page](https://support.foreflight.com/hc/en-us/articles/204115005-Flight-Simulator-GPS-Integration-UDP-Protocol-)
  ** [RealTraffic Developer Documentation](https://rtweb.flyrealtraffic.com/RTdev1.4.pdf)
 */
struct ForeFlightTraffic {
    
    var foreFlightTrafficString: String
        
    init(traffic: AdsBResult) {
        foreFlightTrafficString = "XTRAFFIC 4bitCrew \(traffic.icao24 ?? "") \(traffic.latitude ?? 0.0) \(traffic.longitude ?? 0.0) \(traffic.geoAltitude ?? 0.0) \(traffic.verticalRate ?? 0.0) \(traffic.onGround ?? false) \(traffic.trueTrack ?? 0.0) \(traffic.velocity ?? 0.0) \(traffic.callSign ?? "")"
        print("\(foreFlightTrafficString)")
    }
        
     
}

