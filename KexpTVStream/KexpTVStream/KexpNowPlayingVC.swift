//
//  KexpNowPlayingVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import AlamofireImage

class KexpNowPlayingVC: UIViewController, KexpAudioManagerDelegate {

    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var kexpLogo: UIImageView!

    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var trackLabel: UILabel!
    @IBOutlet var albumLabel: UILabel!

    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var albumArtworkView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addStyleToView()
        
        KexpAudioManager.sharedInstance.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "playKexpAction:")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)
        
        getNowPlayingInfo()
        NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "getNowPlayingInfo", userInfo: nil, repeats: true)
    }

    private func updateAlbumArtWork(albumArtUrl: String) {
        if let albumArt =  NSURL(string: albumArtUrl) {
            albumArtworkView.af_setImageWithURL(
                albumArt,
                placeholderImage: nil
            )
        }
    }
    
    // MARK: - KexpAudioManagerDelegate Methods
    func KexpAudioPlayerDidStartPlaying() {
        getNowPlayingInfo()
    }
    
    func KexpAudioPlayerDidStopPlaying() {
        setPlayMode(false)
    }
    
    // MARK: - Networking methods
    func getNowPlayingInfo() {
        KexpController.getNowPlayingInfo({ [unowned self] (nowPlaying) -> Void in
            if (nowPlaying.airBreak) {
                self.artistLabel.hidden = true
                self.trackLabel.text = "Air Break..."
                self.albumLabel.hidden = true
                self.artistNameLabel.hidden = true
                self.trackNameLabel.hidden = true
                self.albumNameLabel.hidden = true
                self.albumArtworkView.image = UIImage.init(named: "vinylPlaceHolder")
            }
            else {
                self.artistLabel.hidden = false
                self.trackLabel.hidden = false
                self.albumLabel.hidden = false
                self.artistNameLabel.hidden = false
                self.trackNameLabel.hidden = false
                self.albumNameLabel.hidden = false
                
                self.artistNameLabel.text = nowPlaying.artist
                self.trackNameLabel.text = nowPlaying.songTitle
                self.albumNameLabel.text = nowPlaying.album
                
                if let albumArtUrl =  nowPlaying.albumArtWork {
                    self.updateAlbumArtWork(albumArtUrl)
                }
            }
        })
    }
    
    // MARK: - @IBAction
    @IBAction func playKexpAction(sender: AnyObject) {
        (playPauseButton.selected) ? setPlayMode(false) : setPlayMode(true)
        playPauseButton.selected = !playPauseButton.selected
    }
    
    private func setPlayMode(isPlaying: Bool) {
        if (isPlaying) {
            playPauseButton.setImage(UIImage(named: "pauseButton"), forState: .Normal)
            KexpAudioManager.sharedInstance.play()
        }
        else {
            playPauseButton.setImage(UIImage(named: "playButton"), forState: .Normal)
            KexpAudioManager.sharedInstance.pause()
        }
    }
    
    // MARK: - VC Styling
    private func addStyleToView() {
        let backgroundLayer = KexpStyle.kexpBackgroundGradient()
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, atIndex: 0)
        
        kexpLogo.layer.cornerRadius = 30.0
        kexpLogo.clipsToBounds = true
        
        albumArtworkView.layer.cornerRadius = 30.0
        albumArtworkView.clipsToBounds = true
    }
}
