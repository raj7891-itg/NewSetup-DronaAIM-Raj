//
//  LSDistanceCalculator.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/13/24.
//
import UIKit
import CoreLocation

class DistanceCalculator: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<Double?, Never>?
    private var destinationLocation: CLLocation?

    // Function to calculate distance between current device location and given coordinates with async/await
    func distanceBetweenCoordinates(lat2: Double, lon2: Double) async -> Double? {
        // Store destination location
        destinationLocation = CLLocation(latitude: lat2, longitude: lon2)

        // Request permission to access location
        locationManager.requestWhenInUseAuthorization()

        // Check if the last known location is available
        if let currentLocation = locationManager.location {
            // Calculate the distance directly if we have a known location
            if let destinationLocation = self.destinationLocation {
                let distanceInMeters = currentLocation.distance(from: destinationLocation)
                return distanceInMeters
            }
        }

        // Otherwise, start updating location and wait for location update asynchronously
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    // CLLocationManagerDelegate method to receive the current device location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Stop updating location after getting the first location
        locationManager.stopUpdatingLocation()

        // Get the current device location
        if let currentLocation = locations.first, let destinationLocation = self.destinationLocation {
            // Calculate distance in meters
            let distanceInMeters = currentLocation.distance(from: destinationLocation)
            // Pass the calculated distance to the continuation
            locationContinuation?.resume(returning: distanceInMeters)
        } else {
            locationContinuation?.resume(returning: nil) // If no location is found, return nil
        }
    }

    // Handle location error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
        locationContinuation?.resume(returning: nil) // Handle error by returning nil
    }
}
