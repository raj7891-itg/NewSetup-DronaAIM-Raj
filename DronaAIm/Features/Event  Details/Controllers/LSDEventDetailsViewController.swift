//
//  LSDEventDetailsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 01/07/24.
//

import UIKit
import MapKit
import AVKit
import AVFoundation

class LSDEventDetailsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var event: LSDAllEvents!
    var liveTrack: LSDTripLiveTrackModel?
    let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableView()
        self.title = getIncidentType(eventType: event.eventType)
        if let eventID = event.eventID {
            self.title = "\(getIncidentType(eventType: event.eventType))(\(String(describing: eventID)))"
        }
        fetchTripLiveTrack()
    }
    
    private func initializeTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150 // Estimate row height
        tableView.sectionHeaderTopPadding = 1
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0,
                                                         width: self.tableView.bounds.size.width,
                                                         height: .leastNonzeroMagnitude))
        
        
    }
    
    private func fetchTripLiveTrack()  {
        LSProgress.show(in: self.view)
        Task {
            if let tripID = event.tripID {
                let endpoint = LSAPIEndpoints.liveTrackByTripId(for: tripID)
                do {
                    let response: LSDTripLiveTrackModel = try await LSNetworkManager.shared.get(endpoint)
                    self.liveTrack = response
                    LSProgress.hide(from: self.view)
                    self.tableView.reloadData()
                } catch {
                    LSProgress.hide(from: self.view)
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                }
            }
        }
    }
    
}

extension LSDEventDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            return self.tableView(tableView, detailsCellForRowAt: indexPath)
        }  else if indexPath.section == 0 && indexPath.row == 1 {
            return self.tableView(tableView, eventVideosCellForRowAt: indexPath)
        } else if indexPath.section == 0 && indexPath.row == 2 {
            return self.tableView(tableView, safetyCellForRowAt: indexPath)
        } else if indexPath.section == 0 && indexPath.row == 3  {
            return self.tableView(tableView, mapCellForRowAt: indexPath)
        } else {
            return self.tableView(tableView, eventsTrackerCellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, detailsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSDEventDetailsTableViewCell", for: indexPath) as? LSDEventDetailsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, eventVideosCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSEventVideosTableViewCell", for: indexPath) as? LSEventVideosTableViewCell else {
            return UITableViewCell()
        }
        cell.tableCelleDelegate = self
        cell.videoDelegate = self
        cell.configure(with: event)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, safetyCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSDEventSafetyTableViewCell", for: indexPath) as? LSDEventSafetyTableViewCell else {
            return UITableViewCell()
        }
        if let eventType = event.eventType {
            cell.config(for: eventType)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, mapCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LSMapCardTableViewCell", for: indexPath) as! LSMapCardTableViewCell
        if let trip = liveTrack {
            cell.configure(with: trip)
        }
        cell.mapView.layer.borderColor = UIColor.appBorder.cgColor
        cell.mapView.layer.borderWidth = 1
        cell.mapView.layer.cornerRadius = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, eventsTrackerCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LSTripEventTrackCell", for: indexPath) as! LSTripEventTrackCell
        cell.lineView.isHidden = false
        if indexPath.row == 0, let liveTrack = liveTrack {
            cell.displayLocation(liveTrack: liveTrack, coordinateType: .start)
        } else if indexPath.row == 2, let liveTrack = liveTrack {
            cell.displayLocation(liveTrack: liveTrack, coordinateType: .end)
            cell.lineView.isHidden = true
        } else {
            cell.config(with: event, indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? LSMapCardTableViewCell {
                if let liveTrack = liveTrack  {
                    let startEndCoordinates = liveTrack.getCoordinates()
                    let coordinate: LSCoordinate?
                    if indexPath.row == 0 {
                         coordinate = startEndCoordinates.first(where: { $0.type == .start})
                        if  !(coordinate?.coordinate.latitude.isZero ?? false), let lat = coordinate?.coordinate.latitude, let long = coordinate?.coordinate.longitude  {
                            cell.animateTo(latitude: lat, longitude: long)
                        } else {
                            self.view.makeToast("Location not available", position: .bottom)
                        }
                    } else if indexPath.row == 2 {
                         coordinate = startEndCoordinates.first(where: { $0.type == .end})
                        if  !(coordinate?.coordinate.latitude.isZero ?? false), let lat = coordinate?.coordinate.latitude, let long = coordinate?.coordinate.longitude  {
                            cell.animateTo(latitude: lat, longitude: long)
                        } else {
                            self.view.makeToast("Location not available", position: .bottom)
                        }
                    } else {
                        if let gnsInfo = event.gnssInfo, gnsInfo.isValid ?? false {
                            cell.showMarker(for: event)
                        } else {
                            self.view.makeToast("Location not available", position: .bottom)
                        }
                    }
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Map
        if indexPath.section == 0 && indexPath.row == 3  {
            return 220
        }
        //Videos
        if indexPath.section == 0 && indexPath.row == 1  {
            return 255
        }
        return UITableView.automaticDimension
    }
}

extension LSDEventDetailsViewController: LSInsidentsCollectionDelegate {
    func didTapPlayButton(video: LSDAllEventsMedia) {
        if let videoUrl = video.url, let url = URL(string: sansataBaseUrl+videoUrl) {
            if video.type == .mp4 {
                playVieo(url: url)
            } else if video.type == .jpg {
                previewImage(url: url)
            }
        }
        
    }
    
    func playVieo(url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        
        let playerViewController = LSAVPlayerViewController()
        playerViewController.player = player
        playerViewController.avPlayerDelegate = self
        self.present(playerViewController, animated: true)

    }
    
    func previewImage(url: URL) {
        let previewVC = LSImagepreviewViewController.instantiate(fromStoryboard: .driver)
        previewVC.previewDelegate = self
            previewVC.url = url
            self.present(previewVC, animated: true)

    }

}
extension LSDEventDetailsViewController: LSEventVideosTableCellDelegate {
    func didTaponMedia(media: LSDAllEventsMedia) {
        
        if let videoUrl = media.url, let url = URL(string: sansataBaseUrl+videoUrl) {
            if media.type == .mp4 {
                playVieo(url: url)
            } else if media.type == .jpg {
                previewImage(url: url)
            }
        }
    }
    
    func videoDownloadCompleted(with url: URL?) {
        print ("Downloaded Video Url = ", url)
        if let url = url {
            showActivityController(url: url)
        }
    }
}


extension LSDEventDetailsViewController: LSShowActivityDelegate {
    func showActivityController(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url as URL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
