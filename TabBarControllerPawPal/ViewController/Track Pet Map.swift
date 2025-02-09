//
//  Track Pet Map.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 09/02/25.
//

import UIKit
import MapKit

class Track_Pet_Map: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var caretakerLatitude: Double?
    var caretakerLongitude: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pet's Location"
        if let lat = caretakerLatitude, let lon = caretakerLongitude {
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    setupMap(with: location)
                } else {
                    print("Error: Latitude and Longitude not set")
                }
    }
    private func setupMap(with coordinate: CLLocationCoordinate2D) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Caretaker's Location"
            
            // Add annotation and set region
            mapView.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
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
