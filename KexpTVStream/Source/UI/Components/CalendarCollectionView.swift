//
//  CalendarCollectionView.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/8/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit
import KEXPPower

class CalendarCollectionView: UICollectionView {
    private let layout = UICollectionViewFlowLayout()
    private var showsByDate: [[Date: [ArchiveShow]]]?

    init() {
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(frame: CGRect.zero, collectionViewLayout: layout)

        isScrollEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        register(DayCollectionCell.self, forCellWithReuseIdentifier: DayCollectionCell.reuseIdentifier)
        
        dataSource = self
        delegate = self
    }
    
    func configureCalendar(with showsByDate: [[Date: [ArchiveShow]]]) {
        self.showsByDate = showsByDate
        reloadData()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension CalendarCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showsByDate?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCollectionCell.reuseIdentifier, for: indexPath as IndexPath) as! DayCollectionCell
        
        let showByDate = showsByDate?[indexPath.row]
        cell.configure(with: showByDate?.keys.first ?? Date())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let containerWidth = superview?.frame.width else { return CGSize.zero }

        let cellWidth = containerWidth/7.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

private class DayCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "DayCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 5
        
        constructSubviews()
        constructConstraints()
    }
    
    func configure(with date: Date) {
        monthLabel.text = DateFormatter.monthFormatter.string(from: date)
        dayLabel.text = DateFormatter.dayFormatter.string(from: date)
        dayOfWeekLabel.text = DateFormatter.dayOfWeekFormatter.string(from: date)
    }
    
    private func constructSubviews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(monthLabel)
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(dayOfWeekLabel)
    }
    
    private func constructConstraints() {
        NSLayoutConstraint.activate(
            [stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
             stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
             stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
             stackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension DateFormatter {
    public static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    public static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    public static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "eeee"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
