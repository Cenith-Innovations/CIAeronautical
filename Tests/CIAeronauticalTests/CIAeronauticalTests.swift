import XCTest
@testable import CIAeronautical

final class CIAeronauticalTests: XCTestCase {
    
    func testNOTAMTimeframes() {
        let notam = NOTAM(facilityDesignator: "BAB", icaoId: "KBAB", icaoMessage: "NOT AVAILABLE", traditionalMessage: "WED 2200-0400", featureName: "Runway", notamNumber: "01/001", issueDate: "06/03/2023 0205", createdDate: Date(), startDate: "06/03/2023 0205", effectiveDate: Date().addingTimeInterval(-2400), endDate: "06/03/2023 0205", expirationDate: Date().addingTimeInterval(2400), message: "AERODROME CLSD 19 JUN 0530Z - 30 JUL 2230Z", comment: nil, type: .none)
        let result = NotamFlag.isTimeFrameActive(message: notam.message)
        XCTAssertTrue(result)
    }
    
    func testClosedForTimeFrame() {
        
        // Single day
        let message1 = "RWY 15/33 CLSD FRI 0000-2359"
        let test1 = NotamFlag.closedForTimeFrame(message: message1)
        XCTAssertTrue(test1)
        
//        // End time is next day (2200-0500)
        let message2 = "RWY 15/33 CLSD FRI 0200-2300"
        let test2 = NotamFlag.closedForTimeFrame(message: message2)
        XCTAssertTrue(test2)
//        
//        // Multiple days (spaces)
        let message3 = "RWY 15/33 CLSD SUN MON TUE WED THU FRI SAT 0000-2359"
        let test3 = NotamFlag.closedForTimeFrame(message: message3)
        XCTAssertTrue(test3)
//        
//        // Multiple days (slashes)
        let message4 = "RWY 15/33 CLSD SUN/MON/TUE/WED/THU/FRI/SAT 0000-2359"
        let test4 = NotamFlag.closedForTimeFrame(message: message4)
        XCTAssertTrue(test4)
        
        // Normal closure
        let message5 = "RWY 15/33 CLSD"
        let test5 = NotamFlag.closedForTimeFrame(message: message5)
        XCTAssertTrue(test5)
    }
    
    func testIsTimeFrameActive() {
        let message = "AERODROME CLSD AIRFIELD CLOSED 1 JULY 2023 (1230Z/0530L) &#150; 5 JULY 2023(1230Z/0530L) IN OBSERVANCE OF JULY 4TH HOLIDAY."
        let test = NotamFlag.isTimeFrameActive(message: message)
        XCTAssertFalse(test)
        
        let message2 = "AERODROME CLSD 1 JUL 0700Z - 5 JUL 1300Z"
        let test2 = NotamFlag.isTimeFrameActive(message: message2)
        XCTAssertFalse(test2)
        
        let message3 = "AERODROME CLSD 20 JUN 0000L TO 25 JUN 0600L (20 JUN 0700Z TO 25 JUL 1300Z)."
        let test3 = NotamFlag.isTimeFrameActive(message: message3)
        XCTAssertTrue(test3)
    }
    
    func testHourMinsWithTimezone() throws {
        let word1 = "2359Z"
        let test1 = try XCTUnwrap(NotamFlag.hourMinsWithTimezone(word: word1))
        XCTAssert(test1 == (23, 59))
        
        let word2 = "2359L"
        let test2 = try XCTUnwrap(NotamFlag.hourMinsWithTimezone(word: word2))
        XCTAssert(test2 == (23, 59))
        
        let word3 = "2460Z"
        let test3 = NotamFlag.hourMinsWithTimezone(word: word3)
        XCTAssert(test3 == nil)
        
        let word4 = "2023"
        let test4 = NotamFlag.hourMinsWithTimezone(word: word4)
        XCTAssert(test4 == nil)
        
        let word5 = "0000L"
        let test5 = try XCTUnwrap(NotamFlag.hourMinsWithTimezone(word: word5))
        XCTAssert(test5 == (0, 0))
        
        let word6 = "(0000Z)"
        let test6 = try XCTUnwrap(NotamFlag.hourMinsWithTimezone(word: word6))
        XCTAssert(test6 == (0, 0))
    }
    
    func testIsSingleDateTimeFrameActive() {
        // usually spelled out months have the year right after then hour/mins and abbreviated months have hour/mins right after
        let message1 = "AERODROME CLOSED 5 JULY 2023"
        let test1 = NotamFlag.isSingleDateTimeFrameActive(message: message1,
                                                          expirationDate: Date().addingTimeInterval(-3600))
        XCTAssertFalse(test1)
        
        // "AERODROME CLOSED 14 JULY 2023" // expiration date was 17 JULY 2023 1300Z
        // "AERODROME AIRPORT CLOSED 21 SEP (2200L) - 25 SEP (0600L)"
        // "AERODROME AIRPORT CLOSED 31 AUG (2200L) - 5 SEP (0600L)"
        // "PMD AD AIRPORT CLSD AIRFIELD CLOSED 1 JULY 2023 (1230Z/0530L) &#150; 5 JULY 2023(1230Z/0530L) IN OBSERVANCE OF JULY 4TH HOLIDAY."
        // "AERODROME CLSD 18 JUN 1500L TO 20 JUN 0700L (18 JUN 2200Z TO 20 JUN 1400Z)."
        
        let message2 = "AERODROME CLOSED 21 JULY 2023"
        let test2 = NotamFlag.isSingleDateTimeFrameActive(message: message2,
                                                          expirationDate: Date().addingTimeInterval(3600000000))
        XCTAssertTrue(test2)
        
    }
    
