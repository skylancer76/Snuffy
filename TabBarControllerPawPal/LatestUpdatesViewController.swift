//
//  LatestUpdatesViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 17/11/24.
//

import UIKit

class LatestUpdatesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LastestUpdateImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LatestUpdatesCollectionViewCell
        
        cell.liveViewImages.image = UIImage(named: LastestUpdateImages[indexPath.row])
        cell.liveViewImages.layer.cornerRadius = 10
        
        
        return cell
    }
    
    
    var LastestUpdateImages: [String] = ["pick1","pick2","pick3"]


    
    @IBOutlet var myPage: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        myPage.currentPage = 0
        myPage.numberOfPages = LastestUpdateImages.count
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        myPage.currentPage = indexPath.row
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
