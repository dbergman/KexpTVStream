//
//  KexpCurrentDJTest.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import XCTest
@testable import KexpTVStream

class ShowResponseTest: XCTestCase {

    lazy var shows: Shows = self.getShowSampleResponse()!

    func testShowResponse() {
        XCTAssertNotNil(shows)
        
        XCTAssertTrue(shows.count == 40289)
        XCTAssertTrue(shows.theShows?.count == 20)
        XCTAssertTrue(shows.next?.absoluteString == "http://legacy-api.kexp.org/show/?limit=20&offset=20")
    }
    
    func testTheShowsInShowPayload() {
        XCTAssertNotNil(shows)
        
        let aShow = shows.theShows?.first
        XCTAssertNotNil(aShow)
        
        XCTAssertTrue(aShow?.showId == 87492)
        XCTAssertTrue(aShow?.programId == 4)
        XCTAssertTrue(aShow?.showName == "Roadhouse")
        XCTAssertTrue((aShow?.showDescription?.count)! > 10)
        XCTAssertTrue(aShow?.airdate != nil)
        XCTAssertTrue(aShow?.tagline == "")
    }
    
    func testHostsFromShowFromShowPayload() {
        XCTAssertNotNil(shows)
        
        let aShow = shows.theShows?.first
        XCTAssertNotNil(aShow)
        
        let host = aShow?.hosts?.first
        
        XCTAssertTrue(host?.hostId == 286)
        XCTAssertTrue(host?.hostName == "Greg Vandy")
        XCTAssertTrue(host?.hostImageUrl?.absoluteString == "https://kexpstorage.blob.core.windows.net/images/hosts/111347")
    }

    func getShowSampleResponse() -> Shows? {
        let JSONData = TestUtilities.getJSONFromTestFile("ShowSampleResponse")
        
        if let JSONData = JSONData {
            let showsResponse =  Shows(JSONData)
            
            return showsResponse
        }
        
        return nil
    }
}
