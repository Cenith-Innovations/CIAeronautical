// ********************** AhasSearchable *********************************
// * Copyright © Cenith Innovations - All Rights Reserved
// * Created on 12/16/20, for CIAeronautical
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AhasSearchable *********************************


import Foundation

/// Any of the myriad ways to search for an area covered by the AHAS website... The most complicated way to find info that no one gives a shit about anyway.
public protocol AhasSearchable {
    var description: String { get }
}
