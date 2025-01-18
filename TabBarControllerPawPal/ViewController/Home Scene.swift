//
//  Home Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import UIKit
import CoreLocation

class Home_Scene: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var caretakerImage: UIImageView!
    @IBOutlet weak var dogwalkerImage: UIImageView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Corner Radius of Caretaker Image
        caretakerImage.layer.cornerRadius = 12
        caretakerImage.layer.masksToBounds = true
        
        // Background Shadow of Caretaker Image
        caretakerImage.layer.shadowOffset = CGSize(width: 2, height: 2)
        caretakerImage.layer.shadowRadius = 2
        caretakerImage.layer.shadowOpacity = 0.6
        
        // Corner Radius of Dogwalker Image
        dogwalkerImage.layer.cornerRadius = 12
        dogwalkerImage.layer.masksToBounds = true
        
        // Background Shadow of Dogwalker Image
        dogwalkerImage.layer.shadowOffset = CGSize(width: 2, height: 2)
        dogwalkerImage.layer.shadowRadius = 2
        dogwalkerImage.layer.shadowOpacity = 0.6
        
        
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
    
    
    func enableLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    // CLLocationManagerDelegate method
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
    
}

