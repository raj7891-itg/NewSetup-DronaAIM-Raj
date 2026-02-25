//
//  LSTripDetailsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 24/06/24.
//

import UIKit
import MapKit
import AVFoundation

class LSTripDetailsViewController: UIViewController {
    var trips: LSDTrip!
    @IBOutlet weak var tableView: UITableView!
    var trip: LSDTrip!
    var events = [LSDAllEvents]()
    var vehicleStats: LSVehicleStatsModel?
    var liveTrack: LSDTripLiveTrackModel?
    
    let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            Task {
                await self.fetchVehicleStats()
                await self.fetchTripLiveTrack()
            }
        }
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bounces = true;

        tableView.sectionHeaderTopPadding = 1
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0,
                                                              width: self.tableView.bounds.size.width,
                                                              height: .leastNonzeroMagnitude))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 230 // Estimate row height
        DispatchQueue.main.async {
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()
        }

    }

    private func fetchVehicleStats() async {
        if let vehicleID = trip.vehicleID {
            let endpoint = LSAPIEndpoints.vehicleStats(for: vehicleID)
                do {
                    let vehicleStats: LSVehicleStatsModel = try await LSNetworkManager.shared.get(endpoint)
                    self.vehicleStats = vehicleStats
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

                } catch {
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                }
        }
    }
    
    private func fetchTripLiveTrack() async  {
        LSProgress.show(in: self.view)
              let tripID = trip.tripID
                let endpoint = LSAPIEndpoints.liveTrackByTripId(for: tripID)
                do {
                    let response: LSDTripLiveTrackModel = try await LSNetworkManager.shared.get(endpoint)
                    self.liveTrack = response
                    LSProgress.hide(from: self.view)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    LSProgress.hide(from: self.view)
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                }
    }
    
}

extension LSTripDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return events.count + 2
            
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSTripDetailsLocationCell", for: indexPath) as! LSTripDetailsLocationCell
            if indexPath.row == 0 {
                cell.config(with: trip, coordinateType: .start)
            } else {
                cell.config(with: trip, coordinateType: .end)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSTripDetailsEngineCell", for: indexPath) as! LSTripDetailsEngineCell
                cell.config(with: indexPath, trip: trip)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSTripVehicleDetailsTableViewCell", for: indexPath) as! LSTripVehicleDetailsTableViewCell
            cell.config(with: trip, vehicleStats: vehicleStats)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSMapCardTableViewCell", for: indexPath) as! LSMapCardTableViewCell
            cell.mapCardDelegate = self
            cell.configure(with: liveTrack)

            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSTripEventTrackCell", for: indexPath) as! LSTripEventTrackCell
            cell.lineView.isHidden = false
            if indexPath.row == 0 {
                cell.displayLocation(liveTrack: liveTrack, coordinateType: .start)
            } else if indexPath.row == events.count + 1 {
                cell.displayLocation(liveTrack: liveTrack, coordinateType: .end)
                cell.lineView.isHidden = true
            } else {
                let event = events[indexPath.row - 1]
                cell.config(with: event, indexPath: indexPath)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        default:
            print("")
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? LSMapCardTableViewCell {
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
                    } else if indexPath.row == events.count + 1 {
                         coordinate = startEndCoordinates.first(where: { $0.type == .end})
                        if  !(coordinate?.coordinate.latitude.isZero ?? false), let lat = coordinate?.coordinate.latitude, let long = coordinate?.coordinate.longitude  {
                            cell.animateTo(latitude: lat, longitude: long)
                        } else {
                            self.view.makeToast("Location not available", position: .bottom)
                        }
                    } else {
                        let event = events[indexPath.row - 1]
                        if let gnsInfo = event.gnssInfo, gnsInfo.isValid ?? false {
                            cell.showMarker(for: event)
                        } else {
                            self.view.makeToast("Location not available", position: .bottom)
                        }
                    }
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 4 {
//            return 73
//        }
        if indexPath.section == 3 {
            return 230
        }
        return UITableView.automaticDimension
        
    }
}

extension LSTripDetailsViewController: LSMapCardTableViewDelegate {
    func didtapOnEventMarker(event: LSDAllEvents) {
        let videosVC = LSVideosPopoverViewController.instantiate(fromStoryboard: .driver)
       if let sheet = videosVC.sheetPresentationController {
           sheet.detents = [.medium()] // .medium() will present half the screen
           sheet.prefersGrabberVisible = true // Optional: Show a grabber at the top of the sheet
           sheet.prefersEdgeAttachedInCompactHeight = true
           videosVC.event = event
           videosVC.videoVCDelegate = self
           present(videosVC, animated: true, completion: nil)
       }
    }
}

extension LSTripDetailsViewController: LSVideosPopoverDelegate {

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
        print("Downloaded =", url)
        if let url = url {
            let saveToPhotosActivity = SaveToPhotosActivity()
            let saveToFilesActivity = SaveToFilesActivity()
            
            let activityViewController = UIActivityViewController(activityItems: [url as URL], applicationActivities: [saveToPhotosActivity, saveToFilesActivity])
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func playVieo(url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        
        let playerViewController = LSAVPlayerViewController()
        playerViewController.avPlayerDelegate = self
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

extension LSTripDetailsViewController: LSShowActivityDelegate {
    func showActivityController(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url as URL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
