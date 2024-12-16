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
        
        petCaretakerView.layer.cornerRadius = 15
        //petCaretakerView.layer.masksToBounds = true
        petCaretakerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        petCaretakerView.layer.shadowOpacity = 0.2
        petCaretakerView.layer.shadowRadius = 3
        
        petCaretakerImage.layer.cornerRadius = 15
        petCaretakerImage.layer.masksToBounds = true
        
        bookPetCaretakerButoon.layer.cornerRadius = 15
        bookPetCaretakerButoon.layer.masksToBounds = true
        
        dogWalkerView.layer.cornerRadius = 15
        //dogWalkerView.layer.masksToBounds = true
        dogWalkerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        dogWalkerView.layer.shadowOpacity = 0.2
        dogWalkerView.layer.shadowRadius = 3
        
        dogWalkerImage.layer.cornerRadius = 15
        dogWalkerImage.layer.masksToBounds = true
        
        bookDogWalkerButton.layer.cornerRadius = 15
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
