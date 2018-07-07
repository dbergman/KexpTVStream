//
//  KexpAudioManager.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/20/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit
import AlamofireImage

protocol KexpAudioManagerDelegate {
    func kexpAudioPlayerDidStartPlaying()
    func kexpAudioPlayerDidStopPlaying(_ hardStop: Bool, backUpStream: Bool)
    func kexpAudioPlayerFailedToPlay()
}

class KexpAudioManager: NSObject {
    static let sharedInstance : KexpAudioManager = {
            return KexpAudioManager()
        }()

    var kexpConfig: ConfigSettings? {
        didSet {
            currentKexpUrlString = kexpConfig?.streamUrl
        }
    }
    
    var audioPlayerItem: AVPlayerItem?
    var audioPlayer: AVPlayer?
    
    var currentKexpUrlString: String?
    
	let downloader = ImageDownloader()
    
    var delegate: KexpAudioManagerDelegate?

    deinit {
        deInitStream()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initStream() {
        guard let currentKexpUrlString = currentKexpUrlString else { return }
        guard let streamURL = URL(string: currentKexpUrlString) else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(KexpAudioManager.handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KexpAudioManager.handleInterruption(_:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        
        if audioPlayerItem != nil {
            deInitStream()
        }

        audioPlayerItem = AVPlayerItem(url: streamURL)
        audioPlayerItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "timedMetadata", options: .new, context: nil)

        if let audioPlayerItem = audioPlayerItem {
            audioPlayer = AVPlayer(playerItem: audioPlayerItem)
            
            _ = try? AVAudioSession.sharedInstance().setActive(true)
            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        }
    }
    
    private func deInitStream() {
        audioPlayerItem?.removeObserver(self, forKeyPath: "status")
        audioPlayerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        audioPlayerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        audioPlayerItem?.removeObserver(self, forKeyPath: "timedMetadata")
        
        audioPlayer = nil;
        audioPlayerItem = nil;
    }
    
    func play() {
        initStream()
        audioPlayer?.play()
    }
    
    func pause() {
        audioPlayer?.pause()
        deInitStream()
    }
    
    func isPlaying() -> Bool {
        guard let audioRate = audioPlayer?.rate else { return false }
        return Double(audioRate) > 0.0 && audioPlayer?.error == nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        guard let delegate = delegate else { return }
        guard let kexpConfig = kexpConfig else { return }

        if keyPath == "status" {
            if playerItem.status == .readyToPlay {
                delegate.kexpAudioPlayerDidStartPlaying()
                currentKexpUrlString = kexpConfig.streamUrl
            }
            else if playerItem.status == .failed {
                deInitStream()
                delegate.kexpAudioPlayerDidStopPlaying(false, backUpStream: currentKexpUrlString == kexpConfig.backupStreamUrl)
                
                if currentKexpUrlString == kexpConfig.backupStreamUrl {
                    delegate.kexpAudioPlayerFailedToPlay()
                } else {
                    currentKexpUrlString = kexpConfig.backupStreamUrl
                }
            }
        }
    }
    
    func setupRemoteCommandCenter() {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        remoteCommandCenter.pauseCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(KexpAudioManager.pauseEvent))
    }
    
    @objc func pauseEvent() {
        delegate?.kexpAudioPlayerDidStopPlaying(false, backUpStream: false)
        pause()
    }
    
    // MARK: - NSNotification
    // This is called when audio is taken from another app. Sending a HardStop when an AVAudioSessionInterruptionType is fired
    @objc func handleInterruption(_ notification: Notification) {
        guard let interruptionTypeUInt = (notification as NSNotification).userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }

        if let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeUInt) {
            if interruptionType == .began || interruptionType == .ended {
                pause()
                delegate?.kexpAudioPlayerDidStopPlaying(true, backUpStream: false)
            }
        }
    }
    
    func updateNowPlaying(song: Song) {
        let trackName = song.trackName ?? ""
        let artistName = song.artistName ?? ""
        let albumName = song.releaseName ?? ""
        
        let trackItem = AVMutableMetadataItem()
        trackItem.identifier = AVMetadataIdentifier.commonIdentifierTitle
        trackItem.locale = NSLocale.current
        trackItem.value = trackName as NSString
        trackItem.keySpace = AVMetadataKeySpace.common
        
        let albumNameItem = AVMutableMetadataItem()
        albumNameItem.identifier = AVMetadataIdentifier.commonIdentifierAlbumName
        albumNameItem.locale = NSLocale.current
        albumNameItem.value = albumName as NSString
        albumNameItem.keySpace = AVMetadataKeySpace.common
        
        let artistNameItem = AVMutableMetadataItem()
        artistNameItem.identifier = AVMetadataIdentifier.commonIdentifierArtist
        artistNameItem.locale = NSLocale.current
        artistNameItem.value = artistName as NSString
        artistNameItem.keySpace = AVMetadataKeySpace.common
        
        let artworkMetadataItem = AVMutableMetadataItem()
        artworkMetadataItem.locale = Locale.current
        artworkMetadataItem.identifier = AVMetadataIdentifier.commonIdentifierArtwork
        
        if let albumArtUrl = song.largeImageUrl {
            let urlRequest = URLRequest(url: albumArtUrl)

            downloader.download(urlRequest) { response in
                guard let albumArtImage = response.result.value else { return }

                artworkMetadataItem.value = albumArtImage as? NSCopying & NSObjectProtocol
                self.audioPlayerItem?.externalMetadata.append(artistNameItem)
                self.audioPlayerItem?.externalMetadata.append(trackItem)
                self.audioPlayerItem?.externalMetadata.append(albumNameItem)
                self.audioPlayerItem?.externalMetadata.append(artworkMetadataItem)

                let artWork = MPMediaItemArtwork(boundsSize: albumArtImage.size, requestHandler: { _ in
                    return albumArtImage
                })
                
                let nowPlayingInfo = [MPMediaItemPropertyArtist : artistName, MPMediaItemPropertyTitle : trackName, MPMediaItemPropertyArtwork : artWork] as [String : Any]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        } else {
            guard let placeHolderAlbumArt = UIImage(named: "vinylPlaceHolder") else { return }
            
            artworkMetadataItem.value = placeHolderAlbumArt as? NSCopying & NSObjectProtocol
            self.audioPlayerItem?.externalMetadata.append(artistNameItem)
            self.audioPlayerItem?.externalMetadata.append(trackItem)
            self.audioPlayerItem?.externalMetadata.append(albumNameItem)
            self.audioPlayerItem?.externalMetadata.append(artworkMetadataItem)

            let artWork = MPMediaItemArtwork(boundsSize: placeHolderAlbumArt.size, requestHandler: { _ in
                return placeHolderAlbumArt
            })
            
            let nowPlayingInfo = [MPMediaItemPropertyArtist : artistName, MPMediaItemPropertyTitle : trackName, MPMediaItemPropertyArtwork : artWork] as [String : Any]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
}
