//
//  Pet Profile.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 01/01/25.
//

import UIKit
import SwiftUICore

class Pet_Profile: UIViewController {

    @IBOutlet weak var petImage: UIImageView!
    
    @IBOutlet weak var ageView: UIView!
    
    @IBOutlet weak var genderView: UIView!
    
    @IBOutlet weak var weightView: UIView!
    
    @IBOutlet weak var vaccinationDetailsView: UIView!
    
    @IBOutlet weak var petMedicationsView: UIView!
    
    @IBOutlet weak var petDietView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        petImage.layer.cornerRadius = 12
        petImage.layer.masksToBounds = true
        petImage.layer.borderColor = UIColor.purple.cgColor
        petImage.layer.borderWidth = 2
        
        genderView.layer.cornerRadius = 10
        genderView.layer.masksToBounds = true
        
        ageView.layer.cornerRadius = 10
        ageView.layer.masksToBounds = true
        
        weightView.layer.cornerRadius = 10
        weightView.layer.masksToBounds = true
        
        vaccinationDetailsView.layer.cornerRadius = 10
        vaccinationDetailsView.layer.masksToBounds = true
        
        petMedicationsView.layer.cornerRadius = 10
        petMedicationsView.layer.masksToBounds = true
        
        petDietView.layer.cornerRadius = 10
        petDietView.layer.masksToBounds = true
        
        
        
        
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
