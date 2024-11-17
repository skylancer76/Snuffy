//
//  HomeViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 16/11/24.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredCaretaker.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TopCaretakerTableViewCell
        let caretaker = filteredCaretaker[indexPath.row]
        cell.nameLabel.text = caretaker.name
        cell.ratingImage.image = UIImage(named: caretaker.rating)
        cell.addressLabel.text = caretaker.distance
        cell.priceLabel.text = caretaker.price
        cell.verifiedLabel.isHidden = !caretaker.isVerified
        cell.caretakerImage.image = UIImage(named: caretaker.profileImageName)
        return cell
    }
    

    @IBOutlet var myTable: UITableView!
    var isRecommended: Bool = false
    var filteredCaretaker: [PetSitter]{
        return petSitters.filter{
            $0.isrecommended == isRecommended
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func setRecommended(_ sender: UISegmentedControl) {
        isRecommended = sender.selectedSegmentIndex == 1
        myTable.reloadData()
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
