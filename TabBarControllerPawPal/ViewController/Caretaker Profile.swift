//
//  Caretaker Profile.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 21/03/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import CoreLocation

// MARK: - Main Class
class Caretaker_Profile: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    @IBOutlet weak var caretakerDetailsInfo: UIView!
    @IBOutlet weak var petSitterLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // MARK: - Properties
    var profileId: String?
    var profileType: ProfileType = .caretaker
    
    var caretaker: Caretakers?
    var galleryImageNames: [String] = []
    
    // Location Manager
    let locationManager = CLLocationManager()
    var currentUserLocation: CLLocation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up a gradient background for styling
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
        
        caretakerDetailsInfo.layer.cornerRadius = 12
        caretakerDetailsInfo.layer.masksToBounds = true
        caretakerDetailsInfo.backgroundColor = .systemPink.withAlphaComponent(0.1)
        
        distanceLabel.text = "Distance unavailable"
        
        setupLocationManager()
        
        if let profileId = profileId, currentUserLocation != nil, caretaker == nil {
            fetchCaretakerData(caretakerId: profileId)
        }
        
        if let flowLayout = galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let spacing: CGFloat = 8
            flowLayout.minimumLineSpacing = spacing
            flowLayout.minimumInteritemSpacing = spacing
                
            let width = (galleryCollectionView.bounds.width - (spacing * 3)) / 2
            flowLayout.itemSize = CGSize(width: width, height: width * 1.3)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Location Manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Called whenever location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            currentUserLocation = loc
            // Stop if only need one update
            locationManager.stopUpdatingLocation()
            
            // If caretaker not yet fetched, fetch now
            if let profileId = profileId, caretaker == nil {
                fetchCaretakerData(caretakerId: profileId)
            }
        }
    }
    
    // MARK: - Firestore Fetch
    private func fetchCaretakerData(caretakerId: String) {
        let db = Firestore.firestore()
        
        db.collection("caretakers")
            .whereField("caretakerId", isEqualTo: caretakerId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching caretaker: \(error.localizedDescription)")
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    print("No caretaker found for ID: \(caretakerId)")
                    return
                }
                
                let data = doc.data() // [String: Any]
                // Use your dictionary-based convenience init
                if let fetchedCaretaker = Caretakers(dictionary: data) {
                    self.caretaker = fetchedCaretaker
                    print("Caretaker fetched successfully:", fetchedCaretaker.name)
                    
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.updateCaretakerUI(with: fetchedCaretaker)
                    }
                } else {
                    print("Failed to create Caretakers from dictionary.")
                }
            }
    }
    
    // MARK: - Update UI
    private func updateCaretakerUI(with caretaker: Caretakers) {
        // Basic fields
        nameLabel.text = caretaker.name
        addressLabel.text = caretaker.address
        bioLabel.text = caretaker.bio
        petSitterLabel.text = caretaker.petSitted
        
        // Rating
        if let ratingStr = caretaker.rating, !ratingStr.isEmpty {
            ratingLabel.text = "\(ratingStr) ★"
        } else {
            ratingLabel.text = "N/A"
        }
        
        // Profile Pic
        if let profilePic = caretaker.profilePic,
           let url = URL(string: profilePic) {
            profileImageView.loadImage(from: url)
        } else {
            profileImageView.image = UIImage(named: "placeholder")
        }
        
        // Gallery
        galleryImageNames = caretaker.galleryImages ?? []
        galleryCollectionView.reloadData()
        
        // Distance
        if let lat = caretaker.latitude,
           let lon = caretaker.longitude,
           let userLoc = currentUserLocation {
            let caretakerLoc = CLLocation(latitude: lat, longitude: lon)
            let distMeters = userLoc.distance(from: caretakerLoc)
            let distKm = distMeters / 1000.0
            distanceLabel.text = String(format: "%.1f km", distKm)
            
            // Optionally update Firestore with new distance
            updateDistanceInFirestore(for: "caretakers", id: caretaker.caretakerId, distance: distKm)
        } else {
            distanceLabel.text = "Distance unavailable"
        }
    }
    
    // MARK: - Update Firestore Distance
    private func updateDistanceInFirestore(for collection: String, id: String, distance: Double) {
        let db = Firestore.firestore()
        db.collection(collection).document(id).updateData(["distanceAway": distance]) { error in
            if let error = error {
                print("Error updating distance: \(error.localizedDescription)")
            } else {
                print("Distance updated successfully")
            }
        }
    }
}

// MARK: - UICollectionView
extension Caretaker_Profile: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GalleryCell",
            for: indexPath
        ) as! Caretaker_Profile_Gallery
        
        let imageName = galleryImageNames[indexPath.item]
        cell.galleryImage.image = UIImage(named: imageName) ?? UIImage(named: "placeholder")
        return cell
    }
}


extension Caretakers {
    convenience init?(dictionary: [String: Any]) {
        // Required fields that must exist in the dictionary
        guard
            let caretakerId = dictionary["caretakerId"] as? String,
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String,
            let password = dictionary["password"] as? String,
            let bio = dictionary["bio"] as? String,
            let experience = dictionary["experience"] as? Int,
            let address = dictionary["address"] as? String,
            let location = dictionary["location"] as? [Double],
            let distanceAway = dictionary["distanceAway"] as? Double,
            let status = dictionary["status"] as? String,
            let pendingRequests = dictionary["pendingRequests"] as? [String],
            let completedRequests = dictionary["completedRequests"] as? Int
        else {
            // If any required field is missing or has the wrong type, fail the init
            return nil
        }
        // rating could be a String or a numeric type
        var ratingString: String? = nil
        if let ratingVal = dictionary["rating"] {
            if let str = ratingVal as? String {
                ratingString = str
            } else if let num = ratingVal as? NSNumber {
                ratingString = num.stringValue
            }
        }

        // phoneNumber could be a String or a numeric type
        var phoneString: String? = nil
        if let phoneVal = dictionary["phoneNumber"] {
            if let str = phoneVal as? String {
                phoneString = str
            } else if let num = phoneVal as? NSNumber {
                phoneString = num.stringValue
                }
            }

        // Optional fields
        let profilePic = dictionary["profilePic"] as? String
        let petSitted = dictionary["petSitted"] as? String
        let galleryImages = dictionary["galleryImages"] as? [String]

        // Now call your primary initializer
        self.init(
            caretakerId: caretakerId,
            name: name,
            email: email,
            password: password,
            profilePic: profilePic,
            petSitted: petSitted,
            galleryImages: galleryImages,
            bio: bio,
            experience: experience,
            address: address,
            location: location,
            rating: ratingString,
            distanceAway: distanceAway,
            status: status,
            pendingRequests: pendingRequests,
            completedRequests: completedRequests,
            phoneNumber: phoneString
        )
    }
}
