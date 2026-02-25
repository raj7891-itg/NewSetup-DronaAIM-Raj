//
//  LSEventsVideosTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/21/24.
//

import UIKit

protocol LSEventVideosTableCellDelegate: AnyObject {
    func videoDownloadCompleted(with url: URL?)
    func didTaponMedia(media: LSDAllEventsMedia)
}

class LSEventVideosTableViewCell: UITableViewCell {
    weak var tableCelleDelegate: LSEventVideosTableCellDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var videoDelegate: LSInsidentsCollectionDelegate?
    private var noMedia = UILabel()
    private var event: LSDAllEvents?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with event: LSDAllEvents) {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 170, height: 210)
        layout.scrollDirection = .horizontal // Change to .vertical for vertical scrolling
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout.invalidateLayout()
        
        var updatedEvent = event
        let sortedMedia = event.media?.filter{ $0.type == .mp4 }//?.sorted(by: compareMedia)
        if sortedMedia?.count == 0 {
            noMediaAvailable()
        } else {
            updatedEvent.media = sortedMedia
            self.event = updatedEvent
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.layoutIfNeeded()
            }
        }
    }
    
    func compareMedia(_ media1: LSDAllEventsMedia, _ media2: LSDAllEventsMedia) -> Bool {
        return media1.type == .mp4 && media2.type == .jpg
    }
        
    private func noMediaAvailable() {
        noMedia = UILabel.init(frame: CGRect(x: 0, y: 20, width: self.frame.size.width, height: self.frame.size.height - 40))
        noMedia.text = "No Media Available"
        noMedia.textAlignment = .center
        noMedia.textColor = .lightGray
        noMedia.layer.borderColor = UIColor.appBorder.cgColor
        noMedia.layer.borderWidth = 2
        noMedia.cornerRadius = 10
        self.addSubview(noMedia)
    }
    
}

extension LSEventVideosTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Ensure the number of sections is correct
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.event?.media?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LSEventVideosCollectionViewCell", for: indexPath) as! LSEventVideosCollectionViewCell
        cell.collectionCellDelegate = self
        cell.downloadIcon.tag = indexPath.row
        cell.shareIcon.tag = indexPath.row

        cell.tag = indexPath.row
        cell.playIcon.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)
        let medias = self.event?.media
        if let media = medias?[indexPath.row] {
            cell.configure(with: media, event: event!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let medias = self.event?.media
        if let media = medias?[indexPath.row] {
            self.videoDelegate?.didTapPlayButton(video: media)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.size.width - 45
        let height = width/1.45
        print("Height = ", height)
        return CGSize(width: width, height: height)
    }
    
    @objc func playVideo(_ sender: UIButton) {
        let medias = self.event?.media
        if let media = medias?[sender.tag] {
            self.videoDelegate?.didTapPlayButton(video: media)
        }
    }
}

extension LSEventVideosTableViewCell: LSEventVideosCollectionCellDelegate {
    func didTaponMedia(media: LSDAllEventsMedia) {
        self.tableCelleDelegate?.didTaponMedia(media: media)
    }
    
    func videoDownloadCompleted(with url: URL?) {
        self.tableCelleDelegate?.videoDownloadCompleted(with: url)
    }
    
}
