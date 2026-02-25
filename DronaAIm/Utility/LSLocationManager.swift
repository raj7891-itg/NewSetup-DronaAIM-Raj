//
//  LSLocationManager.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/24/24.
//

import Foundation
import UIKit
import CoreLocation

class LSLocationManager: NSObject, CLLocationManagerDelegate  {
    var locationManager: CLLocationManager?
    var locationTimer: Timer?
    let locationFileName = "locations.txt"
    @Published var location: CLLocation? = nil

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization() // Requesting Always authorization
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        startLocationUpdates()
        print("LocationManager initialized")
    }

    func startLocationUpdates() {
        locationTimer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(requestLocation), userInfo: nil, repeats: true)
    }

    @objc func requestLocation() {
        locationManager?.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations called")
        if let location = locations.last {
            print("New location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            self.location = location
            saveLocationToFile(location: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func saveLocationToFile(location: CLLocation) {
        let locationString = "Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude), Timestamp: \(location.timestamp)\n"
        let filePath = getDocumentsDirectory().appendingPathComponent(locationFileName)

        do {
            if FileManager.default.fileExists(atPath: filePath.path) {
                let fileHandle = try FileHandle(forWritingTo: filePath)
                fileHandle.seekToEndOfFile()
                if let data = locationString.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try locationString.write(to: filePath, atomically: true, encoding: .utf8)
            }
            print("Location saved to file")
        } catch {
            print("Error writing to file: \(error)")
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed: \(status.rawValue)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        default:
            locationTimer?.invalidate()
            locationManager?.stopUpdatingLocation()
        }
    }
}

