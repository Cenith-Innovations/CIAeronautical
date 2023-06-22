import XCTest
@testable import CIAeronautical

final class CIAeronauticalTests: XCTestCase {
    func testExample() {
        let testVar = true
        XCTAssertTrue(testVar)
    }
    
    func testNOTAMTimeframes() {
        let adMessage = "AERODROME CLSD 27 MAY @ 0530L - 30 MAY @ 0530L"
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

    static var allTests = [
        ("testExample", testExample),
    ]
}
