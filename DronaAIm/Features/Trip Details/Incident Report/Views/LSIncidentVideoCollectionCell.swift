//
//  LSIncidentVideoCollectionCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 26/06/24.
//

import Foundation
import UIKit
import SDWebImage

class LSIncidentVideoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var playIcon: UIButton!
    @IBOutlet weak var viewType: UILabel!

    func configure(with media: LSDAllEventsMedia, event: LSDAllEvents) {
        let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()
            if let urlStr = media.url,  let thumbnail = URL(string: sansataBaseUrl+urlStr)  {
                if media.type == .jpg {
                    self.thumbnailImageView.sd_setImage(with: thumbnail)
                } else {
                    loadThumbnail(from: thumbnail, into: self.thumbnailImageView)
                }
            }
        
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
        titleLabel.text = event.eventID ?? "NA"
        
        if let address = event.address {
                self.addressLabel.text = address
        }
        
    }

}

func loadThumbnail(from videoURL: URL, into imageView: UIImageView) {
    let cacheKey = videoURL.absoluteString
    
    // Check if the image is already cached
    if let cachedImage = SDImageCache.shared.imageFromCache(forKey: cacheKey) {
        // Use the cached image
        imageView.image = cachedImage
    } else {
        // Generate the thumbnail since it is not in the cache
        LSNetworkManager.shared.generateThumbnail(from: videoURL) { thumbnail in
            guard let thumbnail = thumbnail else {
                print("Failed to generate thumbnail")
                return
            }
            // Cache the image
            SDImageCache.shared.store(thumbnail, forKey: cacheKey)
            
            // Display the image
            imageView.image = thumbnail
        }
    }
}

