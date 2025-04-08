//
//  Notification Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 08/04/25.
//

import UIKit

class Notification_Scene: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton.layer.cornerRadius = 15
        viewButton.layer.cornerRadius = 15
        viewButton.layer.masksToBounds = true
        
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor.systemPink.cgColor
        
        view.backgroundColor = .white
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func viewTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
