// ********************** File *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 3/13/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** File *********************************


import Foundation

import SwiftUI

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
        let noWindValue = 99999.0
        let unknowConditions = (hehw: noWindValue, hexw: noWindValue, lehw: noWindValue, lexw: noWindValue)
        guard let highHdg = highHdg else { return unknowConditions }
        guard let lowghHdg = lowghHdg else { return unknowConditions }
        guard let windSpeed = windSpeed else { return unknowConditions }
        guard let windDirection = windDirection else { return unknowConditions }
        
        // Used to use Int() func to turn high/lowHdg. Replaced with .rounded() so it doesn't just remove decimal
        let heRwyHeading = Heading(highHdg.rounded())
        let leRwyHeading = Heading(lowghHdg.rounded())
        
        let windDirectionInt = Int(windDirection)
        let windHeading = Heading(windDirectionInt)
        
        let heWind = Wind(windHeading: windHeading, windSpeed: windSpeed, runwayHeading: heRwyHeading)
        let leWind = Wind(windHeading: windHeading, windSpeed: windSpeed, runwayHeading: leRwyHeading)
        
        let hehw = heWind.headWind
        let hexw = heWind.crossWind
        let lehw = leWind.headWind
        let lexw = leWind.crossWind
        
        return (hehw: hehw, hexw: hexw, lehw: lehw, lexw: lexw)
    }
    
    /// Takes in a single runway heading and returns its head and crosswinds
    public static func runwayEndWinds(heading: Double?, windSpeed: Double?, windDirection: Double?) -> (hw: Double, xw: Double)? {
        
        guard let hdg = heading, let speed = windSpeed, let dir = windDirection else { return nil }
        
        let wind = Wind(windHeading: Heading(dir), windSpeed: speed, runwayHeading: Heading(hdg.rounded()))
        
        return (wind.headWind, wind.crossWind)
    }
}

public struct WindComp {
    
    public struct WindError: Error {
        public let shortText: String
        public let longText: String
    }
    
    /// Takes in a single runway heading and returns its head and crosswinds
    public static func runwayWinds(heading: Double, windSpeed: Double, windDirection: Double) -> (hw: Double, xw: Double) {
                
        let wind = Wind(windHeading: Heading(windDirection),
                        windSpeed: windSpeed,
                        runwayHeading: Heading(heading.rounded()))
        
        return (wind.headWind, wind.crossWind)
    }
    
    /// Returns all components needed for making wind arrow UI on success. On failure, returns a WindError
    public static func calcWindComps(heading: Double?, direction: Double?, speed: Double?, gust: Double?, rawText: String?) -> Result<(vertical: WindComp, horizontal: WindComp), WindError> {
        
        // VRB
        guard !WX.getVrbWind(rawText: rawText) else {
            return .failure(WindError(shortText: "VAR", longText: "Winds Variable"))
        }
        
        // Wind Unavailable
        guard let heading = heading, let dir = direction, let spd = speed else {
            return .failure(WindError(shortText: "N/A", longText: "Winds N/A"))
        }
        
        // Calm
        if spd == 0 {
            if let gust = gust {
                if gust == 0 {
                    // Gust that is also 0
                    return .failure(WindError(shortText: "Calm", longText: "Winds Calm"))
                }
            } else {
                // No gust
                return .failure(WindError(shortText: "Calm", longText: "Winds Calm"))
            }
        }
                
        let comps = WindComp.runwayWinds(heading: heading,
                                        windSpeed: spd,
                                        windDirection: dir)
        
        // Gust
        var gustVerticalString = ""
        var gustHorizontalString = ""
        
        // Results
        let verticalComps = WindComp.headTailWinds(val: Int(comps.hw.rounded()))
        let horizontalComps = WindComp.crossWinds(val: Int(comps.xw.rounded()))
        let headTailArrow = Int(comps.hw) > 0 ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill"
        let crossArrow = Int(comps.xw) > 0 ? "arrowtriangle.right.fill" : "arrowtriangle.left.fill"
        
        var crossColor = horizontalComps.color
        
        if let gust = gust {
            let gustComps = WindComp.runwayWinds(heading: heading, windSpeed: gust, windDirection: dir)
            gustVerticalString = "-\(WindComp.headTailWinds(val: Int(gustComps.hw.rounded())).val)"
            let gustHoriComps = WindComp.crossWinds(val: Int(gustComps.xw.rounded()))
            gustHorizontalString = "-\(gustHoriComps.val)"
            crossColor = gustHoriComps.color
        }
               
        let vertString = gustVerticalString.isEmpty ? "\(verticalComps.val)kts" : verticalComps.val + gustVerticalString
        let horiString = gustHorizontalString.isEmpty ? "\(horizontalComps.dir)\(horizontalComps.val)kts" : "\(horizontalComps.dir)\(horizontalComps.val)" + gustHorizontalString
                
        let result = (WindComp(windType: verticalComps.type,
                               iconName: headTailArrow,
                               iconColor: verticalComps.color,
                               speedString: verticalComps.val,
                               gustString: verticalComps.val + gustVerticalString,
                               gustStringKts: vertString),
                      WindComp(windType: .cross,
                               iconName: crossArrow,
                               iconColor: crossColor,
                               speedString: "\(horizontalComps.dir)\(horizontalComps.val)",
                               gustString: "\(horizontalComps.dir)\(horizontalComps.val)" + gustHorizontalString,
                               gustStringKts: horiString))
        
        return .success(result)
    }
    
    public static func headTailWinds(val: Int) -> (type: WindType, val: String, color: Color?) {
                
        // nothing
        if val == 0 { return (.none, "", nil) }
        
        // HW
        if val > 0 { return (.head, "\(abs(val))", Color.green) }
        
        // TW
        else { return (.tail, "\(abs(val))", Color.red) }
    }
    
    public static func crossWinds(val: Int) -> (dir: String, val: String, color: Color?) {
        
        if val == 0 { return ("", "", nil) }
        
        let absVal = abs(val)
        let letter = val > 0 ? "L" : "R"
        
        var color = Color.gray
        if absVal > 15 { color = Color.yellow }
        if absVal > 25 { color = Color.red }
        
        return (letter, "\(absVal)", color)
    }
    
    public enum WindType: String {
        case head = "HW"
        case tail = "TW"
        case cross = "XW"
        case none = ""
    }
    
    /// HW, TW, XW
    public let windType: WindComp.WindType
    
    /// "arrowtriangle.down.fill"
    public let iconName: String?
    
    /// .green, .red, .yellow, .gray, .clear
    public let iconColor: Color?
    
    /// Speed in knots with NO gust
    public let speedString: String
    
    /// Gust in knots
    public let gustString: String
    
    /// Speed only in knots plus "kts" at the end
    public let gustStringKts: String
}
