//
//  Home Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class Home_Scene: UIViewController {

    @IBOutlet weak var caretakerImage: UIImageView!
    @IBOutlet weak var dogwalkerImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Caretaker Image view.
        caretakerImage.layer.cornerRadius = 12
        caretakerImage.layer.masksToBounds = true
        
        // Configure Dogwalker Image view.
        dogwalkerImage.layer.cornerRadius = 12
        dogwalkerImage.layer.masksToBounds = true
        
        // Set up a gradient background.
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Removed location access code from Home Scene as per the new requirements.
    }
}

