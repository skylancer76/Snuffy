//
//  User Login.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 14/12/24.
//

import UIKit
import FirebaseAuth

class User_Login: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        
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
                
            if authResult != nil {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController {
                            
                            tabBarVC.modalPresentationStyle = .fullScreen
                            self.present(tabBarVC, animated: true, completion: nil)
                        } else {
                            self.showAlert("Error", "Home screen could not be loaded.")
                        }
                    }
                }
        }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }

}
