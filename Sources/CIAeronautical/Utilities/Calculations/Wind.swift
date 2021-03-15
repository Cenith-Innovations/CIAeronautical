// ********************** File *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 3/13/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** File *********************************


import Foundation

public typealias CalcWinds = (hehw: Double, hexw: Double, lehw: Double, lexw: Double)

public struct Wind {
    
    let runwayHeading: Heading
    let windHeading: Heading
    let windSpeed: Double
    
    public init(windHeading: Heading, windSpeed: Double, runwayHeading: Heading) {
        self.runwayHeading = runwayHeading
        self.windHeading = windHeading
        self.windSpeed = windSpeed
    }
    
    private var windAngle: Double {
        get {
            return Double((runwayHeading - windHeading).direction)
        }
    }
    
    public var headWind: Double {
        get{
            return windSpeed * cos(windAngle * Double.pi / 180)
        }
    }
    
    public var crossWind: Double {
        get{
            return Double(windSpeed * sin(windAngle * Double.pi / 180))
        }
    }
    
    public static func calcWinds(highHdg: Double?, lowghHdg: Double?, windSpeed: Double?, windDirection: Double?) -> CalcWinds {
        let heRwyHeading = Heading(Int(highHdg!))
        let leRwyHeading = Heading(Int(lowghHdg!))
        let noWindValue = 99999.0
        
        let unknowConditions = (hehw: noWindValue, hexw: noWindValue, lehw: noWindValue, lexw: noWindValue)
        
        guard let windDirection = windDirection else { return unknowConditions }
        let windDirectionInt = Int(windDirection)
        let windHeading = Heading(windDirectionInt)
        guard let windSpeed = windSpeed else { return unknowConditions }
        let heWind = Wind(windHeading: windHeading, windSpeed: windSpeed, runwayHeading: heRwyHeading)
        let leWind = Wind(windHeading: windHeading, windSpeed: windSpeed, runwayHeading: leRwyHeading)
        
        
        let hehw = heWind.headWind
        let hexw = heWind.crossWind
        let lehw = leWind.headWind
        let lexw = leWind.crossWind
        
        return (hehw: hehw, hexw: hexw, lehw: lehw, lexw: lexw)
    }
}
