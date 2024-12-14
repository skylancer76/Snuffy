//
//  User Sign Up.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 14/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class User_Sign_Up: UIViewController {

    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var termsButton: UIButton!
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    
    
    let db = Firestore.firestore()
    
    var hasAgreedToTerms: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.layer.cornerRadius = 30
        signUpButton.layer.masksToBounds = true
    }
    
    @IBAction func termsButtonTapped(_ sender: Any) {
        hasAgreedToTerms.toggle() // Toggle agreement state
        updateTermsButtonAppearance()
    }
    
    func updateTermsButtonAppearance() {
        let checkboxImage = hasAgreedToTerms ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        termsButton.setImage(checkboxImage, for: .normal)
        termsButton.tintColor = .systemPurple
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty,
        let email = emailTextField.text, !email.isEmpty,
        let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
                
        if !hasAgreedToTerms {
            showAlert(title: "Error", message: "You must agree to the terms and conditions.")
            return
        }
                
        let role = roleSegmentedControl.selectedSegmentIndex == 0 ? "Pet Owner" : "Pet Caretaker"
                
        // MARK: - Create User with Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                    
                // Save Additional User Data to Firestore
                if let user = authResult?.user {
                    self.saveUserDataToFirestore(uid: user.uid, name: name, email: email, role: role)
                }
        }

    }
    
    // MARK: - Save User Data to Firestore
    func saveUserDataToFirestore(uid: String, name: String, email: String, role: String) {
        let userData: [String: Any] = [
            "uid": uid,
            "name": name,
            "email": email,
            "role": role,
            "createdAt": Timestamp()
        ]
           
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Success", message: "Account created successfully!", completion: {
                    // Navigate to Login Screen or Home Screen
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
       
    // MARK: - Helper: Show Alert
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }

}
