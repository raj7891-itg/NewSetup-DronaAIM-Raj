//
//  LSAddressFetcher.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 17/06/24.
//

import Foundation
import CoreLocation
import GoogleMaps
class GeocoderManager {
    static let shared = GMSGeocoder()
    
    private init() {}
}
private var addressCache = [Coordinate: String]()

class LSAddressFetcher {
    
    func getAddressFromCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?, Error?) -> Void) {
        let coordinate = Coordinate(latitude: latitude, longitude: longitude)
        if let cachedKey = addressCache.keys.first(where: { $0.latitude == latitude && $0.longitude == longitude }) {
            if let cachedAddress = addressCache[cachedKey] {
                print("cachedAddress \(coordinate)= ", cachedAddress)
                completion(cachedAddress, nil)
                return
            }
        }
            GeocoderManager.shared.reverseGeocodeCoordinate((CLLocationCoordinate2DMake(latitude, longitude))) {
                (response, error) in
                if error == nil {
                    if let gmsAddress = response?.firstResult() {
                        let address = gmsAddress.lines?.first
                        addressCache[coordinate] = address
                        completion(address, nil)
                    }
                } else {
                        completion(nil, error)
                }
            }
    }
    
}

struct Coordinate: Hashable {
       let latitude: CLLocationDegrees
       let longitude: CLLocationDegrees
       
       // Initialize with CLLocationCoordinate2D
       init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
           self.latitude = latitude
           self.longitude = longitude
       }
       
       // Provide a method to convert back to CLLocationCoordinate2D
       func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
           return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
       }
       
       // Implement Hashable protocol requirements
       func hash(into hasher: inout Hasher) {
           hasher.combine(latitude)
           hasher.combine(longitude)
       }
       
       static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
           return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
       }
   }
