//
//  My Bookings.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.
//

import UIKit

class My_Bookings: UIViewController {

    @IBOutlet weak var scheduleBookingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleBookingView.layer.cornerRadius = 12
        scheduleBookingView.layer.masksToBounds = true
        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds                          // Match the frame of the view
        gradientLayer.colors = [
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor,  // Start color
            UIColor.clear.cgColor                                  // End color
        ]
        gradientLayer.locations = [0.0, 1.0]                       // Gradually fade
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)         // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)           // Bottom-center
        gradientView.layer.insertSublayer(gradientLayer, at: 0)

        
    }


}
