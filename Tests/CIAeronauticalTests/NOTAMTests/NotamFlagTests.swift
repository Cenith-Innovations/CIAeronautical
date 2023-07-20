//
//  NotamFlagTests.swift
//  
//
//  Created by Jorge Alvarez on 7/18/23.
//

import XCTest
@testable import CIAeronautical

final class NotamFlagTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testAllActiveFlags() {
        // timeframe is active (somehow) but notam is not active anymore (this will never happen IRL)
        let notam = NOTAM(facilityDesignator: "BAB", icaoId: "KBAB", icaoMessage: "NOT AVAILABLE", traditionalMessage: "WED 2200-0400", featureName: "Runway", notamNumber: "01/001", issueDate: "06/03/2023 0205", createdDate: Date(), startDate: "06/03/2023 0205", effectiveDate: Date().addingTimeInterval(-2400), endDate: "06/03/2023 0205", expirationDate: Date().addingTimeInterval(-2000), message: "AERODROME CLSD 19 JUN 0530Z - 30 JUL 2230Z", comment: nil, type: .none)
        // notam is active and we dont have timeframe so it should return active flag
        let notam2 = NOTAM(facilityDesignator: "BAB", icaoId: "KBAB", icaoMessage: "NOT AVAILABLE", traditionalMessage: "WED 2200-0400", featureName: "Runway", notamNumber: "01/001", issueDate: "06/03/2023 0205", createdDate: Date(), startDate: "06/03/2023 0205", effectiveDate: Date().addingTimeInterval(-2400), endDate: "06/03/2023 0205", expirationDate: Date().addingTimeInterval(2000), message: "AERODROME CLOSED", comment: nil, type: .none)
        // notam is active but timeframe is not active anymore
        let notam3 = NOTAM(facilityDesignator: "BAB", icaoId: "KBAB", icaoMessage: "NOT AVAILABLE", traditionalMessage: "WED 2200-0400", featureName: "Runway", notamNumber: "01/001", issueDate: "06/03/2023 0205", createdDate: Date(), startDate: "06/03/2023 0205", effectiveDate: Date().addingTimeInterval(-2400), endDate: "06/03/2023 0205", expirationDate: Date().addingTimeInterval(2000), message: "AERODROME CLSD 19 JUL 0530Z - 30 JUL 2230Z", comment: nil, type: .none)
        let notams = [notam, notam2, notam3]
        let test = NotamFlag.allActiveFlags(notams: notams)
        XCTAssertEqual(test.count, 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
