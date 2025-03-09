//
//  User Profile.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 11/02/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class User_Profile: UITableViewController {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchUserProfile()
    }
    
    func setupUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }
    
    
    func fetchUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        //            db.collection("users").document(userId).getDocument { (document, error) in
        //                if let document = document, document.exists, let data = document.data() {
        //
        //                    let name = data["name"] as? String ?? "User"
        //                    let email = data["email"] as? String ?? "No Email"
        //                    let profileImageUrl = data["profileImageUrl"] as? String
        //
        //                    self.nameLabel.text = name
        //                    self.emailLabel.text = email
        //
        //                    if let imageUrl = profileImageUrl {
        //                        self.loadProfileImage(from: imageUrl)
        //                    } else {
        //                        self.setInitialsAsProfileImage(name: name)
        //                    }
        //
        //                } else {
        //                    print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
        //                    self.nameLabel.text = "User"
        //                    self.emailLabel.text = "No Email"
        //                    self.setInitialsAsProfileImage(name: "User")
        //                }
        //            }
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                self.updateProfileUI(with: data)
                return
            }
            
            // If not found in "users", check "caretakers"
            db.collection("caretakers").whereField("caretakerId", isEqualTo: userId).getDocuments { (caretakerSnapshot, error) in
                if let caretakerSnapshot = caretakerSnapshot, !caretakerSnapshot.documents.isEmpty,
                   let caretakerData = caretakerSnapshot.documents.first?.data() {
                    self.updateProfileUI(with: caretakerData)
                    return
                }
                
                // If not found in "caretakers", check "dogwalkers"
                db.collection("dogwalkers").whereField("dogWalkerId", isEqualTo: userId).getDocuments { (dogwalkerSnapshot, error) in
                    if let dogwalkerSnapshot = dogwalkerSnapshot, !dogwalkerSnapshot.documents.isEmpty,
                       let dogwalkerData = dogwalkerSnapshot.documents.first?.data() {
                        self.updateProfileUI(with: dogwalkerData)
                    } else {
                        // If user is not found in any collection, log them out
                        self.redirectToLogin()
                    }
                }
            }
        }
    }

    func updateProfileUI(with data: [String: Any]) {
        let name = data["name"] as? String ?? "User"
        let email = data["email"] as? String ?? "No Email"
        let profileImageUrl = data["profileImageUrl"] as? String
        
        self.nameLabel.text = name
        self.emailLabel.text = email
        
        if let imageUrl = profileImageUrl {
            self.loadProfileImage(from: imageUrl)
        } else {
            self.setInitialsAsProfileImage(name: name)
        }
    }
    
    func loadProfileImage(from url: String) {
            let storageRef = Storage.storage().reference(forURL: url)
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error loading profile image: \(error.localizedDescription)")
                    self.setInitialsAsProfileImage(name: self.nameLabel.text ?? "User")
                } else if let data = data, let image = UIImage(data: data) {
                    self.profileImageView.image = image
                }
            }
        }
    
    
    func setInitialsAsProfileImage(name: String) {
            let initials = getInitials(from: name)
            profileImageView.image = createProfileImage(with: initials)
        }
        
        func getInitials(from name: String) -> String {
            let nameParts = name.split(separator: " ")
            let initials = nameParts.compactMap { $0.first }.map { String($0) }.joined()
            return initials.isEmpty ? "U" : initials.uppercased()
        }
        
        func createProfileImage(with initials: String) -> UIImage {
            let size = CGSize(width: 80, height: 80)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            let context = UIGraphicsGetCurrentContext()
            
            let rect = CGRect(origin: .zero, size: size)
            UIColor.systemGray.setFill()
            context?.fillEllipse(in: rect)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30, weight: .bold),
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
        
        @IBAction func logoutTapped(_ sender: UIButton) {
            do {
                try Auth.auth().signOut()
                redirectToLogin()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
        
//    func redirectToLogin() {
//        let loginVC = storyboard?.instantiateViewController(withIdentifier: "login") as! User_Login
//        loginVC.modalPresentationStyle = .fullScreen
//        present(loginVC, animated: true, completion: nil)
//    }

    func redirectToLogin() {
            do {
                try Auth.auth().signOut()
                let loginVC = storyboard?.instantiateViewController(withIdentifier: "login") as! User_Login
                loginVC.modalPresentationStyle = .fullScreen
                present(loginVC, animated: true, completion: nil)
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
}
