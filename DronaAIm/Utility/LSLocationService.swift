//
//  LSLocationService.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 17/06/24.
//

import Foundation
import CoreLocation

class LSLocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let addressFetcher = LSAddressFetcher()
    private var locationCompletion: ((String?) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation(completion: @escaping (String?) -> Void) {
        self.locationCompletion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
//            addressFetcher.getAddressFromCoordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] address, error in
//                if let error = error {
//                    print("Error occurred: \(error.localizedDescription)")
//                    self?.locationCompletion?(nil)
//                } else if let address = address {
//                    self?.locationCompletion?(address)
//                } else {
//                    self?.locationCompletion?(nil)
//                }
//            }
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
        locationCompletion?(nil)
    }
}

