//
//  LSMapCardTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 25/06/24.
//

import UIKit
import MapKit
import GoogleMaps

protocol LSMapCardTableViewDelegate: AnyObject {
    func didtapOnEventMarker(event: LSDAllEvents)
}

class LSMapCardTableViewCell: UITableViewCell {
    weak var mapCardDelegate: LSMapCardTableViewDelegate?
    var mapView: GMSMapView!
    var polyline: GMSPolyline?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initializeMapView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.frame = contentView.bounds
        let panGesture = UIPanGestureRecognizer(target: self, action: nil)
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)

        // Ensure the map view adjusts its layout properly
    }
    
    private func initializeMapView() {
        mapView = GMSMapView()
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.settings.tiltGestures   = false
        mapView.settings.rotateGestures = false
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        mapView.layer.cornerRadius = 10
    }

    func configure(with liveTrack: LSDTripLiveTrackModel?) {
        let startEndCoordinates = liveTrack?.getRouteCoordinates()
        startEndCoordinates?.forEach({ coordinate in
            showLocationMarker(coordinate: coordinate.coordinate, marker: coordinate.marker)
        })
        if let vehicleLiveTracks = liveTrack?.vehicleLiveTracks {
            let coordinates: [CLLocationCoordinate2D] = vehicleLiveTracks.compactMap {
                guard let latitude = $0.latitude, let longitude = $0.longitude else { return nil }
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            var reduced = reduceCoordinatesToLimit(coordinates: coordinates)

            startEndCoordinates?.forEach({ coordinate in
                if coordinate.type == .start {
                    reduced.insert(coordinate.coordinate, at: 0)
                } else {
                    reduced.insert(coordinate.coordinate, at: reduced.count)
                }
            })
            print("reduced")
            updateMapWithRoute(from: reduced)
        }
        
    }
    
    private func showLocationMarker(coordinate: CLLocationCoordinate2D, marker: String) {
        DispatchQueue.main.async {
                // Add a marker at the start coordinate
                let startMarker = GMSMarker(position: coordinate)
                let image = UIImage(named: marker)
                startMarker.icon = image
                startMarker.icon?.withTintColor(.blue)
                startMarker.map = self.mapView
        }
        
    }
    
    @MainActor
    func updateMapWithRoute(from coordinates: [CLLocationCoordinate2D]) {
        Task {
            do {
                 polyline = try await LSNetworkManager.shared.getGoogleVehicleRoute(coordinates: coordinates)
                // Since the Task is now marked with @MainActor, no need for DispatchQueue.main.async
                if let polyline = polyline {
                    drawRoute(polyline: polyline, coordinates: coordinates)
                }
            } catch {
                print("Failed to fetch route: \(error)")
                if let coordinate = coordinates.last, !coordinate.latitude.isZero {
                    let lat = coordinate.latitude
                    let long = coordinate.longitude
                    self.mapView.animate(to: GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 3.0))
                    animateTo(latitude: lat, longitude: long)
                }
            }
        }
    }
    
    private func drawRoute(polyline: GMSPolyline, coordinates: [CLLocationCoordinate2D]) {
        polyline.strokeColor = .appTheme
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView
        
        var bounds = GMSCoordinateBounds()
        if let path = polyline.path {
            for index in 0..<path.count() {
                bounds = bounds.includingCoordinate(path.coordinate(at: index))
            }
        }
        if let coordinate = coordinates.first {
            self.mapView.animate(to: GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 3.0))
        }
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))

    }
    
    func animateTo(latitude: Double, longitude: Double) {
       // Creates a marker in the center of the map.
        // Animate the camera to the marker's position and zoom in
        let cameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 10.0)
        mapView.animate(to: cameraPosition)
   }
    
    func showMarker(for event: LSDAllEvents) {
        if let latitude = event.gnssInfo?.latitude, let longitude = event.gnssInfo?.longitude {
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker.map = mapView
            marker.userData = event
            // Animate the camera to the marker's position and zoom in
            let cameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 10.0)
            mapView.animate(to: cameraPosition)
        }

   }
    
    func reduceCoordinatesToLimit(coordinates: [CLLocationCoordinate2D], limit: Int = 23) -> [CLLocationCoordinate2D] {
        guard coordinates.count > limit else {
            return coordinates
        }

        let step = Double(coordinates.count - 1) / Double(limit - 1)
        var reducedCoordinates = [CLLocationCoordinate2D]()

        for i in 0..<limit {
            let index = Int(round(Double(i) * step))
            reducedCoordinates.append(coordinates[index])
        }
        print ("reducedCoordinates Count", reducedCoordinates.count)
        return reducedCoordinates
    }

}


extension LSMapCardTableViewCell: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let event = marker.userData as? LSDAllEvents {
            // Perform actions with the event
            print("Event tapped: \(event)")
            self.mapCardDelegate?.didtapOnEventMarker(event: event)
        }
        return true
    }

}
