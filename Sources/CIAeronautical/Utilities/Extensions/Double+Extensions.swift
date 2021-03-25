//
//  Double+Extensions.swift
//  
//
//  Created by Caleb Wells on 3/17/21.
//

import Foundation

public extension Double {
    
    func toMoneyString() -> String {
        return "$\(String(format: "%.2f",self))"
    }
    
    //http://www.kylesconverter.com
    var radiansToDegrees: Double                    { return self * 180 / Double.pi }
    var degreesToRadians: Double                    { return self * Double.pi / 180 }
    var metersToFeet: Double                        { return self * 3.2808399 }
    var feetToMeters: Double                        { return self * 0.3048 }
    var metersToNauticalMiles: Double               { return self * 0.0005396118248380001 }
    var metersToStatuteMiles: Double                { return self * 0.000621371 }
    var nauticalMilesToMeters: Double               { return self * 1852 }
    var knotsPHrToNMperMin: Double                  { return self/60.0}
    var hundredthsOfFeetToStatuteMiles: Double      { return (self * 100) / 5280}
    var millibarsToInchesMercury: Double            { self / 33.864 }
    
    func numberOfDecimalPlaces(_ decimalPlaces: Int) -> Double {
        let numberOfDecimalPlaces = String(decimalPlaces)
        let returnDouble = Double("\(String(format: "%.\(numberOfDecimalPlaces)f", self))")
        return returnDouble!
    }
    
    func toStringWithDec(_ num: Int) -> String {
        "\(String(format: "%.\(num)f",self))"
    }
    
    func toStringWithNumberOfDecimal(_ num: Int) -> String {
        return "\(String(format: "%.\(num)f",self))"
    }
    
    func toStringWithZeroDecimal() -> String {
        return "\(String(format: "%.0f",self))"
    }
    
    static func ^(lhs: Double, rhs: Double) -> Double{
        return pow(lhs, rhs)
    }
    
    static func abs(_ value: Double) -> Double{
        return value.abs()
    }
    
    func abs() -> Double{
        return self < 0 ? self * -1 : self
    }
    
    enum CoordType {
        case lat
        case long
    }
    
    func coordToString(decPlaces: Int, coordType: self.CoordType) -> String {
        switch coordType {
        case .lat:
            return self.toStringWithDec(decPlaces).replacingOccurrences(of: "-", with: "") + (self < 0 ? "°S" : "°N")
        case .long:
            return self.toStringWithDec(decPlaces).replacingOccurrences(of: "-", with: "") + (self < 0 ? "°W" : "°E")
        }
    }
}
