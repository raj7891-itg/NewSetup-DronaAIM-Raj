//
//  LSIncidentReportViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 24/06/24.
//

import UIKit
import AVKit
import AVFoundation

enum LSDIncidentType: String {
    case Accelerate = "Accelerate"
    case Brake = "Brake"
    case Turn = "Turn"
    case Speed = "Speed"
    case Shock = "Shock"
    case SevereShock = "SevereShock"
    case PanicButton = "PanicButton"
}

class LSIncidentReportViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var events = [LSDAllEvents]()
    var tripid: String!
    var groupedEvents = [LSDAllEventType?: [LSDAllEvents]]()
    
    @IBOutlet weak var totalIncidents: UILabel!
    
    var incidentsInfo = [
        IncidentDetails(incidentType: "Speeding", incidentEvent: "2 events", eventType: .Speed),
        IncidentDetails(incidentType: "Harsh Acceleration", incidentEvent: "0 event", eventType: .Accelerate),
        IncidentDetails(incidentType: "Harsh Braking", incidentEvent: "1 event", eventType: .Brake),
        IncidentDetails(incidentType: "Harsh Cornering", incidentEvent: "0 event", eventType: .Turn),
        IncidentDetails(incidentType: "Impact", incidentEvent: "0 event", eventType: .Shock),
        IncidentDetails(incidentType: "Severe Impact", incidentEvent: "0 event", eventType: .SevereShock),
        IncidentDetails(incidentType: "SOS", incidentEvent: "0 event", eventType: .PanicButton)


    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()
        }
         groupedEvents = Dictionary(grouping: events, by: { $0.eventType })
        print("Grouped =", groupedEvents.keys)

        if events.count == 0 || events.count == 1 {
            totalIncidents.text = "Total \(events.count) event"
        } else {
            totalIncidents.text = "Total \(events.count) events"
        }
    }
   
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bounces = true;
    }
    
}

extension LSIncidentReportViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return incidentsInfo.count + 1
        case 1:
            return groupedEvents.keys.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LSIncidentHeaderTableViewCell", for: indexPath) as! LSIncidentHeaderTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LSTripIncidentInfoCell", for: indexPath) as! LSTripIncidentInfoCell
                let details = incidentsInfo[indexPath.row - 1]
                cell.config(with: details, events: self.events)
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSIncedentReportTableViewCell", for: indexPath) as! LSIncedentReportTableViewCell
            cell.videoDelegate = self
            let keys = Array(groupedEvents.keys)
            let key = keys[indexPath.row]
            let groupedEvent = groupedEvents[key]
            if let groupedEvent = groupedEvent {
                cell.configure(with: groupedEvent)
            }
            return cell

        default:
            return UITableViewCell()
        }
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Events Media"
        default:
            return ""
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 60
        default:
            return 260
        }
    }
}

extension LSIncidentReportViewController: LSInsidentsCollectionDelegate {
    func didTapPlayButton(video: LSDAllEventsMedia) {
        let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()

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

extension LSIncidentReportViewController: LSShowActivityDelegate {
    func showActivityController(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url as URL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
