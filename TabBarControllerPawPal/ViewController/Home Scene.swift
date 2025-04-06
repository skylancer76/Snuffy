//
//  Home Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class Home_Scene: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var petSittingBgView: UIView!
    @IBOutlet weak var petWalkingBgView: UIView!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var petSittingImage: UIImageView!
    @IBOutlet weak var petWalkingImage: UIImageView!
    
    @IBOutlet weak var homePetsCollectionView: UICollectionView!
    
    private var homePets: [PetData] = []
    private var homePetsListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gradient Background Setup
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
        
        bgView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        
        // Pet Sitting Background View
        petSittingBgView.layer.cornerRadius = 10
        petSittingImage.layer.cornerRadius = 10
        petSittingBgView.layer.masksToBounds = false
        petSittingBgView.layer.shadowRadius = 5
        petSittingBgView.layer.shadowOffset = CGSize(width: 2, height: 2)
        petSittingBgView.layer.shadowOpacity = 0.2
        
        // Pet Walking Background View
        petWalkingBgView.layer.cornerRadius = 10
        petWalkingImage.layer.cornerRadius = 10
        petWalkingBgView.layer.masksToBounds = false
        petWalkingBgView.layer.shadowOffset = CGSize(width: 2, height: 2)
        petWalkingBgView.layer.shadowRadius = 5
        petWalkingBgView.layer.shadowOpacity = 0.2
        
        homePetsCollectionView.delegate = self
        homePetsCollectionView.dataSource = self
        homePetsCollectionView.backgroundColor = .clear
        
        if let layout = homePetsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        checkUserAuthentication()
        fetchPetsForHomeScreen()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserNameAndSetupProfileIcon()
    }
    
    // MARK: - Auth
    func checkUserAuthentication() {
        if Auth.auth().currentUser == nil {
            redirectToLogin()
        }
    }
    
    func redirectToLogin() {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "login") as! User_Login
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)
    }
    
    // MARK: - Firestore Pets
    func fetchPetsForHomeScreen() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        homePetsListener = db.collection("Pets")
            .whereField("ownerID", isEqualTo: currentUser.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching pet data for Home: \(error.localizedDescription)")
                    return
                }
                self.homePets = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    return PetData(
                        petId: data["petId"] as? String ?? "",
                        petImage: data["petImage"] as? String,
                        petName: data["petName"] as? String,
                        petBreed: data["petBreed"] as? String,
                        petGender: data["petGender"] as? String,
                        petAge: data["petAge"] as? String,
                        petWeight: data["petWeight"] as? String
                    )
                } ?? []
                DispatchQueue.main.async {
                    self.homePetsCollectionView.reloadData()
                }
            }
    }
    
    // MARK: - Profile Icon
    func fetchUserNameAndSetupProfileIcon() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document,
               document.exists,
               let data = document.data(),
               let name = data["name"] as? String {
                self.setupProfileIcon(with: name)
            } else {
                print("User document not found: \(error?.localizedDescription ?? "Unknown error")")
                self.setupProfileIcon(with: "User")
            }
        }
    }
    
    func setupProfileIcon(with name: String) {
        let accessoryView = UIButton(type: .custom)
        let initials = getInitials(from: name)
        let profileImage = createProfileImage(with: initials)
        accessoryView.setImage(profileImage, for: .normal)
        accessoryView.frame.size = CGSize(width: 34, height: 34)
        accessoryView.layer.cornerRadius = 17
        accessoryView.layer.masksToBounds = true
        accessoryView.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        let largeTitleView = navigationController?.navigationBar.subviews.first { subview in
            return String(describing: type(of: subview)) == "_UINavigationBarLargeTitleView"
        }
        largeTitleView?.perform(Selector(("setAccessoryView:")), with: accessoryView)
        largeTitleView?.perform(Selector(("setAlignAccessoryViewToTitleBaseline:")), with: nil)
        largeTitleView?.perform(Selector(("updateContent")))
    }
    
    func getInitials(from name: String) -> String {
        let nameParts = name.split(separator: " ")
        let initials = nameParts.compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? "U" : initials.uppercased()
    }
    
    func createProfileImage(with initials: String) -> UIImage {
        let size = CGSize(width: 34, height: 34)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: .zero, size: size)
        UIColor.systemGray.setFill()
        context?.fillEllipse(in: rect)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let textSize = initials.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        initials.draw(in: textRect, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    @objc func profileTapped() {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "Profile") as! User_Profile
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPetProfileFromHome",
           let destinationVC = segue.destination as? Pet_Profile,
           let selectedPet = sender as? PetData {
            print("Received Pet ID: \(selectedPet.petId)")
            destinationVC.petId = selectedPet.petId
            destinationVC.hidesBottomBarWhenPushed = true
        } else {
            print("Pet ID is missing!")
        }
    }
}

// MARK: - UICollectionView Setup
extension Home_Scene: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homePets.isEmpty ? 1 : homePets.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if homePets.isEmpty || indexPath.item == homePets.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPetCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
            cell.contentView.backgroundColor = .systemPink.withAlphaComponent(0.2)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCells", for: indexPath) as! MyPetsCell
            let pet = homePets[indexPath.item]
            cell.configure(with: pet)
            
            cell.backgroundColor = .clear
            cell.contentView.layer.cornerRadius = 12
            cell.layer.masksToBounds = false
            cell.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.layer.shadowOpacity = 0.2
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if homePets.isEmpty || indexPath.item == homePets.count {
            MoveToMyPets()
        } else {
            let selectedPet = homePets[indexPath.item]
            performSegue(withIdentifier: "ShowPetProfileFromHome", sender: selectedPet)
        }
    }
    
    func MoveToMyPets() {
        
        guard let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController else {
            print("Failed to instantiate main tab bar controller")
            return
        }
        
        mainTabBarController.selectedIndex = 2

        mainTabBarController.modalPresentationStyle = .fullScreen
        present(mainTabBarController, animated: true, completion: nil)
    }


    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
