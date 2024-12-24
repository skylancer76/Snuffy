//
//  Caretaker Profile.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 25/12/24.
//

import UIKit

class Caretaker_Profile: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var caretakerName: UILabel!
    
    @IBOutlet weak var caretakerAddress: UILabel!
    
    @IBOutlet weak var caretakerRating: UILabel!
    
    @IBOutlet weak var experience: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var petsSitted: UILabel!
    
    @IBOutlet weak var distanceAway: UILabel!
    
    @IBOutlet weak var aboutCaretaer: UILabel!
    
    @IBOutlet weak var scheduleBooking: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
