//
//  LSVideosPopoverViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/27/24.
//

import UIKit
import AVFoundation

protocol LSVideosPopoverDelegate: AnyObject {
    func videoDownloadCompleted(with url: URL?)
    func didTaponMedia(media: LSDAllEventsMedia)

}

class LSVideosPopoverViewController: UIViewController {
    weak var videoCollectionDelegate: LSInsidentsCollectionDelegate?
    weak var videoVCDelegate: LSVideosPopoverDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var eventTypeLabel: UILabel!
    
    var event: LSDAllEvents?
        private var noMedia = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventTypeLabel.text = getIncidentType(eventType: event?.eventType)
        initializeCollectionView()
        
        var updatedEvent: LSDAllEvents?
        updatedEvent = self.event
        let medias = self.event?.media
        let sortedMedia = self.event?.media?.filter {$0.type == .mp4}//.sorted(by: compareMedia)

        if sortedMedia?.count == 0 {
            noMediaAvailable()
        } else {
//            let sortedMedia = self.event?.media?.sorted(by: compareMedia)
            updatedEvent?.media = sortedMedia
            self.event = updatedEvent
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.layoutIfNeeded()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func compareMedia(_ media1: LSDAllEventsMedia, _ media2: LSDAllEventsMedia) -> Bool {
        return media1.type == .mp4 && media2.type == .jpg
    }
    
    func initializeCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 170, height: 210)
        layout.scrollDirection = .horizontal // Change to .vertical for vertical scrolling
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func noMediaAvailable() {
        noMedia = UILabel.init(frame: self.view.bounds)
        noMedia.text = "No Media Available"
        noMedia.textAlignment = .center
        noMedia.textColor = .lightGray
        self.view.addSubview(noMedia)
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

// MARK: LSEventVideosCollectionCellDelegate
extension LSVideosPopoverViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
            self.dismiss(animated: true) {
                self.videoCollectionDelegate?.didTapPlayButton(video: media)
                self.videoVCDelegate?.didTaponMedia(media: media)
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.size.width - 45
        let height = width/1.45
        print("Height = ", height)
        return CGSize(width: width, height: height)
    }
    
    @objc func playVideo(_ sender: UIButton) {
        let medias = self.event?.media
        if let media = medias?[sender.tag]{
            self.dismiss(animated: true) {
                self.videoCollectionDelegate?.didTapPlayButton(video: media)
                self.videoVCDelegate?.didTaponMedia(media: media)
            }
        }
        
    }
    
}

// MARK: LSEventVideosCollectionCellDelegate
extension LSVideosPopoverViewController: LSEventVideosCollectionCellDelegate {
    func didTaponMedia(media: LSDAllEventsMedia) {
        let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()

        if let videoUrl = media.url, let url = URL(string: sansataBaseUrl+videoUrl) {
            if media.type == .mp4 {
                playVieo(url: url)
            } else if media.type == .jpg {
                previewImage(url: url)
            }
        }
    }
    
    func videoDownloadCompleted(with url: URL?) {
        self.dismiss(animated: true) {
            self.videoVCDelegate?.videoDownloadCompleted(with: url)
        }
    }
    
    func playVieo(url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        
        let playerViewController = LSAVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true)

    }
    
    func previewImage(url: URL) {
        let previewVC = LSImagepreviewViewController.instantiate(fromStoryboard: .driver)
        previewVC.previewDelegate = self
        previewVC.url = url
        self.present(previewVC, animated: true)
    }
    
}

extension LSVideosPopoverViewController: LSShowActivityDelegate {
    func showActivityController(url: URL) {
        self.dismiss(animated: true) {
            self.videoVCDelegate?.videoDownloadCompleted(with: url)
        }
    }
    
}
