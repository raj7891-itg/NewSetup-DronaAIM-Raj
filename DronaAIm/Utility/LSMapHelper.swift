//
//  LSMapHelper.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/25/24.
//

import Foundation
import UIKit
import MapKit

class LSMapHelper: NSObject, MKMapViewDelegate {
    static let shared = LSMapHelper()
    
    func configure(mapView: MKMapView, startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        mapView.delegate = self
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = startCoordinate
        startAnnotation.title = "Start Location"
        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = endCoordinate
        endAnnotation.title = "End Location"
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
        
        // Calculate the region to include both annotations with a bit of padding
        let padding: CGFloat = 10000
        let mapRect = MKMapRect(
            x: min(startCoordinate.mapPoint.x, endCoordinate.mapPoint.x),
            y: min(startCoordinate.mapPoint.y, endCoordinate.mapPoint.y),
            width: abs(startCoordinate.mapPoint.x - endCoordinate.mapPoint.x),
            height: abs(startCoordinate.mapPoint.y - endCoordinate.mapPoint.y)
        ).insetBy(dx: -padding, dy: -padding)
        
        mapView.setVisibleMapRect(mapRect, animated: true)
        
        drawRoute(from: startCoordinate, to: endCoordinate, mapView: mapView)
    }
    
    func drawRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, mapView: MKMapView) {
        let startPlacemark = MKPlacemark(coordinate: start)
        let endPlacemark = MKPlacemark(coordinate: end)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: endPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.appTheme
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}

private extension CLLocationCoordinate2D {
    var mapPoint: MKMapPoint {
        return MKMapPoint(self)
    }
}
