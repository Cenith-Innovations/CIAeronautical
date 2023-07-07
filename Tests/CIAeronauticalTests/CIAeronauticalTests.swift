import XCTest
@testable import CIAeronautical

final class CIAeronauticalTests: XCTestCase {
    
    func testNOTAMTimeframes() {
        let notam = NOTAM(facilityDesignator: "BAB", icaoId: "KBAB", icaoMessage: "NOT AVAILABLE", traditionalMessage: "WED 2200-0400", featureName: "Runway", notamNumber: "01/001", issueDate: "06/03/2023 0205", createdDate: Date(), startDate: "06/03/2023 0205", effectiveDate: Date().addingTimeInterval(-2400), endDate: "06/03/2023 0205", expirationDate: Date().addingTimeInterval(2400), message: "AERODROME CLSD 19 JUN 0530Z - 30 JUN 2230Z", comment: nil, type: .none)
        let result = NOTAM.isTimeFrameActive(message: notam.message)
        XCTAssertTrue(result)
    }
    
    func testClosedForTimeFrame() {
        
        // Single day
        let message1 = "RWY 15/33 CLSD THU 0000-2359"
        let test1 = NOTAM.closedForTimeFrame(message: message1)
        XCTAssertTrue(test1)
        
//        // End time is next day (2200-0500)
        let message2 = "RWY 15/33 CLSD THU 2200-1900"
        let test2 = NOTAM.closedForTimeFrame(message: message2)
        XCTAssertTrue(test2)
//        
//        // Multiple days (spaces)
        let message3 = "RWY 15/33 CLSD SUN MON TUE WED THU FRI SAT 0000-2359"
        let test3 = NOTAM.closedForTimeFrame(message: message3)
        XCTAssertTrue(test3)
//        
//        // Multiple days (slashes)
        let message4 = "RWY 15/33 CLSD SUN/MON/TUE/WED/THU/FRI/SAT 0000-2359"
        let test4 = NOTAM.closedForTimeFrame(message: message4)
        XCTAssertTrue(test4)
        
        // Normal closure
        let message5 = "RWY 15/33 CLSD"
        let test5 = NOTAM.closedForTimeFrame(message: message5)
        XCTAssertTrue(test5)
    }
    
    func testIsTimeFrameActive() {
        let message = "AERODROME CLSD AIRFIELD CLOSED 1 JULY 2023 (1230Z/0530L) &#150; 5 JULY 2023(1230Z/0530L) IN OBSERVANCE OF JULY 4TH HOLIDAY."
        let test = NOTAM.isTimeFrameActive(message: message)
        XCTAssertFalse(test)
        
        let message2 = "AERODROME CLSD 1 JUL 0700Z - 5 JUL 1300Z"
        let test2 = NOTAM.isTimeFrameActive(message: message2)
        XCTAssertFalse(test2)
        
        let message3 = "AERODROME CLSD 20 JUN 0000L TO 25 JUN 0600L (20 JUN 0700Z TO 25 JUN 1300Z)."
        let test3 = NOTAM.isTimeFrameActive(message: message3)
        XCTAssertTrue(test3)
    }
    
    func testWithinTimeFrame() {
        let test1 = NOTAM.withinTimeFrame(start: 0, end: 2359, now: 1200)
        let test2 = NOTAM.withinTimeFrame(start: 2200, end: 900, now: 700)
        let test3 = NOTAM.withinTimeFrame(start: 0, end: 1000, now: 1200)
        let test4 = NOTAM.withinTimeFrame(start: 2200, end: 900, now: 1200)
        
        XCTAssertTrue(test1)
        XCTAssertTrue(test2)
        XCTAssertFalse(test3)
        XCTAssertFalse(test4)
    }
    
    func testCleanWx() throws {
        let word1 = "TSRA"
        let test1 = try XCTUnwrap(WX.cleanWx(word: word1))
        XCTAssertEqual(test1, "Thunderstorms Rain")
        
        let word2 = "TSXX"
        let test2 = WX.cleanWx(word: word2)
        XCTAssertEqual(test2, nil)
    }
    
    func testCleanWxString() {
        let wxString1 = "HZ RA"
        let test1 = WX.cleanWxString(wx: wxString1)?.joined(separator: ", ")
        XCTAssertEqual(test1, "Haze, Rain")
        
        let wxString2 = "-RA"
        let test2 = WX.cleanWxString(wx: wxString2)?.joined(separator: ", ")
        XCTAssertEqual(test2, "Light Rain")
        
        let wxString3 = "BCFG"
        let test3 = WX.cleanWxString(wx: wxString3)?.joined(separator: ", ")
        XCTAssertEqual(test3, "Patchy Fog")
        
        let wxString4 = "-RASH"
        let test4 = WX.cleanWxString(wx: wxString4)?.joined(separator: ", ")
        XCTAssertEqual(test4, "Light Rain Showers")
        
        let wxString5 = "-TSRA"
        let test5 = WX.cleanWxString(wx: wxString5)?.joined(separator: ", ")
        XCTAssertEqual(test5, "Thunderstorms, Light Rain")
    }
    
