//
//  AppDelegate.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import AVFoundation
import KEXPPower
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let kexpFlurryKey = "4DYG4DMSNS3S4XCYTCG6"
    private let kexpBaseURL = "https://api.kexp.org"
    private let configurationURL = URL(string: "http://www.kexp.org/content/applications/AppleTV/config/KexpConfigResponse.json")

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
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: ThemeManager.TabBar.font as Any], for: .normal
        )

        let tabBarController = UITabBarController()
        
        let nowPlayingTabBarItem = UITabBarItem()
        nowPlayingTabBarItem.title = "Now Playing"
        let nowPlayingVC = NowPlayingViewController()
        nowPlayingVC.tabBarItem = nowPlayingTabBarItem
        
        let archiveTabBarItem = UITabBarItem()
        archiveTabBarItem.title = "Archive"
        let archiveVC = ArchiveViewController()
        archiveVC.delegate = nowPlayingVC
        archiveVC.tabBarItem = archiveTabBarItem
        
        let settingsTabBarItem = UITabBarItem()
        settingsTabBarItem.title = "Settings"
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = settingsTabBarItem

        let imageView = UIImageView(image: UIImage(named: "kexp"))
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        tabBarController.tabBar.leadingAccessoryView.addSubview(imageView)

        tabBarController.viewControllers = [nowPlayingVC, archiveVC, settingsVC]
         
        return tabBarController
    }
    
    private func setup() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        UIApplication.shared.isIdleTimerDisabled = UserSettingsManager.disableTimer
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        KEXPPower.sharedInstance.setup(
            kexpBaseURL: kexpBaseURL,
            configurationURL: configurationURL,
            availableStreams: retrieveAvailableStreams(),
            selectedArchiveBitRate: ArchiveBitRate.oneTwentyEight,
            defaultStreamIndex: 0,
            backupStreamIndex: 1
        )
        
        let builder = FlurrySessionBuilder()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        builder.withAppVersion(appVersion)
        builder.withLogLevel(FlurryLogLevelAll)
        builder.withCrashReporting(true)
        Flurry.startSession(kexpFlurryKey, with: builder)
    }
    
    private func retrieveAvailableStreams() -> [AvailableStream] {
        let thirtyTwoBitURL = URL(string: "https://kexp-mp3-32.streamguys1.com/kexp32.mp3")!
        let sixtyFourBitURL = URL(string: "https://kexp-aacPlus-64.streamguys1.com/kexp64.aac")!
        let oneTwentyEightBitURL = URL(string: "https://kexp-mp3-128.streamguys1.com/kexp128.mp3")!
        
        let thirtyTwoBit = AvailableStream(streamName: "32 Kbps", streamURL: thirtyTwoBitURL)
        let sixtyFourBit = AvailableStream(streamName: "64 Kbps", streamURL: sixtyFourBitURL)
        let oneTwentyEightBit = AvailableStream(streamName: "128 Kbps", streamURL: oneTwentyEightBitURL)
        
        let availableStream = [oneTwentyEightBit, sixtyFourBit, thirtyTwoBit]
        
        return availableStream
    }
}

