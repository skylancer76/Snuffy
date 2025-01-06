//
//  Home Page.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 07/01/25.
//

import UIKit

class Home_Page: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource{
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Banner", for: indexPath) as! HomeBannerCell
        
        
        cell.bannerImage.image = UIImage(named: bannerImages[indexPath.row])
        cell.bannerImage.layer.cornerRadius = 15
        
        return cell
    }
    

    
    var bannerImages:[String] = ["caretaker1" , "caretaker2"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust the cell size to resemble the "Find Pet" cards
        let width = collectionView.frame.width * 0.9 // 90% of collection view width
        let height = width * 0.6 // Adjust height-to-width ratio
        return CGSize(width: width, height: height)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 25 // Spacing between items in the same row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 25) // Section padding
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


