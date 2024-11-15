//
//  CaretakerProfileViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 15/11/24.
//

import UIKit

class CaretakerProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet var distance: UITextView!
    @IBOutlet var noOfpetSitted: UITextView!
    @IBOutlet var costLabel: UITextView!
    @IBOutlet var experienceLabel: UITextView!
    
    @IBOutlet var aboutTheCaretaker: UITextView!
    @IBOutlet var templateImage: UIImageView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var addressLabel: UILabel!
    
    
    @IBOutlet var ratingImage: UIImageView!
    
    @IBOutlet var ratingsLabel: UILabel!
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return caretakerImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! caretakerProfileCollectionViewCell
        
        cell.caretakerImage.image = UIImage(named: caretakerImages[indexPath.row])
        cell.caretakerImage.layer.cornerRadius = 50.0
        return cell
        
    }
    
    
    var caretakerImages: [String] = ["caretaker1","caretaker2","caretaker3","caretaker4"]
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
