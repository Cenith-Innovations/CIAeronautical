// ********************** Loopable *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** Loopable *********************************


import Foundation

public protocol Loopable {
    func allProperties() -> [String: Any]
}

public extension Loopable {
    func allProperties() -> [String: Any] {
        var result: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        for (property, value) in mirror.children {
            guard let property = property else {
                continue
            }
            result[property] = value
        }
        return result
    }
}

