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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var petSittingBgView: UIView!
    @IBOutlet weak var petWalkingBgView: UIView!
    
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

        // Check user authentication
        checkUserAuthentication()

        // Clear background for the gradient
        bgView.backgroundColor = .clear
        tableView.backgroundColor = .clear

        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        
        // Set Corner Radius
        petSittingBgView.layer.cornerRadius = 10
        petSittingBgView.layer.masksToBounds = true
        petWalkingBgView.layer.cornerRadius = 10
        petWalkingBgView.layer.masksToBounds = true
        
        // Enable user interaction (just to be safe)
        petSittingBgView.isUserInteractionEnabled = true
        petWalkingBgView.isUserInteractionEnabled = true

        // Add tap gesture recognizers to the UIViews
        let petSittingTap = UITapGestureRecognizer(target: self, action: #selector(petSittingTapped))
        petSittingBgView.addGestureRecognizer(petSittingTap)
        
        let petWalkingTap = UITapGestureRecognizer(target: self, action: #selector(petWalkingTapped))
        petWalkingBgView.addGestureRecognizer(petWalkingTap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserNameAndSetupProfileIcon()

        // Refresh upcoming bookings each time the home screen appears
        fetchUpcomingBookings()
    }
    
    @objc func petSittingTapped() {
        // Push the PetSittingVC
        if let petSittingVC = storyboard?.instantiateViewController(withIdentifier: "PetSittingVC") as? Schedule_Request {
            navigationController?.pushViewController(petSittingVC, animated: true)
        }
    }

    @objc func petWalkingTapped() {
        // Push the PetWalkingVC
        if let petWalkingVC = storyboard?.instantiateViewController(withIdentifier: "PetWalkingVC") as? Schedule_Dogwalker_Request {
            navigationController?.pushViewController(petWalkingVC, animated: true)
        }
    }

    // MARK: - Authentication
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

    // MARK: - Profile Icon
    func fetchUserNameAndSetupProfileIcon() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists,
               let data = document.data(),
               let name = data["name"] as? String {
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

    // MARK: - Fetch Upcoming Bookings
    private func fetchUpcomingBookings() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            upcomingBookings.removeAll()
            tableView.reloadData()
            return
        }

        // Clear out existing data first
        upcomingBookings.removeAll()

        let group = DispatchGroup()  // So we can wait for both caretaker & dog walker fetches

        // 1) Fetch caretaker requests (scheduleRequests) with status = "Accepted" or "Ongoing"
        group.enter()
        Firestore.firestore().collection("scheduleRequests")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("status", in: ["Accepted", "Ongoing"])
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching caretaker requests: \(error.localizedDescription)")
                    group.leave()
                    return
                }
                guard let snapshot = snapshot else {
                    group.leave()
                    return
                }
                let caretakerRequests = snapshot.documents.compactMap { doc -> ScheduleCaretakerRequest? in
                    let data = doc.data()
                    return ScheduleCaretakerRequest(from: data)
                }

                // For each caretaker request, fetch caretaker details
                let innerGroup = DispatchGroup()
                for request in caretakerRequests {
                    innerGroup.enter()
                    let caretakerId = request.caretakerId
                    Firestore.firestore().collection("caretakers")
                        .whereField("caretakerId", isEqualTo: caretakerId)
                        .getDocuments { caretakerSnap, err in
                            if let err = err {
                                print("Error fetching caretaker info: \(err.localizedDescription)")
                                innerGroup.leave()
                            } else if let caretakerDoc = caretakerSnap?.documents.first {
                                let caretakerData = caretakerDoc.data()
                                if let caretaker = try? JSONDecoder().decode(Caretakers.self, from: JSONSerialization.data(withJSONObject: caretakerData)) {
                                    let phone = caretaker.phoneNumber ?? ""
                                    let name = caretaker.name
                                    let picURL = caretaker.profilePic ?? ""

                                    let model = UpcomingBookingModel(
                                        bookingId: request.requestId,
                                        bookingType: .caretaker,
                                        caretakerOrWalkerId: caretakerId,
                                        caretakerOrWalkerName: name,
                                        caretakerOrWalkerPhone: phone,
                                        caretakerOrWalkerImageURL: picURL,
                                        petName: request.petName
                                    )
                                    self.upcomingBookings.append(model)
                                }
                                innerGroup.leave()
                            } else {
                                innerGroup.leave()
                            }
                        }
                }

                innerGroup.notify(queue: .main) {
                    group.leave()
                }
            }

        // 2) Fetch dog walker requests (dogWalkerRequests) with status = "Accepted" or "Ongoing"
        group.enter()
        Firestore.firestore().collection("dogWalkerRequests")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("status", in: ["Accepted", "Ongoing"])
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching dog walker requests: \(error.localizedDescription)")
                    group.leave()
                    return
                }
                guard let snapshot = snapshot else {
                    group.leave()
                    return
                }
                let dogWalkerRequests = snapshot.documents.compactMap { doc -> ScheduleDogWalkerRequest? in
                    let data = doc.data()
                    return ScheduleDogWalkerRequest(from: data)
                }

                // For each dog walker request, fetch dog walker details
                let innerGroup = DispatchGroup()
                for request in dogWalkerRequests {
                    innerGroup.enter()
                    let walkerId = request.dogWalkerId
                    Firestore.firestore().collection("dogwalkers")
                        .document(walkerId)
                        .getDocument { (walkerDoc, err) in
                            if let err = err {
                                print("Error fetching dog walker info: \(err.localizedDescription)")
                                innerGroup.leave()
                            } else if let walkerDoc = walkerDoc, walkerDoc.exists {
                                let walkerData = walkerDoc.data() ?? [:]
                                if let walker = try? JSONDecoder().decode(DogWalker.self, from: JSONSerialization.data(withJSONObject: walkerData)) {
                                    let phone = walker.phoneNumber ?? ""
                                    let name = walker.name
                                    let picURL = walker.profilePic ?? ""

                                    let model = UpcomingBookingModel(
                                        bookingId: request.requestId,
                                        bookingType: .dogWalker,
                                        caretakerOrWalkerId: walkerId,
                                        caretakerOrWalkerName: name,
                                        caretakerOrWalkerPhone: phone,
                                        caretakerOrWalkerImageURL: picURL,
                                        petName: request.petName
                                    )
                                    self.upcomingBookings.append(model)
                                }
                                innerGroup.leave()
                            } else {
                                innerGroup.leave()
                            }
                        }
                }

                innerGroup.notify(queue: .main) {
                    group.leave()
                }
            }

        // When both caretaker & dog walker fetches are done, reload the table
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension Home_Scene: UITableViewDataSource, UITableViewDelegate {

    /// If there are upcoming bookings, the first row is the "Upcoming Bookings" label,
    /// followed by one row per upcoming booking.
    /// If no upcoming bookings, return 0 rows.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingBookings.isEmpty ? 0 : (1 + upcomingBookings.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            // The "Upcoming Bookings" label cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenLabelCell", for: indexPath) as! HomeScreenLabelTableViewCell
            // This cell displays static text like "Upcoming Bookings"
            return cell
        } else {
            // One of the upcoming booking rows
            let booking = upcomingBookings[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingBookingsCell", for: indexPath) as! UpcomingBookingsTableViewCell

            // Configure the cell:
            cell.caretakerNameLabel.text = booking.caretakerOrWalkerName
            cell.petNameLabel.text = booking.petName

            // Load caretaker/walker image asynchronously
            if let url = URL(string: booking.caretakerOrWalkerImageURL), !booking.caretakerOrWalkerImageURL.isEmpty {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.caretakerImage.image = image
                        }
                    }
                }
            } else {
                cell.caretakerImage.image = UIImage(named: "placeholder")
            }

            // Set up call/message button actions
            cell.callButton.isUserInteractionEnabled = true
            cell.callButton.tag = indexPath.row - 1
            let callTap = UITapGestureRecognizer(target: self, action: #selector(callButtonTapped(_:)))
            cell.callButton.addGestureRecognizer(callTap)

            cell.messageButton.isUserInteractionEnabled = true
            cell.messageButton.tag = indexPath.row - 1
            let msgTap = UITapGestureRecognizer(target: self, action: #selector(messageButtonTapped(_:)))
            cell.messageButton.addGestureRecognizer(msgTap)

            return cell
        }
    }

    /// Provide the heights for each cell type.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // For upcoming bookings, row 0 (label cell) is 45 and each booking cell is 110
        return indexPath.row == 0 ? 45 : 110
    }
}

// MARK: - Call & Message
extension Home_Scene {

    @objc func callButtonTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view?.tag else { return }
        let booking = upcomingBookings[row]
        let phone = booking.caretakerOrWalkerPhone.replacingOccurrences(of: " ", with: "")

        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func messageButtonTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view?.tag else { return }
        let booking = upcomingBookings[row]

        switch booking.bookingType {
        case .caretaker:
            // Use iMessage (like Bookings_Information)
            openMessageCompose(withPhone: booking.caretakerOrWalkerPhone)
        case .dogWalker:
            // Use in-app chat (like DogWalker_Profile)
            openInAppChat(dogWalkerId: booking.caretakerOrWalkerId)
        }
    }

    private func openMessageCompose(withPhone phone: String) {
        if let url = URL(string: "sms:\(phone)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func openInAppChat(dogWalkerId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatsViewController") as? Chats {
            chatVC.userId = userId
            chatVC.caretakerId = dogWalkerId
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
