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

    // MARK: - Outlets
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    // MARK: - Properties
    let db = Firestore.firestore()
    var hasAgreedToTerms: Bool = false

    // Activity Indicator
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - View Lifecycle
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
        
        appLogo.layer.cornerRadius = appLogo.frame.height / 2
        appLogo.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        passwordTextField.isSecureTextEntry = true
        
        // Hide the email error label initially
        emailErrorLabel.isHidden = true
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        
        // Add tap gesture to dismiss keyboard and hide error label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Setup the activity indicator in the view
        setupActivityIndicator()
        
        // Set self as delegate for text fields for border highlighting
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: - Email Validation in Real-Time
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        guard let email = textField.text else { return }
        
        // Always use systemPink for the border color
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.layer.cornerRadius = 8
        
        if isValidEmail(email) {
            emailErrorLabel.isHidden = true
        } else {
            emailErrorLabel.isHidden = false
            emailErrorLabel.text = "Invalid email format"
        }
    }
    
    @objc private func didTapView() {
        // Dismiss keyboard
        view.endEditing(true)
        
        // Hide error label and reset email field border if needed
        emailErrorLabel.isHidden = true
        emailTextField.layer.borderWidth = 0
        emailTextField.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
   
    // MARK: - Password Visibility Toggle
    @IBAction func passwordViewTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    // MARK: - Terms & Conditions Toggle
    @IBAction func termsButtonTapped(_ sender: Any) {
        hasAgreedToTerms.toggle() // Toggle agreement state
        updateTermsButtonAppearance()
    }
    
    func updateTermsButtonAppearance() {
        let config = UIImage.SymbolConfiguration(scale: .medium)
        let checkboxImage = hasAgreedToTerms ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        termsButton.setImage(checkboxImage, for: .normal)
        termsButton.tintColor = .systemPurple
    }
    
    // MARK: - Sign Up Action
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
        
        let selectedIndex = roleSegmentedControl.selectedSegmentIndex
        
        // Show the loading spinner
        showLoadingIndicator()
        
        // Create User with Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.hideLoadingIndicator() // Hide if createUser fails
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                self.hideLoadingIndicator()
                return
            }
            
            // Save Firestore data based on selected role.
            if selectedIndex == 0 {
                self.saveUserDataToFirestore(uid: user.uid, name: name, email: email, role: "Pet Owner")
            } else if selectedIndex == 1 {
                self.saveCaretakerDataToFirestore(uid: user.uid, name: name, email: email, password: password)
            } else {
                self.saveDogWalkerDataToFirestore(uid: user.uid, name: name, email: email, password: password)
            }
        }
    }
    
    // MARK: - Firestore Save Methods
    func saveUserDataToFirestore(uid: String, name: String, email: String, role: String) {
        let userData: [String: Any] = [
            "uid": uid,
            "name": name,
            "email": email,
            "role": role,
            "createdAt": Timestamp()
        ]
           
        db.collection("users").document(uid).setData(userData) { error in
            self.hideLoadingIndicator()
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
            } else {
                self.navigateToHomeScreen()
            }
        }
    }
    
    func saveCaretakerDataToFirestore(uid: String, name: String, email: String, password: String) {
        let caretakerData: [String: Any] = [
            "caretakerId": uid,
            "name": name,
            "email": email,
            "password": password,
            "profilePic": "",
            "bio": "",
            "experience": 0,
            "address": "",
            "location": [0.0, 0.0],
            "distanceAway": 0.0,
            "status": "available",
            "pendingRequests": [],
            "completedRequests": 0,
            "createdAt": Timestamp()
        ]
        db.collection("caretakers").document(uid).setData(caretakerData) { error in
            self.hideLoadingIndicator()
            if let error = error {
                self.showAlert(title: "Error", message: "Error saving caretaker data to Firestore: \(error.localizedDescription)")
            } else {
                self.navigateToHomeScreen()
            }
        }
    }
    
    func saveDogWalkerDataToFirestore(uid: String, name: String, email: String, password: String) {
         let dogWalkerData: [String: Any] = [
             "dogWalkerId": uid,
             "name": name,
             "email": email,
             "password": password,
             "profilePic": "",
             "rating": "0.0",
             "address": "",
             "location": [0.0, 0.0],
             "distanceAway": 0.0,
             "status": "available",
             "pendingRequests": [],
             "completedRequests": 0,
             "phoneNumber": "",
             "createdAt": Timestamp()
         ]
         db.collection("dogWalkers").document(uid).setData(dogWalkerData) { error in
             self.hideLoadingIndicator()
             if let error = error {
                 self.showAlert(title: "Error", message: "Error saving dog walker data: \(error.localizedDescription)")
             } else {
                 self.navigateToHomeScreen()
             }
         }
     }
    
    // MARK: - Navigation
    func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController {
            tabBarVC.modalPresentationStyle = .fullScreen
            self.present(tabBarVC, animated: true, completion: nil)
        } else {
            self.showAlert(title: "Error", message: "Home screen could not be loaded.")
        }
    }
    
    // MARK: - Activity Indicator Methods
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - Helper: Show Alert
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion?()
            })
        )
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate for Border Highlighting
extension User_Sign_Up: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // When editing begins, set the border to systemPink
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.layer.cornerRadius = 8
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // For the email text field, if valid, remove the border; otherwise, keep it.
        if textField == emailTextField {
            if let email = textField.text, !email.isEmpty, isValidEmail(email) {
                textField.layer.borderWidth = 0
                textField.layer.borderColor = UIColor.clear.cgColor
            } else {
                // Keep systemPink border if email is invalid
                textField.layer.borderWidth = 1
                textField.layer.borderColor = UIColor.systemPink.cgColor
            }
        } else {
            // For other text fields, clear the border when editing ends.
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
