//
//  LANetworkManager_Google.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/22/24.
//

import Foundation
import GoogleMaps

extension LSNetworkManager {
    
    func getGoogleVehicleRoute(coordinates: [CLLocationCoordinate2D]) async throws -> GMSPolyline {
        guard coordinates.count > 1 else {
            throw NSError(domain: "InvalidCoordinates", code: 0, userInfo: [NSLocalizedDescriptionKey: "You need at least two coordinates to get a route."])
        }
        
        let origin = "\(coordinates.first!.latitude),\(coordinates.first!.longitude)"
        let destination = "\(coordinates.last!.latitude),\(coordinates.last!.longitude)"
        
        let waypoints = coordinates.dropFirst().dropLast().map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
        
        let gmsKey = LSConstants.APIKeys.googleMapsAPIKey
        var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=\(gmsKey)&waypoints=optimize:true"
           if !waypoints.isEmpty {
               urlString += "|\(waypoints)"
           }
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "The constructed URL is invalid."])
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                LSLogger.debug("Google Maps Directions API response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw NSError(domain: "NetworkError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to parse the response as JSON."])
            }
                        
            guard let routes = json["routes"] as? [[String: Any]],
                  let route = routes.first,
                  let overviewPolyline = route["overview_polyline"] as? [String: Any],
                  let points = overviewPolyline["points"] as? String else {
                throw NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Expected keys not found in the JSON response."])
            }
            
            guard let path = GMSPath(fromEncodedPath: points) else {
                throw NSError(domain: "PolylineError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to decode polyline."])
            }
            return await MainActor.run {
                let polyline = GMSPolyline(path: path)
                return polyline
            }
        } catch {
            throw error
        }
    }


}
