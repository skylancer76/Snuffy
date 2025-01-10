//
//  Home Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import UIKit

class Home_Scene: UIViewController {

    @IBOutlet weak var caretakerImage: UIImageView!
    @IBOutlet weak var dogwalkerImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        caretakerImage.layer.cornerRadius = 12
        caretakerImage.layer.masksToBounds = true
        
        dogwalkerImage.layer.cornerRadius = 12
        dogwalkerImage.layer.masksToBounds = true
        
//        // Set Gradient View
//        let gradientView = UIView(frame: view.bounds)
//            gradientView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(gradientView)
//            view.sendSubviewToBack(gradientView)
//        
//        // Set Gradient inside the view
//        let gradientLayer = CAGradientLayer()
//            gradientLayer.frame = view.bounds // Match the frame of the view
//            gradientLayer.colors = [
//                UIColor.systemPurple.withAlphaComponent(0.3).cgColor, // Start color
//                UIColor.clear.cgColor       // End color
//            ]
//            gradientLayer.locations = [0.0, 1.0] // Gradually fade
//            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
//            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Bottom-center
//                
//            // Apply the gradient to the gradientView
//            gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let accessoryView = UIButton()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 34, weight: .regular, scale: .medium)
        let image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: symbolConfig)?
            .withTintColor(.gray, renderingMode: .alwaysOriginal) // Apply gray color
        
        accessoryView.setImage(image, for: .normal)
        accessoryView.frame.size = CGSize(width: 34, height: 34)
        
        let largeTitleView = navigationController?.navigationBar.subviews.first { subview in
            return String(describing: type(of: subview)) == "_UINavigationBarLargeTitleView"
        }
        largeTitleView?.perform(Selector(("setAccessoryView:")), with: accessoryView)
        largeTitleView?.perform(Selector(("setAlignAccessoryViewToTitleBaseline:")), with: nil)
        largeTitleView?.perform(Selector(("updateContent")))
    }
}

