// ********************** AlertArea *********************************
// * Copyright © Cenith Innovations, LLC - All Rights Reserved
// * Created on 1/22/21, for 
// * Matthew Elmore <matt@cenithinnovations.com>
// * Unauthorized copying of this file is strictly prohibited
// ********************** AlertArea *********************************


import Foundation

public enum AlertArea: String, AhasSearchable {
    public var description: String { return self.rawValue}
    case ALBEMARLE_NC = "ALBEMARLE, NC"
    case CHERRY_POINT_NC = "CHERRY POINT, NC"
    case COLORADO_SPRINGS_CO = "COLORADO SPRINGS, CO"
    case COLUMBUS_AFB_MS = "COLUMBUS AFB, MS"
    case CORPUS_CHRISTI_TX = "CORPUS CHRISTI, TX"
    case COUPEVILLE_OLF_WA = "COUPEVILLE OLF, WA"
    case DAHLONEGA_GA = "DAHLONEGA, GA"
    case DOTHAN_AL = "DOTHAN, AL"
    case ENID_OK = "ENID, OK"
    case FORT_CAMPBELL_KY = "FORT CAMPBELL, KY"
    case FREDRICK_OK = "FREDRICK, OK"
    case GULF_COAST_GULF_OF_MEXICO = "GULF COAST, GULF OF MEXICO"
    case HONDO_TX = "HONDO, TX"
    case LAUGHLIN_AFB_TX = "LAUGHLIN AFB, TX"
    case LUKE_AFB_AZ = "LUKE AFB, AZ"
    case MCGUIRE_AFB_NJ = "MCGUIRE AFB, NJ"
    case MIAMI_FL = "MIAMI, FL"
    case MOODY_AFB_GA = "MOODY AFB, GA"
    case NELLIS_AFB_NV = "NELLIS AFB, NV"
    case PENSACOLA_FL = "PENSACOLA, FL"
    case RANDOLPH_AFB_TX = "RANDOLPH AFB, TX"
    case SEGUIN_TX = "SEGUIN, TX"
    case SHUQUALAK_COLUMBUS_AFB_ALERT_AREA = "SHUQUALAK (COLUMBUS AFB ALERT AREA)"
    case TRAVIS_AFB_CA = "TRAVIS AFB, CA"
    case USAF_ACADEMY_CO = "USAF ACADEMY, CO"
    case WICHITA_FALLS_TX = "WICHITA FALLS, TX"
    case WICHITA_MCCONNELL_AFB_KS = "WICHITA MCCONNELL AFB, KS"
}

