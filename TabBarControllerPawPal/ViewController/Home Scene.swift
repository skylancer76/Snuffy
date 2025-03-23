//
//  Home Scene.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 15/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MessageUI 

class Home_Scene: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var petSittingBgView: UIView!
    @IBOutlet weak var petWalkingBgView: UIView!
    @IBOutlet weak var scrollView: UIView!
    
    // Array to store combined caretaker & dog walker upcoming bookings
    private var upcomingBookings: [UpcomingBookingModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up gradient background.
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
        
        // Checking if the user is authenticated
        checkUserAuthentication()

        // Clear background for the gradient
        bgView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        
        petSittingBgView.layer.cornerRadius = 10
        petSittingBgView.clipsToBounds = true
        
        petWalkingBgView.layer.cornerRadius = 10
        petWalkingBgView.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserNameAndSetupProfileIcon()

    }
    
    func checkUserAuthentication() {
            if Auth.auth().currentUser == nil {
                redirectToLogin()
            }
        }
    
    func fetchUserNameAndSetupProfileIcon() {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { (document, error) in
                if let document = document, document.exists, let data = document.data(), let name = data["name"] as? String {
                    self.setupProfileIcon(with: name)
                } else {
                    print("User document not found: \(error?.localizedDescription ?? "Unknown error")")
                    self.setupProfileIcon(with: "User") // Default placeholder
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
            
            // Background Circle
            let rect = CGRect(origin: .zero, size: size)
            UIColor.systemGray.setFill()
            context?.fillEllipse(in: rect)
            
            // Initials Text
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
        
        func redirectToLogin() {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "login") as! User_Login
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        }

}
    
