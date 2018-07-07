//
//  File.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/23/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias SongChangeBlock = (_ song: Song?) -> Void
typealias ShowChangeBlock = (_ show: Show?) -> Void
typealias ConfigurationSettingsBlock = (_ kexpConfig: ConfigSettings) -> Void

private let songEndpoint = "http://legacy-api.kexp.org/play/?limit=1"
private let showEndpoint = "http://legacy-api.kexp.org/show/?limit=1"
private let configEndpoint = "http://www.kexp.org/content/applications/AppleTV/config/KexpConfigResponse.json"

class KexpController {

   class func getSong(_ currentTrackUpdate: @escaping SongChangeBlock) {
        Alamofire.request(songEndpoint)
            .responseJSON { response in
                guard let jsonResponse = response.result.value else { currentTrackUpdate(nil); return }
                
                let playResponse = JSON(jsonResponse)
                let play = Play(playResponse)
                currentTrackUpdate(play.songs?.first)
        }
    }
    
    class func getShow(_ currentDjUpdate: @escaping ShowChangeBlock) {
        Alamofire.request(showEndpoint)
            .responseJSON { response in
                guard let jsonResponse = response.result.value else { currentDjUpdate(nil); return }
                
                let showsResponse = JSON(jsonResponse)
                let shows = Shows(showsResponse)
                currentDjUpdate(shows.theShows?.last)
        }
    }
    
    class func getConfig(_ configurationSetup: ConfigurationSettingsBlock) {
        guard let url = URL(string: configEndpoint) else { return }
        guard let kexpConfigData = try? Data(contentsOf: url) else {
            let configSetting = ConfigSettings(nil)
            configurationSetup(configSetting)
            return
        }
        
        do {
            let configJSON = try JSON(data: kexpConfigData)
            let configSetting = ConfigSettings(configJSON)
            configurationSetup(configSetting)
        } catch  let error as NSError  {
            print("Error with config JSON Paring: \(error)")
        }
    }
}
