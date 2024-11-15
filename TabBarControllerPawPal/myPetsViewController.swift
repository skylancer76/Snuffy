//
//  myPetsViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 06/11/24.
//

import UIKit

class myPetsViewController: UIViewController {

    @IBOutlet weak var addPet: UIButton!
    

    @IBOutlet var addPetView: UIView!
    @IBOutlet weak var petDetails: UIButton!
  
    



    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addPetTapped(_ sender: Any) {
    }
    
    @IBAction func petDetailsTapped(_ sender: Any) {
        performSegue(withIdentifier: "welcome", sender: self)
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
