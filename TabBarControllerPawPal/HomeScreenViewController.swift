//
//  HomeScreenViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 08/11/24.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
    
    @IBOutlet weak var topCaretakerVerifiedLabel: UILabel!
    @IBOutlet weak var topCaretakerRatingImage: UIImageView!
    @IBOutlet weak var topCaretakeraddressLabel: UILabel!
    @IBOutlet weak var topCaretakerPriceLabel: UILabel!
    @IBOutlet weak var topCaretakerNameLabel: UILabel!
    @IBOutlet weak var topCaretakerProfileImage: UIImageView!
    
    @IBOutlet weak var welcomeNameLabel: UILabel!
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    var selectedCaretakerInfo: PetCaretakerInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCaretakerInfo = PetCaretakerInfo(
            name: "Katie",
            address: "27 km, Guindy",
            price: "₹350 / Day",
            rating: "Rating1",
            verified: true,
            profileImageName: "Profile Image 1",
            petName: "Buzzo"
        )
        if let caretakerInfo = selectedCaretakerInfo {
            displayCaretakerInfo(caretakerInfo: caretakerInfo)
        }
    }
        
        func displayCaretakerInfo(caretakerInfo: PetCaretakerInfo) {
            topCaretakerNameLabel.text = caretakerInfo.name
            topCaretakeraddressLabel.text = caretakerInfo.address
            topCaretakerPriceLabel.text = caretakerInfo.price
            topCaretakerVerifiedLabel.text = caretakerInfo.verified ? "Verified" : "Not Verified"
            welcomeNameLabel.text = "Welcome, Pawan"
            petNameLabel.text = caretakerInfo.petName
            
            // Set the profile image if available
            topCaretakerProfileImage.image = UIImage(named: caretakerInfo.profileImageName)
            
            // Display stars based on the rating
            topCaretakerRatingImage.image = UIImage(named: "Rating1") 
        }
        
        @IBAction func topCaretakersListTapped(_ sender: Any) {
        }
        @IBAction func upCommingBookingListTapped(_ sender: Any) {
        }
        @IBAction func profileButtonTapped(_ sender: Any) {
        }
        
        @IBAction func topCaretakerProfileTapped(_ sender: Any) {
            performSegue(withIdentifier: "caretaker", sender: self)
        }
        @IBAction func dogWalkingButtonTapped(_ sender: Any) {
        }
        @IBAction func petSittingServiceButtonTapped(_ sender: Any) {
        }
        @IBAction func upcomingBookingButtonTapped(_ sender: Any) {
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

