// ********************** DateFormat *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** DateFormat *********************************


import Foundation

public enum DateFormat {
    case reference
    case ahas
    case notam
    case metarTaf
    case ahas12Hr
    
    @available(*, deprecated, renamed: "value")
    public var rawValue: String {
        return self.value
    }
    
    public var value: String {
        switch self {
        case .reference: return "yyyyMMddHHmmss"
        case .ahas: return "yyyy'-'MM'-'dd' 'HH':'mm':'ss.sss"
        case .notam: return "ddMMMHH:mmyyyy" //16JUL07:392019
        case .metarTaf: return "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        case .ahas12Hr: return "yyyy'-'MM'-'dd' 'HH':'mm'"
        }
    }
}
