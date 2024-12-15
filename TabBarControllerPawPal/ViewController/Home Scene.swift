//
//  Home Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import UIKit

class Home_Scene: UIViewController {

    @IBOutlet weak var headerBgImage: UIImageView!
    
    @IBOutlet weak var petCaretakerView: UIView!
    
    @IBOutlet weak var petCaretakerImage: UIImageView!
    
    @IBOutlet weak var bookPetCaretakerButoon: UIButton!
    
    @IBOutlet weak var dogWalkerView: UIView!
    
    @IBOutlet weak var dogWalkerImage: UIImageView!
    
    @IBOutlet weak var bookDogWalkerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerBgImage.alpha = 0.1
        
        petCaretakerView.layer.cornerRadius = 10
        petCaretakerView.layer.masksToBounds = true
        
        petCaretakerImage.layer.cornerRadius = 15
        petCaretakerImage.layer.masksToBounds = true
        
        bookPetCaretakerButoon.layer.cornerRadius = 25
        bookPetCaretakerButoon.layer.masksToBounds = true
        
        dogWalkerView.layer.cornerRadius = 10
        dogWalkerView.layer.masksToBounds = true
        
        dogWalkerImage.layer.cornerRadius = 15
        dogWalkerImage.layer.masksToBounds = true
        
        bookDogWalkerButton.layer.cornerRadius = 25
        bookDogWalkerButton.layer.masksToBounds = true
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
