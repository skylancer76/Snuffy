//
//  MyPetsViewController.swift
//  PawPal_MyPets_TrackPet
//
//  Created by admin19 on 16/11/24.
//

import UIKit

class MyPetsViewController: UIViewController {

    @IBOutlet weak var myTable: UITableView!
    
    var petDataList = [PetData]()
    var selectedPet: PetData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        petDataList = [
            PetData(petImage: "Image1", petName: "Buzzo", petBreed: "Rottweiler", petGender: "Male", petAge: "12" , petWeight: "32"),
            PetData(petImage: "Image1", petName: "Fluffy", petBreed: "Golden Retriever", petGender: "Female" , petAge: "13", petWeight: "24")
                ]
                
        
        myTable.dataSource = self
        myTable.delegate = self
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "AddPetSegue", let destinationVC = segue.destination as? AddPetViewController {
                destinationVC.delegate = self
            } else if segue.identifier == "IndividualPetDetailSegue", let destinationVC = segue.destination as? IndiviualPetDetailViewController {
                // Pass the selected pet to the details view controller
                destinationVC.petData = selectedPet
            }
        }
    }

//
//override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AddPetSegue", let destinationVC = segue.destination as? AddPetViewController {
//            destinationVC.delegate = self
//        }
//    }
//}

extension MyPetsViewController: AddPetDelegate {
    func didAddPet(pet: PetData) {
        petDataList.append(pet)
        myTable.reloadData()
    }
}

extension MyPetsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyPetsTableViewCell
        
        cell.petImageView.image = UIImage(named: petDataList[indexPath.row].petImage)
        cell.petNameLabel.text = petDataList[indexPath.row].petName
        cell.petBreedLabel.text = petDataList[indexPath.row].petBreed
        cell.petGenderLabel.text = petDataList[indexPath.row].petGender
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Set the selected pet
            selectedPet = petDataList[indexPath.row]
            
            // Navigate directly to the pet details view controller
            performSegue(withIdentifier: "IndividualPetDetailSegue", sender: self)
        }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 10 // Set your custom spacing height here
        }
    
}
