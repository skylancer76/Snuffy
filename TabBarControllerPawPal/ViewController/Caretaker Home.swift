//
//  Caretaker Home.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.
//

import UIKit

class Caretaker_Home: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
