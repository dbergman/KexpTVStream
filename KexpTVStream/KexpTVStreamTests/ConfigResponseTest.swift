//
//  KexpConfigResponseUnitTest.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import KexpTVStream

class ConfigResponseTest: XCTestCase {

    lazy var configSettings: ConfigSettings = self.getKexpSettings()

    func testConfigResponse() {
        XCTAssertNotNil(configSettings)

        XCTAssert(configSettings.streamUrl == "http://live-aacplus-64.kexp.org/kexp64.aac", "Kexp Stream URL not present")
        XCTAssert(configSettings.backupStreamUrl == "http://live-mp3-128.kexp.org:8000/listen.pls", "Back up Kexp Stream URL not present")
        
        if let nowPlayingLogo = configSettings.nowPlayingLogo {
            XCTAssert(nowPlayingLogo.count > 0, "Now playing logo is not present")
        }
        else {
            XCTAssertNotNil(configSettings.nowPlayingLogo)
        }
        
        if let updated = configSettings.updated {
            XCTAssert(updated > 0, "Updated timestamp is not present")
        }
        else {
            XCTAssertNotNil(configSettings.updated)
        }
        
    }
    
    func getKexpSettings() -> ConfigSettings {
        let JSONData = TestUtilities.getJSONFromTestFile("ConfigureSampleResponse")
        
        if let JSONData = JSONData {
            let configResponse = ConfigSettings(JSONData)
            
            return configResponse
        }
        
       return ConfigSettings(nil)
    }
}