    func testCloudTypeWx() {
        let skyConditions = [SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 20000, cloudType: "CB"),
                             SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 25000, cloudType: "TCU"),
                             SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 30000, cloudType: "CB")]
        let test = WX.cloudTypeWx(skyConditions: skyConditions)
        XCTAssertEqual(test, ["Cumulonimbus", "Towering Cumulus"])
    }

    func testlowVisWx() throws {
        let rawText = "METAR KBAB 210255Z AUTO 18006KT 1/8SM R15/1200V1400FT R33/1300FT HZ CLR 24/16 A2995 RMK AO2 SLP145 T02420157 55000 $"
        let rvrs = WX.lowVisWx(rawText: rawText, visibility: 0.13)
        let test = try XCTUnwrap(rvrs)
        let solution = [WX.RVR(runway: "Rwy 15 RVR", range: "1200\' to 1400\'"), WX.RVR(runway: "Rwy 33 RVR", range: "1300\'")]
        XCTAssertTrue(test == solution)
    }
    
    func testRvrComponents() throws {
        let text = WX.rvrComponents(rvr: "23L/0500")
        let test = try XCTUnwrap(text)
        let solution = WX.RVR(runway: "Rwy 23L RVR", range: "500m")
        XCTAssertTrue(test == solution)
    }
    
    func testRvrString() {
        
        // Single value
        let test1 = WX.rvrString(word: "0500")
        XCTAssertEqual(test1, "500m")
        
        // Range (V)
        let test2 = WX.rvrString(word: "1200V1400FT")
        XCTAssertEqual(test2, "1200\' to 1400\'")
        
        // Greater than (P)
        let test3 = WX.rvrString(word: "P0600FT")
        XCTAssertEqual(test3, "Greater than 600\'")
        
        // Less than (M)
        let test4 = WX.rvrString(word: "M6000FT")
        XCTAssertEqual(test4, "Less than 6000\'")
        
        // Invalid Range
        let test5 = WX.rvrString(word: "1200V")
        XCTAssertEqual(test5, "1200V")
        
        // No Numbers
        let test6 = WX.rvrString(word: "Unknown")
        XCTAssertEqual(test6, "Unknown")
    }
    
    func testAllWx() throws {
        let rawText = "METAR KBAB 210255Z AUTO 18006KT 1/8SM R23L/0500FT HZ CLR 24/16 A2995 RMK AO2 SLP145 T02420157 55000 $"
        let visibility = 0.8
        let wxString = "BR HZ"
        let skyConditions = [SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 20000, cloudType: "CB"),
                                                 SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 25000, cloudType: "TCU"),
                                                 SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 30000, cloudType: "CB")]
        
        let example = WX.allWx(rawText: rawText, visibility: visibility, wxString: wxString, skyConditions: skyConditions)
        let test = try XCTUnwrap(example)
        XCTAssertEqual(test, "Low Vis, Mist, Haze, Cumulonimbus, Towering Cumulus")
    }
    
    func testAllWxUncleanWxString() throws {
        let rawText = "METAR KBAB 210255Z AUTO 18006KT 1/8SM R15/1200V1400FT HZ CLR 24/16 A2995 RMK AO2 SLP145 T02420157 55000 $"
        let visibility = 0.8
        let wxString = "XX ZZ"
        let skyConditions = [SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 20000, cloudType: "CB"),
                                                 SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 25000),
                                                 SkyCondition(skyCover: "BKN", cloudBaseFtAgl: 30000, cloudType: "CB")]
        
        let example = WX.allWx(rawText: rawText, visibility: visibility, wxString: wxString, skyConditions: skyConditions)
        let test = try XCTUnwrap(example)
        XCTAssertEqual(test, "Low Vis, XX ZZ, Cumulonimbus")
    }
    
    func testAllWxNoWx() throws {
        let rawText = "METAR KBAB 210255Z AUTO 18006KT 6SM CLR 24/16 A2995 RMK AO2 SLP145 T02420157 55000 $"
        let visibility = 6.0
        
        let wxString: String? = nil
        
        let test = WX.allWx(rawText: rawText, visibility: visibility, wxString: wxString, skyConditions: nil)
        XCTAssertEqual(test, nil)
    }
}
