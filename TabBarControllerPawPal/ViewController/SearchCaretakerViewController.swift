//
//  SearchCaretakerViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 16/11/24.
//

import UIKit

class SearchCaretakerViewController: UIViewController {
    
   
    @IBOutlet var myTabel: UITableView!
    
    var caretakerList = [CaretakerData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let caretaker1 = CaretakerData(name: "Katie", price: "Price : Rs 350 / Day", address: "2.7 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Profile Image 1")
        
        caretakerList.append(caretaker1)
        let caretaker2 = CaretakerData(name: "Ananya", price: "Price : Rs 250 / Day", address: "3 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Ananya")
        caretakerList.append(caretaker2)
        let caretaker3 = CaretakerData(name: "Karan", price: "Price : Rs 300 / Day", address: "3.2 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Karan")
        caretakerList.append(caretaker3)
        let caretaker4 = CaretakerData(name: "Pooja", price: "Price : Rs 350 / Day", address: "2.7 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Pooja")
        caretakerList.append(caretaker4)
        let caretaker5 = CaretakerData(name: "Aman", price: "Price : Rs 250 / Day", address: "4 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Aman")
        caretakerList.append(caretaker5)
        let caretaker6 = CaretakerData(name: "Sharddha", price: "Price : Rs 400 / Day", address: "5 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Shraddha")
        caretakerList.append(caretaker6)
        let caretaker7 = CaretakerData(name: "Nidhi", price: "Price : Rs 400 / Day", address: "4.5 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Profile Image 1")
        caretakerList.append(caretaker7)
        let caretaker8 = CaretakerData(name: "Ananya", price: "Price : Rs 250 / Day", address: "3 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Ananya")
        caretakerList.append(caretaker8)
        let caretaker9 = CaretakerData(name: "Karan", price: "Price : Rs 350 / Day", address: "2.7 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Karan")
        caretakerList.append(caretaker9)
        let caretaker10 = CaretakerData(name: "Pooja", price: "Price : Rs 300 / Day", address: "15 km, Chennai", rating: "Frame 166", isverified: true, caretakerImage: "Pooja")
        caretakerList.append(caretaker10)
        
        
        myTabel.tableFooterView = UIView(frame: .zero)
      
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        
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


extension SearchCaretakerViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caretakerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTabel.dequeueReusableCell(withIdentifier: "caretakercell", for: indexPath) as! SearchTableViewCell
        
        cell.nameLabel.text = caretakerList[indexPath.row].name
        cell.addressLabel.text = caretakerList[indexPath.row].address
        cell.ratingImage.image = UIImage(named: caretakerList[indexPath.row].rating)
        cell.priceLabel.text = caretakerList[indexPath.row].price
        cell.caretakerImage.image = UIImage(named: caretakerList[indexPath.row].caretakerImage)
        cell.verifiedLabel.isHidden = !caretakerList[indexPath.row].isverified
        cell.cellView.layer.cornerRadius = 10
//        cell.cellView.layer.backgroundColor = UIColor.systemBackground.cgColor
        cell.cellView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.cellView.layer.shadowOpacity = 0.2
        cell.cellView.layer.shadowRadius = 2
        
        
        return cell
    }
    
}


