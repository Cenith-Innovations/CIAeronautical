// ********************** File *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 3/13/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** File *********************************


import Foundation

public struct Heading: Equatable, CustomStringConvertible {
    public var description: String {
        return "\(direction)"
    }
    
    public static func ==(lhs: Heading, rhs: Heading) -> Bool {
        return lhs.direction == rhs.direction
    }
    
    public static func +(lhs: Heading, rhs: Heading) -> Heading {
        var total = lhs.direction + rhs.direction
        total = total % 360
        if total < 0 {
            total = 360 - abs(total)
            total %= 360
        }
        return Heading(total)
    }
    
    public static func -(lhs: Heading, rhs: Heading) -> Heading {
        var total = lhs.direction - rhs.direction
        total = total % 360
        if total < 0 {
            total = 360 - abs(total)
            total %= 360
        }
        return Heading(total)
    }
    
    public var direction: Int {
        didSet(old) {
            if (direction < 0 || direction > 360){
                direction = direction % 360
            }
        }
    }
    
    public init(_ hdg: Double?) {
        guard let hdg = hdg else {
            direction = 0
            return
        }
        let newDirection = abs(Int(hdg)) % 360
        direction = newDirection
    }
    
    public init(_ hdg: Int) {
        let newDirection = abs(hdg) % 360
        direction = newDirection
    }
}
