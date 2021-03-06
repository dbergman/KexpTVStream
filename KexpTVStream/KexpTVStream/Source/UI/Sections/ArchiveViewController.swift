//
//  ArchiveViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/8/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower
import UIKit

protocol ArchiveDelegate: class {
    func playShow(archiveShow: ArchiveShow)
}

class ArchiveViewController: BaseViewController {
    private enum Style {
        static let archiveTopInset = CGFloat(40)
        static let containerViewPadding = CGFloat(100)
        static let containerViewTopInset = CGFloat(40)
    }
    
    private let archiveManager = ArchiveManager()
    private let calendarCollectionVC = ArchiveCalendarCollectionVC(displayType: .full)
    private let hostArchieveCollectionVC = ArchiveDetailCollectionVC(with: .host)
    private let showArchieveCollectionVC = ArchiveDetailCollectionVC(with: .show)
    private let genreArchieveCollectionVC = ArchiveDetailCollectionVC(with: .genre)
    
    private lazy var archieveCollectionViews: [UIViewController] = {
        return [calendarCollectionVC,
                hostArchieveCollectionVC,
                showArchieveCollectionVC,
                genreArchieveCollectionVC]
    } ()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let archiveSelectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.Archive.Select.font
        label.textColor = ThemeManager.Archive.Select.textColor
        label.textAlignment = .center
        return label
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let font: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: ThemeManager.Archive.Menu.font as Any]
        segmentedControl.setTitleTextAttributes(font, for: .normal)
        segmentedControl.insertSegment(withTitle: "Date", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Host", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "Show", at: 2, animated: true)
        segmentedControl.insertSegment(withTitle: "Genre", at: 3, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(handleUpdate(sender:)), for: .valueChanged)
        return segmentedControl
    }()

    weak var delegate: ArchiveDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        archiveManager.retrieveArchieveShows { [weak self] showsByDate, showsByShowName, showsByHostName, showsGenre in
            guard let strongSelf = self else { return }
            
            strongSelf.calendarCollectionVC.view.isHidden = false
            strongSelf.archiveSelectionLabel.text = "Select a Date"
            
            strongSelf.calendarCollectionVC.configure(with: showsByDate)
            
            let showContent = showsByShowName.map { ArchiveDetailCollectionVC.ArchiveContent($0) }
            strongSelf.showArchieveCollectionVC.configure(with: showContent)
            
            let hostContent = showsByHostName.map { ArchiveDetailCollectionVC.ArchiveContent($0) }
            strongSelf.hostArchieveCollectionVC.configure(with: hostContent)
            
            let genreContent = showsGenre.map { ArchiveDetailCollectionVC.ArchiveContent($0) }
            strongSelf.genreArchieveCollectionVC.configure(with: genreContent)            
        }
    }
    
    override func setupViews() {
        view.backgroundColor = .white
    
        calendarCollectionVC.archiveCalendarDelegate = self
        hostArchieveCollectionVC.archiveDetailDelegate = self
        showArchieveCollectionVC.archiveDetailDelegate = self
        genreArchieveCollectionVC.archiveDetailDelegate = self
    }
    
    override func constructSubviews() {
        view.addSubview(segmentedControl)
        view.addSubview(archiveSelectionLabel)
        view.addSubview(containerView)
        
        archieveCollectionViews.forEach { cv in
            cv.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(cv.view)
            addChild(cv)
            cv.didMove(toParent: self)
            cv.view.isHidden = true
        }
    }
    
    override func constructConstraints() {
        NSLayoutConstraint.activate(
            [segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        NSLayoutConstraint.activate(
            [archiveSelectionLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: Style.archiveTopInset),
             archiveSelectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        NSLayoutConstraint.activate(
            [containerView.topAnchor.constraint(equalTo: archiveSelectionLabel.bottomAnchor, constant: Style.containerViewTopInset),
             containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
             containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
             containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        archieveCollectionViews.forEach { cv in
            NSLayoutConstraint.activate(
                [cv.view.topAnchor.constraint(equalTo: self.containerView.topAnchor),
                 cv.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
                 cv.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
                 cv.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
                ])
        }
    }
    
   @objc private func handleUpdate(sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
    
        _ = archieveCollectionViews.map { $0.view.isHidden = true }
    
        if selectedIndex == 0  {
            calendarCollectionVC.view.isHidden = false
            archiveSelectionLabel.text = "Select a Date"
        } else if selectedIndex == 1 {
            hostArchieveCollectionVC.view.isHidden = false
            archiveSelectionLabel.text = "Select a Host"
        } else if selectedIndex == 2 {
            showArchieveCollectionVC.view.isHidden = false
            archiveSelectionLabel.text = "Select a Show"
        } else if selectedIndex == 3 {
            archiveSelectionLabel.text = "Select a Genre"
            genreArchieveCollectionVC.view.isHidden = false
        }
    }
}

extension ArchiveViewController: ArchiveCalendarDelegate {
    func didSelectArchieveShow(archiveShow: ArchiveShow) {
        delegate?.playShow(archiveShow: archiveShow)
    }
    
    func didSelectArchieveDate(archiveShows: [ArchiveShow]) {
        let showsVC = ArchiveDetailCollectionVC(with: .day)
        showsVC.archiveDetailDelegate = self
        let archiveContent = archiveShows.map { ArchiveDetailCollectionVC.ArchiveContent(.day, archiveShow: $0) }.compactMap { $0 }
        
        showsVC.configure(with: archiveContent)
        let navigationController = UINavigationController(rootViewController: showsVC)
        navigationController.navigationBar.titleTextAttributes =
             [NSAttributedString.Key.font: ThemeManager.Archive.Details.Title.font as Any,
              NSAttributedString.Key.foregroundColor: ThemeManager.Archive.Details.Title.textColor]

        showsVC.title = "Select a Show"

        show(navigationController, sender: self)
    }
}

extension ArchiveViewController: ArchiveDetailDelegate {
    func didSelectArchive(archiveShows: [ArchiveShow], type: ArchiveDetailCollectionVC.ArchiveType) {
        if
            let selectedShow = archiveShows.first,
            type == .day
        {
            delegate?.playShow(archiveShow: selectedShow)
        } else {
            let archiveCalendarVC = ArchiveCalendarCollectionVC(displayType: .detail)
            archiveCalendarVC.archiveCalendarDelegate = self
            
            let dateShows = archiveShows.map { DateShows(date: $0.showEndTime ?? Date(), shows: [$0]) }
            archiveCalendarVC.configure(with: dateShows)
            let navigationController = UINavigationController(rootViewController: archiveCalendarVC)
            navigationController.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.font: ThemeManager.Archive.Details.Title.font as Any,
                 NSAttributedString.Key.foregroundColor: ThemeManager.Archive.Details.Title.textColor]

            let vcTitle: String
            
            switch type {
            case .show: vcTitle = "\(archiveShows.first?.show.programName ?? "")"
            case .host: vcTitle = "\(archiveShows.first?.show.hostNames?.first ?? "")"
            case .genre: vcTitle = "\(archiveShows.first?.show.programTags ?? "")"
            default: vcTitle = ""
            }
            
            
            archiveCalendarVC.title = vcTitle
            show(navigationController, sender: self)
        }
    }
}
