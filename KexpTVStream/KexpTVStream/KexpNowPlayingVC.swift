//
//  KexpNowPlayingVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
//import AlamofireImage
//import Alamofire
import KEXPPower
import Flurry_iOS_SDK

private let nowPlayingTimeInterval:TimeInterval = 15.0
private let currentDJTimeInterval:TimeInterval = 60.0

class KexpNowPlayingVC: UIViewController {
    @IBOutlet var kexpLogo: UIImageView!

    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var trackLabel: UILabel!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var djInfoLabel: UILabel!
    
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var albumArtworkView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var albumArtworkButton: ArtworkPlayButton!
    
    private let networkManager = NetworkManager()
    
    fileprivate var playlistArray = [Any]()
    private var currentSong: Play?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addStyleToView()

        KexpController.getConfig { [weak self] (kexpConfig) -> Void in
            guard let strongSelf = self else { return }

            KexpAudioManager.sharedInstance.kexpConfig = kexpConfig
            KexpAudioManager.sharedInstance.delegate = self
            KexpAudioManager.sharedInstance.setupRemoteCommandCenter()

            //strongSelf.loadKexpLogo(kexpConfig.nowPlayingLogo)
            strongSelf.albumArtworkButton.isEnabled = true
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(KexpNowPlayingVC.playKexpAction(_:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue as Int)];
        self.view.addGestureRecognizer(tapRecognizer)
        
        let panGesture  = UIPanGestureRecognizer(target: self, action: #selector(KexpNowPlayingVC.panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
        
        tableView.estimatedRowHeight = 130.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.clear
        tableView.register(KexpPlaylistCell.self, forCellReuseIdentifier: "NowPLayingCell")

        getNowPlayingInfo()
        getCurrentDjInfo()

        Timer.scheduledTimer(timeInterval: nowPlayingTimeInterval, target: self, selector: #selector(KexpNowPlayingVC.getNowPlayingInfo), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: currentDJTimeInterval, target: self, selector: #selector(KexpNowPlayingVC.getCurrentDjInfo), userInfo: nil, repeats: true)
    }

    private func updateAlbumArtWork(_ albumArtUrl: URL?) {
        guard let albumArtUrl = albumArtUrl else { albumArtworkView.image = UIImage(named: "vinylPlaceHolder"); return }
        
//        albumArtworkView.af_setImage(
//            withURL: albumArtUrl,
//            placeholderImage: UIImage(named: "vinylPlaceHolder"),
//            filter: nil
//        )
    }
    
    private func updateAlbumArtWorkButton(with albumArtUrl: URL?) {
        guard let albumArtUrl = albumArtUrl else { albumArtworkButton.setBackgroundImage(UIImage(named: "vinylPlaceHolder"), for: .normal); albumArtworkButton.showingDefaultImage = true; return }
        
       // albumArtworkButton.af_setBackgroundImage(for: .normal, url: albumArtUrl)
        albumArtworkButton.showingDefaultImage = false
    }

    // MARK: - Networking methods
    @objc private func getNowPlayingInfo() {
        networkManager.getPlay(limit: 1) { [weak self] result, playResult in
            guard
                case .success = result,
                let strongSelf = self,
                let playResult = playResult,
                let song = playResult.playlist?.first
            else {
                return
            }
            
            let isAirBreak = song.playType.playTypeId == 4

            DispatchQueue.main.async {
                strongSelf.artistLabel.isHidden = isAirBreak
                strongSelf.trackLabel.text = isAirBreak ? "Air Break..." : "Track:"
                strongSelf.albumLabel.isHidden = isAirBreak
                strongSelf.artistNameLabel.isHidden = isAirBreak
                strongSelf.trackNameLabel.isHidden = isAirBreak
                strongSelf.albumNameLabel.isHidden = isAirBreak
                strongSelf.albumArtworkButton.setBackgroundImage(UIImage(named: "vinylPlaceHolder"), for: .normal)
                strongSelf.albumArtworkButton.showingDefaultImage = isAirBreak

                if
                    !isAirBreak,
                    let lastSongPlayed = strongSelf.currentSong,
                    lastSongPlayed.playId != song.playId
                {
                    strongSelf.playlistArray.insert(lastSongPlayed, at: 0)
                    strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
                
                if !isAirBreak {
                    strongSelf.artistNameLabel.text = song.artist?.name
                    strongSelf.trackNameLabel.text = song.track?.name
                    strongSelf.albumNameLabel.text = song.release?.name
                    strongSelf.updateAlbumArtWorkButton(with: song.release?.largeImageURL)
                }
            }
            
            strongSelf.currentSong = isAirBreak ? nil : song
        }
    }
    
    @objc private func getCurrentDjInfo() {
        KexpController.getShow { [weak self] show -> Void in
            guard let strongSelf = self else { return }
            guard let show = show else { return }
//            guard let showTitle = show.showName else { strongSelf.djInfoLabel.text = "ON NOW: Unknown"; return }
//            guard let djName = show.hosts?.first?.hostName else { strongSelf.djInfoLabel.text = "ON NOW: \(showTitle)"; return }
//
//            strongSelf.djInfoLabel.text = "ON NOW: " + showTitle + " with " + djName
        }
    }
    
    // MARK: - @IBAction
    
    @IBAction func playKexpAction(_ sender: AnyObject) {
//        guard let networkReachabilityManager = NetworkReachabilityManager(), networkReachabilityManager.isReachable
//            else {
//                showAlert("Unable to connect to the Internet")
//                setPlayMode(hardStop: true)
//                return
//        }
//        
//        setPlayMode(hardStop: false)
//        albumArtworkButton.isSelected = KexpAudioManager.sharedInstance.isPlaying()
    }
    
    // Only Show playbutton action image when playlist is not present
    @objc private func panGestureAction(_ sender:UIPanGestureRecognizer) {
        guard playlistArray.count == 0 else { return }
        albumArtworkButton.showPlayButtonActionImage()
    }

    fileprivate func showAlert(_ alertMessage: String) {
        let alert = UIAlertController(title: "Whoops!", message: alertMessage, preferredStyle: .alert)

        let alertAction = UIAlertAction.init(title: "OK", style: .default) { [weak self] action in
            guard let strongSelf = self else { return }
            
            strongSelf.setPlayMode(hardStop: true)
            strongSelf.albumArtworkButton.isSelected = false
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setPlayMode(hardStop: Bool, isBackUpStream:Bool = false) {
        if (!KexpAudioManager.sharedInstance.isPlaying() && !hardStop && !isBackUpStream) {
            KexpAudioManager.sharedInstance.play()
        }
        else {
            albumArtworkButton.isSelected = false
            KexpAudioManager.sharedInstance.pause()
        }
    }
    
    fileprivate func loadKexpLogo(_ logoUrl: String?) {
        guard let imageUrlString = logoUrl as String? else { kexpLogo.image = UIImage(named: "kexp"); return }
        guard let imageUrl = URL(string: imageUrlString) else { kexpLogo.image = UIImage(named: "kexp"); return }

       // kexpLogo.af_setImage(withURL: imageUrl, placeholderImage: UIImage(named: "kexp"), filter: nil)
    }
    
    // MARK: - VC Styling
    
    fileprivate func addStyleToView() {
        let backgroundLayer = KexpStyle.kexpBackgroundGradient()
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, at: 0)
        
        kexpLogo.layer.cornerRadius = 30.0
        kexpLogo.clipsToBounds = true
        
        artistNameLabel.text = "-"
        albumNameLabel.text = "-"
        trackNameLabel.text = "-"
        
        let focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)
        focusGuide.topAnchor.constraint(equalTo: kexpLogo.topAnchor).isActive =  true
        focusGuide.heightAnchor.constraint(equalTo: tableView.heightAnchor).isActive =  true
        focusGuide.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        focusGuide.preferredFocusEnvironments = [albumArtworkButton]
    }
}

extension KexpNowPlayingVC: KexpAudioManagerDelegate {
    func kexpAudioPlayerDidStartPlaying() {
        getNowPlayingInfo()
    }
    
    func kexpAudioPlayerDidStopPlaying(_ hardStop: Bool, backUpStream: Bool) {
        setPlayMode(hardStop: hardStop, isBackUpStream: backUpStream)
    }
    
    func kexpAudioPlayerFailedToPlay() {
        showAlert("The KEXP stream is down, please contact KEXP if the issue persists.")
    }
}

extension KexpNowPlayingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NowPLayingCell", for: indexPath) as! KexpPlaylistCell
        
        let song = playlistArray[indexPath.row]
        cell.configureNowPlayingCell(song)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let previouslyFocusedIndexPath = context.previouslyFocusedIndexPath {
            let previousFocusCell = tableView.cellForRow(at: previouslyFocusedIndexPath)
            previousFocusCell?.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
        
        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            let nextFocusCell = tableView.cellForRow(at: nextFocusedIndexPath)
            nextFocusCell?.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
}
