//
//  User Login.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 14/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class User_Login: UIViewController {
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
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
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        passwordTextField.isSecureTextEntry = true
        setupActivityIndicator()
        emailErrorLabel.isHidden = true
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)


    }
    
    @objc private func didTapView() {

        view.endEditing(true)
        
        // Hide the error label and reset border
        emailErrorLabel.isHidden = true
        emailTextField.layer.borderWidth = 0
        emailTextField.layer.borderColor = UIColor.clear.cgColor
    }

    
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        guard let email = textField.text else { return }
        
        if isValidEmail(email) {
            // Example feedback: green border for valid email
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor

            emailErrorLabel.isHidden = true
        } else {
            // Red border for invalid email (or remove border if you prefer)
            emailErrorLabel.isHidden = false
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemRed.cgColor
            textField.layer.cornerRadius = 8
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
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
        
        showLoadingIndicator() // shows the spinner
        
        // Firebase Login
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.hideLoadingIndicator()
                self.showAlert("Login Failed", error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                self.hideLoadingIndicator()
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
                self.hideLoadingIndicator()
                if isCaretaker || isDogwalker {
                    self.navigateToCaretakerHome()
                } else {
                    self.navigateToRegularHome()
                }
            }
        }
    }
    
    // MARK: - Activity Indicator
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

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
