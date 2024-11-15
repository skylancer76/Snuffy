//
//  searchCaretakerViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 13/11/24.
//

import UIKit

class searchCaretakerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    private var filteredPetSitters: [PetSitter] = petSitters
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetSitters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PetSitterCell", for: indexPath) as? searchTableViewCell else {
                return UITableViewCell()
            }

            let petSitter = filteredPetSitters[indexPath.row]
            cell.name.text = petSitter.name
            cell.distance.text = petSitter.distance
            cell.price.text = petSitter.price
            cell.profileImageName.image = UIImage(named: petSitter.profileImageName)
            cell.rating.image = UIImage(named: petSitter.rating)

            return cell
    }
    

    @IBOutlet var petSittersTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        petSittersTableView.dataSource = self
        petSittersTableView.delegate = self
        petSittersTableView.register(searchTableViewCell.self, forCellReuseIdentifier: "PetSitterCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPetSitter = filteredPetSitters[indexPath.row]
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "caretakerViewController") as! caretakerViewController
        
        let caretaker = Caretaker(
                    name: selectedPetSitter.name,
                    title: "Pet Sitter",
                    ratings: Int(selectedPetSitter.rating) ?? 0,
                    experience: "2+ Years",
                    rate: selectedPetSitter.price,
                    verified: selectedPetSitter.isVerified,
                    about: "Experienced pet sitter with a love for animals.",
                    galleryImages: ["katie_profile"]
                )

        detailViewController.caretaker = caretaker
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedPetSitter = filteredPetSitters[indexPath.row]
//        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "caretakerViewController") as! caretakerViewController
//        detailViewController.petSitters = selectedPetSitter
//        navigationController?.pushViewController(detailViewController, animated: true)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
