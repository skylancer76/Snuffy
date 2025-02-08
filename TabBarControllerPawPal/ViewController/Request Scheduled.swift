//
//  Request Scheduled.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 07/02/25.
//

import UIKit

class Request_Scheduled: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var rotatingSealImageView: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        startRotatingSeal()
    }

    // MARK: - Rotate Seal Animation
    private func startRotatingSeal() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.toValue = CGFloat.pi * 2 // Full circle rotation
        rotationAnimation.duration = 3 // Adjust speed (3 seconds per rotation)
        rotationAnimation.repeatCount = .infinity // Infinite loop
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .forwards
        rotatingSealImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    // MARK: - Dismiss Button Action
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
