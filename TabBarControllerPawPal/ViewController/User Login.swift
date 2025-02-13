//
//  User Login.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 14/12/24.
//

//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//class User_Login: UIViewController {
//
//    @IBOutlet weak var emailTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var loginButton: UIButton!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        loginButton.layer.cornerRadius = 10
//        loginButton.layer.masksToBounds = true
//        passwordTextField.isSecureTextEntry = true
//    }
//    
//    
//    @IBAction func passwordViewTapped(_ sender: UIButton) {
//        passwordTextField.isSecureTextEntry.toggle()
//        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
//        sender.setImage(UIImage(systemName: imageName), for: .normal)
//    }
//    
//    
//    
//    @IBAction func loginClicked(_ sender: Any) {
//        guard let email = emailTextField.text, !email.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty else {
//            showAlert("Error", "Please fill in all fields")
//            return
//        }
//                
//        // Firebase Login
//        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                self.showAlert("Login Failed", error.localizedDescription)
//                return
//            }
//            
//            if let user = authResult?.user {
//                self.checkIfUserIsCaretaker(userID: user.uid)
//            }
//            
//            if let user = authResult?.user {
//                self.checkIfUserIsDogWalker(userID: user.uid)
//            }
//        }
//    }
//    
//    //  Check if the user is a caretaker in Firestore
//    func checkIfUserIsCaretaker(userID: String) {
//        let db = Firestore.firestore()
//        let caretakersRef = db.collection("caretakers")
//
//        caretakersRef.whereField("caretakerId", isEqualTo: userID).getDocuments { snapshot, error in
//            if let error = error {
//                self.showAlert("Error", "Could not verify user role: \(error.localizedDescription)")
//                return
//            }
//            
//            if let snapshot = snapshot, !snapshot.documents.isEmpty {
//                // The user is a caretaker
//                self.navigateToCaretakerHome()
//            } else {
//                //  Regular user navigation
//                self.navigateToRegularHome()
//            }
//        }
//    }
//    
//    func checkIfUserIsDogWalker(userID: String) {
//        let db = Firestore.firestore()
//        let caretakersRef = db.collection("dogwalkers")
//
//        caretakersRef.whereField("dogWalkerId", isEqualTo: userID).getDocuments { snapshot, error in
//            if let error = error {
//                self.showAlert("Error", "Could not verify user role: \(error.localizedDescription)")
//                return
//            }
//            
//            if let snapshot = snapshot, !snapshot.documents.isEmpty {
//                // The user is a caretaker
//                self.navigateToCaretakerHome()
//            } else {
//                //  Regular user navigation
//                self.navigateToRegularHome()
//            }
//        }
//    }
//    
//    //  Navigate caretakers to Caretaker Home
//    func navigateToCaretakerHome() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let caretakerTabBarVC = storyboard.instantiateViewController(withIdentifier: "CaretakerTabBarController") as? UITabBarController {
//            caretakerTabBarVC.modalPresentationStyle = .fullScreen
//            self.present(caretakerTabBarVC, animated: true, completion: nil)
//        } else {
//            self.showAlert("Error", "Caretaker home could not be loaded.")
//        }
//    }
//
//    //  Navigate regular users to User Home (Updated to use "TabBarControllerID")
//    func navigateToRegularHome() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let userTabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController {
//            userTabBarVC.modalPresentationStyle = .fullScreen
//            self.present(userTabBarVC, animated: true, completion: nil)
//        } else {
//            self.showAlert("Error", "User home could not be loaded.")
//        }
//    }
//
//    //  Helper function to show alerts
//    func showAlert(_ title: String, _ message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true, completion: nil)
//    }
//    
//}

import UIKit
import FirebaseAuth
import FirebaseFirestore

class User_Login: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func passwordViewTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Error", "Please fill in all fields")
            return
        }
        
        // Firebase Login
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert("Login Failed", error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                self.showAlert("Error", "User not found")
                return
            }
            
            // Use DispatchGroup to combine caretaker and dog walker checks
            let group = DispatchGroup()
            var isCaretaker = false
            var isDogwalker = false
            
            group.enter()
            self.checkIfUserIsCaretaker(userID: user.uid) { result in
                isCaretaker = result
                group.leave()
            }
            
            group.enter()
            self.checkIfUserIsDogWalker(userID: user.uid) { result in
                isDogwalker = result
                group.leave()
            }
            
            group.notify(queue: .main) {
                if isCaretaker || isDogwalker {
                    self.navigateToCaretakerHome()
                } else {
                    self.navigateToRegularHome()
                }
            }
        }
    }
    
    // MARK: - Role Checking Methods
    
    func checkIfUserIsCaretaker(userID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let caretakersRef = db.collection("caretakers")
        
        caretakersRef.whereField("caretakerId", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error verifying caretaker role: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkIfUserIsDogWalker(userID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let dogWalkersRef = db.collection("dogwalkers")
        
        dogWalkersRef.whereField("dogWalkerId", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error verifying dog walker role: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    func navigateToCaretakerHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let caretakerTabBarVC = storyboard.instantiateViewController(withIdentifier: "CaretakerTabBarController") as? UITabBarController {
            caretakerTabBarVC.modalPresentationStyle = .fullScreen
            self.present(caretakerTabBarVC, animated: true, completion: nil)
        } else {
            self.showAlert("Error", "Caretaker home could not be loaded.")
        }
    }
    
    func navigateToRegularHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userTabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController {
            userTabBarVC.modalPresentationStyle = .fullScreen
            self.present(userTabBarVC, animated: true, completion: nil)
        } else {
            self.showAlert("Error", "User home could not be loaded.")
        }
    }
    
    // MARK: - Helper
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