    func testWithinTimeFrame() {
        let test1 = NotamFlag.withinTimeFrame(start: 0, end: 2359, now: 1200)
        let test2 = NotamFlag.withinTimeFrame(start: 2200, end: 900, now: 700)
        let test3 = NotamFlag.withinTimeFrame(start: 0, end: 1000, now: 1200)
        let test4 = NotamFlag.withinTimeFrame(start: 2200, end: 900, now: 1200)
        
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
    
    func testCloudTypeWx() throws {
        
        // TCU only
        let test = WX.cloudTypeWx(rawText: "KCLT 071852Z VRB06KT 10SM SCT055TCU BKN250 34/20 A2987 RMK AO2 LTG DSNT S SLP119 TCU SE-S AND DSNT E AND NW T03440200")
        XCTAssertEqual(test, ["Towering Cumulus"])
        
        // CB only
        let test1 = WX.cloudTypeWx(rawText: "KCLT 071852Z VRB06KT 10SM SCT055CB BKN250 34/20 A2987 RMK AO2 LTG DSNT S SLP119 TCU SE-S AND DSNT E AND NW T03440200")
        XCTAssertEqual(test1, ["Cumulonimbus"])
        
        // TCU and CB
        let test2 = WX.cloudTypeWx(rawText: "KCLT 071852Z VRB06KT 10SM SCT055TCU BKNCB BKN250 34/20 A2987 RMK AO2 LTG DSNT S SLP119 TCU SE-S AND DSNT E AND NW T03440200")
        XCTAssertEqual(test2, ["Towering Cumulus", "Cumulonimbus"])
        
        // TCU and CB with extra CB
        let test3 = WX.cloudTypeWx(rawText: "KCLT 071852Z VRB06KT 10SM SCT055TCU BKN250CB BKN300CB 34/20 A2987 RMK AO2 LTG DSNT S SLP119 TCU SE-S AND DSNT E AND NW T03440200")
        XCTAssertEqual(test3, ["Towering Cumulus", "Cumulonimbus"])
        
        // no cloud types
        let test4 = WX.cloudTypeWx(rawText: "KCLT 071852Z VRB06KT 10SM SCT055 BKN250 BKN300 34/20 A2987 RMK AO2 LTG DSNT S SLP119 TCU SE-S AND DSNT E AND NW T03440200")
        XCTAssertEqual(test4, nil)
        
        // no cloud feet
        let test5 = WX.cloudTypeWx(rawText: "KCLT 071852Z VRB06KT 10SM SCT 34/20 A2987 RMK AO2 LTG DSNT S SLP119 TCU SE-S AND DSNT E AND NW T03440200")
        XCTAssertEqual(test5, nil)
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
        let rawText = "METAR KBAB 210255Z AUTO 18006KT 1/8SM R23L/0500FT HZ SCT055CB BKN200TCU 24/16 A2995 RMK AO2 SLP145 T02420157 55000 $"
        let visibility = 0.8
        let wxString = "BR HZ"
        
        let example = WX.allWx(rawText: rawText, visibility: visibility, wxString: wxString)
        let test = try XCTUnwrap(example)
        XCTAssertEqual(test, "Low Vis, Mist, Haze, Cumulonimbus, Towering Cumulus")
    }
    
    func testAllWxUncleanWxString() throws {
        let rawText = "METAR KBAB 210255Z AUTO 18006KT 1/8SM R15/1200V1400FT HZ SCT055CB 24/16 A2995 RMK AO2 SLP145 T02420157 55000 $"
        let visibility = 0.8
        let wxString = "XX ZZ"
        
        let example = WX.allWx(rawText: rawText, visibility: visibility, wxString: wxString)
        let test = try XCTUnwrap(example)
        XCTAssertEqual(test, "Low Vis, XX ZZ, Cumulonimbus")
    }
    
    func testAllWxNoWx() throws {
//        let rawText = "METAR KBAB 210255Z AUTO 18006KT 6SM 24/16 A2995 RMK AO2 SLP145 T02420157 55000 $"
//        let visibility = 6.0
//
//        let wxString: String? = nil
//
//        let test = WX.allWx(rawText: rawText, visibility: visibility, wxString: wxString)
//        XCTAssertEqual(test, nil)
        
        let test2 = WX.allWx(rawText: "TEMPO 0906/0912 34005G13MPS 4000 -TSRA BKN014CB ", visibility: 2.49, wxString: "-TSRA")
        XCTAssertEqual(test2, "Thunderstorms, Light Rain, Cumulonimbus")
        //WX.allWx(rawText: "TAF ULWC 090200Z 0903/0912 31003G08MPS 6000 BKN017 ", visibility: 3.73, wxString: nil)
    }
    
    func testTafTime() {
        let taf = Forecast.dummyTAF
        let time = taf.timeAgoString(date: taf.validTimeFrom?.addingTimeInterval(-3660), type: .taf).text
        XCTAssertEqual(time, "1h 1m ago")
        
        let taf2 = Forecast.dummyTAF
        let time2 = taf2.timeAgoString(date: taf2.validTimeFrom?.addingTimeInterval(-120), type: .taf).text
        XCTAssertEqual(time2, "2m ago")
    }
}
