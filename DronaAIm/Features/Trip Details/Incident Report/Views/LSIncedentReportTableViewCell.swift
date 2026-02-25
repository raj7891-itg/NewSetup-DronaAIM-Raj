//
//  LSIncedentReportTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 26/06/24.
//

import UIKit

protocol LSInsidentsCollectionDelegate: AnyObject {
    func didTapPlayButton(video: LSDAllEventsMedia)
}


class LSIncedentReportTableViewCell: UITableViewCell {
    weak var videoDelegate: LSInsidentsCollectionDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var events: [LSDAllEvents] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.layoutIfNeeded()
            }
        }
    }
    
    var mediaDics: [Int: [LSDAllEventsMedia]] = [:]
    var noMedia = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    func configure(with events: [LSDAllEvents]) {
        let eventType = events.first?.eventType
        titleLabel.text = getIncidentType(eventType: eventType)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 170, height: 210)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .horizontal // Change to .vertical for vertical scrolling
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.register(LSCollectionViewTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LSCollectionViewTitleHeader.identifier)
        var updatedEvents: [LSDAllEvents] = []

        // Process each event individually
        for event in events {
            // Make a mutable copy of the event
            var updatedEvent = event
            // Sort the media items, prioritizing mp4 over jpg
            let sortedMedia = event.media?.filter{ $0.type == .mp4 }//.sorted(by: compareMedia)
            updatedEvent.media = sortedMedia
            updatedEvents.append(updatedEvent)
        }
        self.events = updatedEvents

    }
    
    func compareMedia(_ media1: LSDAllEventsMedia, _ media2: LSDAllEventsMedia) -> Bool {
        return media1.type == .mp4 && media2.type == .jpg
    }
    
    private func noMediaAvailable() {
         noMedia = UILabel.init(frame: self.bounds)
        noMedia.text = "No Media Available"
        noMedia.textAlignment = .center
        noMedia.textColor = .lightGray
        self.addSubview(noMedia)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

extension LSIncedentReportTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return events.count // Ensure the number of sections is correct
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let event = events[section]
        let media = event.media
        return media?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LSIncidentVideoCollectionCell", for: indexPath) as! LSIncidentVideoCollectionCell
        cell.tag = indexPath.row
        cell.playIcon.tag = indexPath.row
        cell.playIcon.titleLabel?.tag = indexPath.section
        cell.playIcon.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)

        let event = events[indexPath.section]
        if let media = event.media?[indexPath.row] {
            cell.configure(with: media, event: event)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = events[indexPath.section]
        let media = event.media?[indexPath.row]
        if let videoMedia = media {
            self.videoDelegate?.didTapPlayButton(video: videoMedia)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 220) 
    }
    
    @objc func playVideo(_ sender: UIButton) {
        let section = sender.titleLabel?.tag ?? 0
        let index = sender.tag
        let event = events[section]
        let media = event.media?[index]

        if let videoMedia = media,  media?.type == .mp4 {
            self.videoDelegate?.didTapPlayButton(video: videoMedia)
        }
    }
}
