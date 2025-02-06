//
//  Home Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class Home_Scene: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var caretakerImage: UIImageView!
    @IBOutlet weak var dogwalkerImage: UIImageView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Corner Radius of Caretaker Image
        caretakerImage.layer.cornerRadius = 12
        caretakerImage.layer.masksToBounds = true
        
        
        // Corner Radius of Dogwalker Image
        dogwalkerImage.layer.cornerRadius = 12
        dogwalkerImage.layer.masksToBounds = true
        
        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds                           // Match the frame of the view
        gradientLayer.colors = [
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor,   // Start color
            UIColor.clear.cgColor                                   // End color
        ]
        gradientLayer.locations = [0.0, 1.0]                        // Gradually fade
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)          // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)            // Bottom-center
        // Apply the gradient to the gradientView
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        
        // Request location access
        requestLocationAccess()
    
    }
    
    
    // Notification Altert to access location
    func requestLocationAccess() {
        // Create the alert controller
        let alert = UIAlertController(
            title: "Allow \"PawPal\" to access your location while using the app?",
            message: "We need your location to show you nearby caretakers.",
            preferredStyle: .alert
        )
        // Add "Allow" action
        alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { _ in
            self.enableLocationServices()
        }))
        // Add "Don't Allow" action
        alert.addAction(UIAlertAction(title: "Don't Allow", style: .default, handler: nil))
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Enable Location Service
    func enableLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if !CLLocationManager.locationServicesEnabled() {
            print("Location services are not enabled. Please enable them in Settings.")
            return
        }
    }
    
    
    // Handle Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Save location to Firestore
        saveUserLocationToFirestore(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        // Stop updating location after the location is fetched
        locationManager.stopUpdatingLocation()
    }
    
    
    // Handle Location Authorization Changers
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted.")
        case .denied, .restricted:
            print("Location access denied.")
        default:
            break
        }
    }
    
    
    // Save user location to Firebase
    func saveUserLocationToFirestore(latitude: Double, longitude: Double) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }
    
        let locationData: [String: Any] = [
            "location": [
            "latitude": latitude,
            "longitude": longitude
            ]
        ]
        
        Firestore.firestore().collection("users").document(userID).updateData(locationData) { error in
            if let error = error {
                print("Failed to save user location: \(error.localizedDescription)")
            } else {
                print("User location saved successfully.")
            }
        }
    }
    
    
    // Handle Any Location Errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch location: \(error.localizedDescription)")
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("Location access was denied.")
            case .locationUnknown:
                print("Location is unknown.")
            default:
                print("Location error: \(clError.code.rawValue)")
            }
        }
    }
    
}

