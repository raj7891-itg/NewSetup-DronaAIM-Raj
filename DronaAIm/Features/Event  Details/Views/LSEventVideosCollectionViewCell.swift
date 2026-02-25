//
//  LSEventsVideosCollectionViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/21/24.
//

import UIKit

protocol LSEventVideosCollectionCellDelegate: AnyObject {
    func videoDownloadCompleted(with url: URL?)
    func didTaponMedia(media: LSDAllEventsMedia)
}

class LSEventVideosCollectionViewCell: UICollectionViewCell {
    weak var collectionCellDelegate: LSEventVideosCollectionCellDelegate?
    
    @IBOutlet weak var eventinfoView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var playIcon: UIButton!
    @IBOutlet weak var downloadIcon: UIButton!
    @IBOutlet weak var shareIcon: UIButton!
    @IBOutlet weak var viewType: UILabel!
    var media: LSDAllEventsMedia?
    
    func configure(with media: LSDAllEventsMedia, event: LSDAllEvents) {
        eventinfoView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.media = media
        self.layer.cornerRadius = 10
        thumbnailImageView.layer.cornerRadius = 10
        
        titleLabel.text = getIncidentType(eventType: event.eventType)
        if let eventId = event.eventID {
            self.titleLabel.text = "\(getIncidentType(eventType: event.eventType))(\(String(describing: eventId)))"
        }
        let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()

        if let urlStr = media.url,  let thumbnail = URL(string: sansataBaseUrl+urlStr)  {
            if media.type == .jpg {
                self.thumbnailImageView.sd_setImage(with: thumbnail)
            } else {
                loadThumbnail(from: thumbnail, into: self.thumbnailImageView)
            }
        }

        // Date and Time based TimeZone or Current Timezone
        if let time = media.startTsInMilliseconds {
            if let observation = event.tzAbbreviation {
                let date = LSDateFormatter.shared.convertTimestampToDate(from: time, format: .MMMdYYYHmmaComma, timezone: observation)
                self.dateLabel.text = date
            } else {
                let date = LSDateFormatter.shared.convertTimestampToDate(from: time, format: .MMMdYYYHmmaComma)
                self.dateLabel.text = date
            }
        }
        
        if media.type == .mp4 {
            playIcon.isHidden = false
        } else {
            playIcon.isHidden = true
        }
        
        if media.camera == 1 {
            viewType.text = "  Road View  "
        } else {
            viewType.text = "  Driver view  "
        }

        if let address = event.address {
            self.addressLabel.text = address
        }
        
    }
    
    @IBAction func downloadVideoAction(_ sender: Any) {
        let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()

        Task {
            LSProgress.show(in: self, message: "Downloading...")
            if let mp4Media = media, let mp4UrlString = mp4Media.url, let mp4Url = URL(string: sansataBaseUrl + mp4UrlString) {
                do {
                    let url = try await LSNetworkManager.shared.downloadAndSaveFile(from: mp4Url)
                    self.collectionCellDelegate?.videoDownloadCompleted(with: url)
                    LSProgress.hide(from: self)
                } catch {
                    LSProgress.hide(from: self)
                }
            }
        }
    }
    
    @IBAction func shareVideoAction(_ sender: Any) {
        let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()

        Task {
            LSProgress.show(in: self, message: "")
            if let mp4Media = media, let mp4UrlString = mp4Media.url, let mp4Url = URL(string: sansataBaseUrl + mp4UrlString) {
                do {
                    let requestbody = LSAliasRequest(url: mp4Url.absoluteString)
                    let response: LSAliasModel = try await LSNetworkManager.shared.post("", body: requestbody, apiType: .alias)
                    let url = URL(string: response.aliasURL)
                    self.collectionCellDelegate?.videoDownloadCompleted(with: url)
                    LSProgress.hide(from: self)
                } catch {
                    LSProgress.hide(from: self)
                }
            }
        }
    }

    
}
