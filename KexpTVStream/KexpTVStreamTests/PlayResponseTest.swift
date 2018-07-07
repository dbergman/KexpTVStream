//
//  KexpNowPlayingTest.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import XCTest
@testable import KexpTVStream

class PlayResponseTest: XCTestCase {
    lazy var playResponse: Play = self.getPlaySampleResponse()!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPlayResponse() {
        XCTAssertNotNil(playResponse)
        
        XCTAssertTrue(playResponse.count == 2243242)
        XCTAssertTrue(playResponse.next?.absoluteString == "http://legacy-api.kexp.org/play/?limit=20&offset=20")
        XCTAssertTrue(playResponse.songs?.count == 20)
    }
    
    func testSongInPlayPayload() {
        let song = playResponse.songs?[4]
        XCTAssertNotNil(song)
        
        XCTAssertTrue(song?.playId == 2308325)
        XCTAssertTrue(song?.playTypeId == 1)
        XCTAssertTrue(song?.playTypeName == "Media play")
        XCTAssertTrue(song?.airdate != nil)
        XCTAssertTrue(song?.artistId == 8206)
        XCTAssertTrue(song?.artistName == "Jackie DeShannon")
        XCTAssertTrue(song?.isLocal == false)
        XCTAssertTrue(song?.releaseId == 241372)
        XCTAssertTrue(song?.releaseName == "Laurel Canyon")
        XCTAssertTrue(song?.largeImageUrl?.absoluteString == "http://ecx.images-amazon.com/images/I/51nD-OokW1L.jpg")
        XCTAssertTrue(song?.smallImageUrl?.absoluteString == "http://ecx.images-amazon.com/images/I/51nD-OokW1L._SL75_.jpg")
        XCTAssertTrue(song?.releaseEventId == 303605)
        XCTAssertTrue(song?.releaseEventYear == 1968)
        XCTAssertTrue(song?.trackId == 1050495)
        XCTAssertTrue(song?.trackName == "Laurel Canyon")
        XCTAssertTrue(song?.labelId == 4226)
        XCTAssertTrue(song?.labelName == "Imperial")
    }
    
    func testCommentsInSongFromPlayPayload() {
        let song = playResponse.songs?.last
        XCTAssertNotNil(song)
        
        XCTAssertTrue(song?.comments?.count == 1)
        
        let comment = song?.comments?.first
        XCTAssertNotNil(comment)
        
        XCTAssertTrue(comment?.commentid == 949045)
        XCTAssertTrue((comment?.commentText?.count)! > 0)
    }
    
    func testAirBreakInPayload() {
        let airBreak = playResponse.songs?[17]
        XCTAssertNotNil(airBreak)
        
        XCTAssertTrue(airBreak?.playTypeId == 4)
        XCTAssertTrue(airBreak?.playTypeName == "Air break")
    }
    
    func getPlaySampleResponse() -> Play? {
        let JSONData = TestUtilities.getJSONFromTestFile("PlaySampleResponse")
        
        if let JSONData = JSONData {
            let currentlyPlayingResponse = Play(JSONData)
        
            return currentlyPlayingResponse
        }
        
        assertionFailure()
        
        return nil
    }
}
