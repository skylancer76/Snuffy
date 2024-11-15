//
//  myPetsdetailedViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 06/11/24.
//

import UIKit

struct PetDetails {
    let name: String
    let imageName: String
    let vaccinationDetails: [String]
    let healthDetails: [String]
    let medications: [String]
    let diet: String
}

class myPetsdetailedViewController: UIViewController {

    
    @IBOutlet weak var petImageView: UIImageView!
    
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func petDetailsTapped(_ sender: Any) {
    }
    
    
    @IBAction func vaccinationDetailsTapped(_ sender: Any) {
    }
    
    @IBAction func healthdetailsTapped(_ sender: Any) {
    }
    
    @IBAction func medDetailTapped(_ sender: Any) {
    }
    
    @IBAction func foodDetailsTapped(_ sender: Any) {
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
