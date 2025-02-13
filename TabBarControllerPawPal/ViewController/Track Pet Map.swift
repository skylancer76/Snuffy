//
//  Track Pet Map.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 09/02/25.
//

import UIKit
import MapKit

class Track_Pet_Map: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var caretakerLatitude: Double?
    var caretakerLongitude: Double?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pet's Location"
        
        // Set up map view delegate and enable user location
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set up caretaker's annotation and animated zoom
        if let lat = caretakerLatitude, let lon = caretakerLongitude {
            let caretakerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            addCaretakerAnnotation(at: caretakerCoordinate)
            animateZoom(to: caretakerCoordinate)
        } else {
            print("Error: Latitude and Longitude not set")
        }
    }
    
    private func addCaretakerAnnotation(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Caretaker's Location"
        mapView.addAnnotation(annotation)
    }
    
    private func animateZoom(to coordinate: CLLocationCoordinate2D) {
        // Set an initial, wider region
        let initialRegion = MKCoordinateRegion(center: coordinate,
                                               latitudinalMeters: 1000,
                                               longitudinalMeters: 1000)
        mapView.setRegion(initialRegion, animated: true)
        
        // Animate zoom in after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let zoomedRegion = MKCoordinateRegion(center: coordinate,
                                                  latitudinalMeters: 500,
                                                  longitudinalMeters: 500)
            self.mapView.setRegion(zoomedRegion, animated: true)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Using the most recent user location
        guard let userLocation = locations.last,
              let lat = caretakerLatitude,
              let lon = caretakerLongitude else { return }
        
        let caretakerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        drawRoute(from: userLocation.coordinate, to: caretakerCoordinate)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
    
    // MARK: - Directions and Route Drawing
    
    private func drawRoute(from sourceCoordinate: CLLocationCoordinate2D,
                           to destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] (response, error) in
            if let error = error {
                print("Error calculating directions: \(error)")
                return
            }
            
            guard let route = response?.routes.first else {
                print("No route found")
                return
            }
            
            // Add the route as an overlay to the map
            self?.mapView.addOverlay(route.polyline)
            
            // Optionally, adjust the map region to fit the route
            self?.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                            edgePadding: UIEdgeInsets(top: 60, left: 40, bottom: 40, right: 40),
                                            animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Render the route polyline
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.systemPink.withAlphaComponent(0.6)
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

