//
//  Caretaker Home.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.

import UIKit
import FirebaseAuth
import FirebaseFirestore

class Caretaker_Home: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    
    var scheduleRequests: [ScheduleCaretakerRequest] = []
    var dogWalkerRequests: [ScheduleDogWalkerRequest] = []
    
    // These will be set if the user is found in the corresponding collection.
    var caretakerId: String?
    var dogWalkerId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: No user logged in")
            return
        }
        
        let userId = currentUser.uid
        let db = Firestore.firestore()
        
        // First, check if the user is registered as a caretaker.
        db.collection("caretakers").whereField("caretakerId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking caretaker: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                self.caretakerId = userId
                self.fetchCaretakerRequests()
            } else {
                // If not a caretaker, check if the user is a dog walker.
                db.collection("dogwalkers").whereField("dogWalkerId", isEqualTo: userId).getDocuments { snapshot, error in
                    if let error = error {
                        print("Error checking dogwalker: \(error.localizedDescription)")
                        return
                    }
                    if let snapshot = snapshot, !snapshot.documents.isEmpty {
                        self.dogWalkerId = userId
                        self.fetchDogWalkerRequests()
                    } else {
                        print("User role is not recognized.")
                    }
                }
            }
        }
        
        setupUI()
    }
    
    // MARK: - Fetch Requests
    
    func fetchCaretakerRequests() {
        guard let caretakerId = caretakerId else { return }
        FirebaseManager.shared.fetchAssignedRequests(for: caretakerId) { requests in
            self.scheduleRequests = requests
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchDogWalkerRequests() {
        guard let dogWalkerId = dogWalkerId else { return }
        FirebaseManager.shared.fetchAssignedDogWalkerRequests(for: dogWalkerId) { requests in
            self.dogWalkerRequests = requests
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - UI Setup
    
    func setupUI() {
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        tableView.backgroundColor = .clear
        bgView.backgroundColor = .clear
    }
    
    // MARK: - Accept Request Actions
    
    @objc func acceptCaretakerRequest(_ sender: UIButton) {
        guard sender.tag < scheduleRequests.count,
              let caretakerId = self.caretakerId else { return }
        let request = scheduleRequests[sender.tag]
        
        FirebaseManager.shared.acceptRequest(caretakerId: caretakerId, requestId: request.requestId) { error in
            if let error = error {
                print("Error accepting request: \(error.localizedDescription)")
            } else {
                self.scheduleRequests.remove(at: sender.tag)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func acceptDogWalkerRequest(_ sender: UIButton) {
        // For dog walker requests, the button's tag corresponds to the index in dogWalkerRequests.
        let dogWalkerIndex = sender.tag
        guard dogWalkerIndex < dogWalkerRequests.count,
              let dogWalkerId = self.dogWalkerId else { return }
        let request = dogWalkerRequests[dogWalkerIndex]
        
        FirebaseManager.shared.acceptDogWalkerRequest(dogWalkerId: dogWalkerId, requestId: request.requestId) { error in
            if let error = error {
                print("Error accepting dog walker request: \(error.localizedDescription)")
            } else {
                self.dogWalkerRequests.remove(at: dogWalkerIndex)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleRequests.count + dogWalkerRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestTableViewCell
                cell.backgroundColor = .clear
                cell.bgView.layer.cornerRadius = 10
                cell.bgView.layer.masksToBounds = false
                cell.bgView.layer.shadowRadius = 5
                cell.bgView.layer.shadowOpacity = 0.1
                
                // Ensure pet image view styling
                cell.petImageView.layer.cornerRadius = 10
                cell.petImageView.layer.masksToBounds = true
                
                if indexPath.row < scheduleRequests.count {
                    // Configure a caretaker request cell.
                let request = scheduleRequests[indexPath.row]
                cell.petNameLabel.text = request.petName
                cell.ownerNameLabel.text = request.userName
                cell.petBreedLabel.text = request.petBreed ?? "Breed Not Available"
                cell.durationLabel.text = request.duration
                    
                    // Load pet image for caretaker request.
                    if let imageUrlString = request.petImageUrl, !imageUrlString.isEmpty, let url = URL(string: imageUrlString) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    cell.petImageView.image = UIImage(data: data)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    cell.petImageView.image = UIImage(named: "placeholder")
                                }
                            }
                        }
                    } else {
                        cell.petImageView.image = UIImage(named: "placeholder")
                    }
                    
                    cell.acceptButton.tag = indexPath.row
                    cell.acceptButton.addTarget(self, action: #selector(acceptCaretakerRequest(_:)), for: .touchUpInside)
                } else {
                    // Configure a dog walker request cell.
                    let dogWalkerIndex = indexPath.row - scheduleRequests.count
                    let request = dogWalkerRequests[dogWalkerIndex]
                    
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h a"
                    let startTime = timeFormatter.string(from: request.startTime)
                    let endTime = timeFormatter.string(from: request.endTime)
                    
                    cell.petNameLabel.text = request.petName
                    cell.ownerNameLabel.text = request.userName
                    cell.petBreedLabel.text = request.petBreed ?? "Breed Not Available"
                    cell.durationLabel.text = "\(startTime) to \(endTime)"
                    
                    // Load pet image for dog walker request.
                    if let imageUrlString = request.petImageUrl, !imageUrlString.isEmpty, let url = URL(string: imageUrlString) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    cell.petImageView.image = UIImage(data: data)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    cell.petImageView.image = UIImage(named: "placeholder")
                                }
                            }
                        }
                    } else {
                        cell.petImageView.image = UIImage(named: "placeholder")
                    }
                    
                    cell.acceptButton.tag = dogWalkerIndex
                    cell.acceptButton.addTarget(self, action: #selector(acceptDogWalkerRequest(_:)), for: .touchUpInside)
                }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserNameAndSetupProfileIcon()
    }

    func fetchUserNameAndSetupProfileIcon() {
        guard let userId = Auth.auth().currentUser?.uid else {
            redirectToLogin()
            return
        }

        let db = Firestore.firestore()

        // Check in "caretakers" collection
        db.collection("caretakers").whereField("caretakerId", isEqualTo: userId).getDocuments { (caretakerSnapshot, error) in
            if let caretakerSnapshot = caretakerSnapshot, !caretakerSnapshot.documents.isEmpty,
               let caretakerData = caretakerSnapshot.documents.first?.data(),
               let name = caretakerData["name"] as? String {
                self.setupProfileIcon(with: name)
                return
            }

            // If not found in caretakers, check in "dogwalkers"
            db.collection("dogwalkers").whereField("dogWalkerId", isEqualTo: userId).getDocuments { (dogwalkerSnapshot, error) in
                if let dogwalkerSnapshot = dogwalkerSnapshot, !dogwalkerSnapshot.documents.isEmpty,
                   let dogwalkerData = dogwalkerSnapshot.documents.first?.data(),
                   let name = dogwalkerData["name"] as? String {
                    self.setupProfileIcon(with: name)
                } else {
                    // If user does not exist in either caretakers or dogwalkers, log them out
                    self.redirectToLogin()
                }
            }
        }
    }

    // MARK: - Profile Icon Setup
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

    // MARK: - Profile Button Action
    @objc func profileTapped() {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "Profile") as! User_Profile
        navigationController?.pushViewController(profileVC, animated: true)
    }

    // MARK: - Redirect to Login if User Not Found
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
