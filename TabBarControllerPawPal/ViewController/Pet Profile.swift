//
//  Pet Profile.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 01/01/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class Pet_Profile: UIViewController {
    
    // The petId passed from My_Pets view controller
    var petId: String?
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var breedLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var petInfo: UIView!
    
    // Outlet for TableView
    @IBOutlet weak var petDetailsTableView: UITableView!
    
    // Data to populate the table
    let tableOptions = ["Pet Vaccinations", "Pet Diet", "Pet Medications"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Received Pet ID: \(petId ?? "No Pet ID")")
        
        petDetailsTableView.dataSource = self
        petDetailsTableView.delegate = self
        
        if let petId = petId {
            fetchPetData(petId: petId)
        } else {
            print("Pet ID is missing!")
        }
        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor, // Start color
            UIColor.clear.cgColor                              // End color
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        petImage.layer.cornerRadius = petImage.frame.height / 2
        petImage.layer.masksToBounds = true
        
        petInfo.layer.cornerRadius = 12
        petInfo.layer.masksToBounds = true
        petInfo.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
    }
    
    // Fetch pet data from Firestore using petId
    func fetchPetData(petId: String) {
        let db = Firestore.firestore()
        db.collection("Pets").document(petId).getDocument { document, error in
            if let error = error {
                print("Error fetching pet data: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists, let data = document.data() {
                let petName = data["petName"] as? String ?? "Unknown"
                let petBreed = data["petBreed"] as? String ?? "Unknown"
                let petAge = data["petAge"] as? String ?? "Unknown"
                let petGender = data["petGender"] as? String ?? "Unknown"
                let petWeight = data["petWeight"] as? String ?? "Unknown"
                let petImageUrl = data["petImage"] as? String ?? ""
                
                DispatchQueue.main.async {
                    self.nameLabel.text = petName
                    self.breedLabel.text = petBreed
                    self.ageLabel.text = petAge
                    self.genderLabel.text = petGender
                    self.weightLabel.text = petWeight
                    self.petImage.loadPrefetchedImageFromUrl(petImageUrl)
                }
            } else {
                print("No pet data found for this petId.")
            }
        }
    }
}

// MARK: - Prefetched Image Extension
extension UIImageView {
    func loadPrefetchedImageFromUrlOwner(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.image = UIImage(named: "placeholder_image")
            }
            return
        }
        
        // Use the URL's lastPathComponent as the file name
        let fileName = url.lastPathComponent
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let localURL = cachesDirectory.appendingPathComponent(fileName)
        
        // Check if the image file already exists locally
        if FileManager.default.fileExists(atPath: localURL.path),
           let image = UIImage(contentsOfFile: localURL.path) {
            DispatchQueue.main.async {
                self.image = image
            }
        } else {
            // If not, download the image using ImageDownloader
            ImageDownloader.shared.downloadImage(from: url) { downloadedLocalURL in
                if let downloadedLocalURL = downloadedLocalURL,
                   let image = UIImage(contentsOfFile: downloadedLocalURL.path) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.image = UIImage(named: "placeholder_image")
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension Pet_Profile: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PetDetailCell", for: indexPath) as? PetProfileTableViewCell else {
            return UITableViewCell()
        }
        
        let option = tableOptions[indexPath.row]
        cell.petDetailName.text = option
        cell.petDetailImageBgView.layer.cornerRadius = cell.petDetailImageBgView.frame.height / 2
        cell.petDetailImageBgView.layer.masksToBounds = true
        
        // Set the appropriate icon
        let icon: UIImage?
        switch option {
        case "Pet Vaccinations":
            icon = UIImage(systemName: "syringe.fill")
        case "Pet Diet":
            icon = UIImage(systemName: "fork.knife")
        case "Pet Medications":
            icon = UIImage(systemName: "pills.fill")
        default:
            icon = nil
        }
        
        if let icon = icon {
            let tintedIcon = icon.withRenderingMode(.alwaysTemplate)
            cell.petDetailImage.image = tintedIcon
            cell.petDetailImage.tintColor = UIColor.systemBackground
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let petId = petId else { return }
        let option = tableOptions[indexPath.row]
        
        switch option {
        case "Pet Vaccinations":
            if let vaccinationDetailsVC = storyboard?.instantiateViewController(withIdentifier: "VaccinationDetailsVC") as? Vaccination_Details {
                vaccinationDetailsVC.petId = petId
                navigationController?.pushViewController(vaccinationDetailsVC, animated: true)
            }

        case "Pet Diet":
            if let petDietVC = storyboard?.instantiateViewController(withIdentifier: "PetDetailsVC") as? Pet_Diet {
                petDietVC.petId = petId
                navigationController?.pushViewController(petDietVC, animated: true)
            }
        case "Pet Medications":
            if let petMedicationVC = storyboard?.instantiateViewController(withIdentifier: "PetMedicationVC") as? Pet_Medications {
                petMedicationVC.petId = petId
                navigationController?.pushViewController(petMedicationVC, animated: true)
            }
        default:
            break
        }
    }
    
    // Set a consistent cell height if desired
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
