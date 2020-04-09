//
//  AppDelegate.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import KEXPPower
import Flurry_iOS_SDK

private let kexpFlurryKey = "4DYG4DMSNS3S4XCYTCG6"
private let kexpBaseURL = "https://api.kexp.org"
private let configurationURL = URL(string:"http://www.kexp.org/content/applications/AppleTV/config/KexpConfigResponse.json")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool
    {
        setup()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        window!.rootViewController = buildUITabBarController()
      
        return true
    }
    
    private func buildUITabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let listenLiveTabBarItem = UITabBarItem()
        listenLiveTabBarItem.title = "Listen Live"
        let listenLiveVC = ListenLiveViewController()
        listenLiveVC.tabBarItem = listenLiveTabBarItem
        
        let archiveTabBarItem = UITabBarItem()
        archiveTabBarItem.title = "Archive"
        let archiveVC = ArchiveViewController()
        archiveVC.tabBarItem = archiveTabBarItem
        
        let settingsTabBarItem = UITabBarItem()
        settingsTabBarItem.title = "Settings"
        let settingsVC = UIViewController()
        settingsVC.tabBarItem = settingsTabBarItem
        
        let nowPlayingTabBarItem = UITabBarItem()
        nowPlayingTabBarItem.title = "Now Playing"
        let nowPlayingVC = UIViewController()
        nowPlayingVC.tabBarItem = nowPlayingTabBarItem
        
        tabBarController.viewControllers = [listenLiveVC, archiveVC, settingsVC, nowPlayingVC]
        tabBarController.selectedIndex = 1
        
        return tabBarController
    }
    
    private func setup() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        KEXPPower.sharedInstance.setup(
            kexpBaseURL: kexpBaseURL,
            configurationURL: configurationURL,
            availableStreams: retrieveAvailableStreams(),
            selectedArchiveBitRate: ArchiveBitRate.oneTwentyEight,
            defaultStreamIndex: 0,
            backupStreamIndex: 1
        )

        Flurry.startSession(kexpFlurryKey)
    }
    
    private func retrieveAvailableStreams() -> [AvailableStream] {
        let thirtyTwoBitURL = URL(string: "https://kexp-mp3-32.streamguys1.com/kexp32.mp3")!
        let sixtyFourBitURL = URL(string: "https://kexp-aacPlus-64.streamguys1.com/kexp64.aac")!
        let oneTwentyEightBitURL = URL(string: "https://kexp-mp3-128.streamguys1.com/kexp128.mp3")!
        
        let thirtyTwoBit = AvailableStream(streamName: "32 Kbps", streamURL: thirtyTwoBitURL)
        let sixtyFourBit = AvailableStream(streamName: "64 Kbps", streamURL: sixtyFourBitURL)
        let oneTwentyEightBit = AvailableStream(streamName: "128 Kbps", streamURL: oneTwentyEightBitURL)
        
        let availableStream = [thirtyTwoBit, sixtyFourBit, oneTwentyEightBit]
        
        return availableStream
    }
}
