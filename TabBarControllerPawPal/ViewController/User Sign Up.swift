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
    @IBOutlet weak var scrollView: UIScrollView! // Connect this in storyboard!
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - Properties
    let db = Firestore.firestore()
    var hasAgreedToTerms: Bool = false

    // MARK: - Activity Indicator
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
        
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        appLogo.layer.cornerRadius = appLogo.frame.height / 2
        appLogo.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        passwordTextField.isSecureTextEntry = true
        emailErrorLabel.isHidden = true
        
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setupActivityIndicator()

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self

        // Keyboard Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Keyboard Adjustments
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = keyboardFrame.height
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - Keyboard Dismissal
    @objc private func didTapView() {
        view.endEditing(true)
        emailErrorLabel.isHidden = true
        emailTextField.layer.borderWidth = 0
        emailTextField.layer.borderColor = UIColor.clear.cgColor
    }

    // MARK: - Real-time Email Validation
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        guard let email = textField.text else { return }
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.layer.cornerRadius = 8
        
        emailErrorLabel.isHidden = isValidEmail(email)
        if !emailErrorLabel.isHidden {
            emailErrorLabel.text = "Invalid email format"
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    // MARK: - Toggle Password Visibility
    @IBAction func passwordViewTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Terms & Conditions
    @IBAction func termsButtonTapped(_ sender: Any) {
        hasAgreedToTerms.toggle()
        updateTermsButtonAppearance()
    }

    func updateTermsButtonAppearance() {
        let image = hasAgreedToTerms ? "checkmark.square.fill" : "square"
        termsButton.setImage(UIImage(systemName: image), for: .normal)
        termsButton.tintColor = .systemPurple
    }

    // MARK: - Sign Up
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
        showLoadingIndicator()

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.hideLoadingIndicator()
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            guard let user = authResult?.user else {
                self.hideLoadingIndicator()
                return
            }

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
        let data: [String: Any] = [
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
        db.collection("caretakers").document(uid).setData(data) { error in
            self.hideLoadingIndicator()
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.navigateToHomeScreen()
            }
        }
    }

    func saveDogWalkerDataToFirestore(uid: String, name: String, email: String, password: String) {
        let data: [String: Any] = [
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
        db.collection("dogWalkers").document(uid).setData(data) { error in
            self.hideLoadingIndicator()
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
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
            present(tabBarVC, animated: true)
        } else {
            showAlert(title: "Error", message: "Home screen could not be loaded.")
        }
    }

    // MARK: - Activity Indicator
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

    // MARK: - Alerts
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in completion?() }))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension User_Sign_Up: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.layer.cornerRadius = 8
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField,
           let email = textField.text,
           !email.isEmpty,
           isValidEmail(email) {
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
        } else {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemPink.cgColor
        }
    }
}

