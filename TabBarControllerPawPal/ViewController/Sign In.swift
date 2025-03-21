//
//  Sign In.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 18/03/25.
//

import UIKit

class Sign_In: UIViewController {

    
    @IBOutlet weak var appLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up a gradient background for styling
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
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        
        appLogo.layer.cornerRadius = appLogo.frame.height / 2
        appLogo.clipsToBounds = true

        
    }


}
