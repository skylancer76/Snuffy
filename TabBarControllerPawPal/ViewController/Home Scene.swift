//
//  Home Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import UIKit

class Home_Scene: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var servicesCollectionView: UICollectionView!
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = servicesCollectionView.dequeueReusableCell(withReuseIdentifier: "Banner", for: indexPath) as! HomeBannerCell
        
        
        cell.bannerImage.image = UIImage(named: bannerImages[indexPath.row])
        cell.bannerImage.layer.cornerRadius = 15
        
        cell.ViewAllButton.layer.cornerRadius = 7.5
        
        return cell
    }
    

    
    var bannerImages:[String] = ["Home1" , "Home2"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 25 // Spacing between items in the same row
    }
    

}

