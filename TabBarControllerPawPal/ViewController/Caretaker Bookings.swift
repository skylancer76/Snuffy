//
//  Caretaker Bookings.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 10/03/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class Caretaker_Bookings: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bookingsSegmentedControl: UISegmentedControl!
    
    // Whether the current user is caretaker or dog walker
    var isCaretaker: Bool = false
    
    // MARK: - Arrays for caretaker requests
    var caretakerUpcomingBookings: [ScheduleCaretakerRequest] = []
    var caretakerCompletedBookings: [ScheduleCaretakerRequest] = []
    
    // MARK: - Arrays for dog walker requests
    var dogWalkerUpcomingBookings: [ScheduleDogWalkerRequest] = []
    var dogWalkerCompletedBookings: [ScheduleDogWalkerRequest] = []
    
    // Snapshot listeners so we can remove them in deinit
    private var caretakerListener: ListenerRegistration?
    private var dogWalkerListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientBackground()
        setupSegmentedControl()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        bgView.backgroundColor    = .clear
        
        // First, determine if this user is caretaker or dog walker.
        checkUserRoleAndObserveBookings()
    }
    
    deinit {
        caretakerListener?.remove()
        dogWalkerListener?.remove()
    }
    
    // MARK: - Determine if user is caretaker or dog walker
    func checkUserRoleAndObserveBookings() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in.")
            return
        }
        
        let userId = currentUser.uid
        let db = Firestore.firestore()
        
        // Check "caretakers" collection
        db.collection("caretakers").whereField("caretakerId", isEqualTo: userId).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error checking caretaker role: \(error.localizedDescription)")
                return
            }
            
            if let snap = snapshot, !snap.documents.isEmpty {
                // Found caretaker doc -> user is caretaker
                self.isCaretaker = true
                self.observeCaretakerRequests(userId: userId)
            } else {
                // If not caretaker, check "dogwalkers" collection
                db.collection("dogwalkers").whereField("dogWalkerId", isEqualTo: userId).getDocuments { [weak self] (dogSnap, error) in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error checking dog walker role: \(error.localizedDescription)")
                        return
                    }
                    
                    if let dogSnap = dogSnap, !dogSnap.documents.isEmpty {
                        // Found dog walker doc -> user is dog walker
                        self.isCaretaker = false
                        self.observeDogWalkerRequests(userId: userId)
                    } else {
                        print("User is neither caretaker nor dog walker.")
                    }
                }
            }
        }
    }
    
    // MARK: - Firestore Observers
    
    /// Observe caretaker requests in "scheduleRequests"
    func observeCaretakerRequests(userId: String) {
        // For caretaker, the caretakerId in scheduleRequests equals the userId.
        // We listen for any changes and separate them into "Upcoming" vs. "Completed"
        caretakerListener = Firestore.firestore().collection("scheduleRequests")
            .whereField("caretakerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching caretaker requests: \(error.localizedDescription)")
                    return
                }
                
                var upcoming: [ScheduleCaretakerRequest] = []
                var completed: [ScheduleCaretakerRequest] = []
                
                // Use a dispatch group to wait for all pet detail queries.
                let group = DispatchGroup()
                
                for doc in snapshot?.documents ?? [] {
                    var data = doc.data()
                    data["requestId"] = doc.documentID
                    
                    // Use petName from the request to fetch additional pet details.
                    guard let petName = data["petName"] as? String else {
                        continue
                    }
                    
                    group.enter()
                    Firestore.firestore().collection("Pets")
                        .whereField("petName", isEqualTo: petName)
                        .getDocuments { petSnapshot, error in
                            if let error = error {
                                print("Error fetching pet details for \(petName): \(error.localizedDescription)")
                                group.leave()
                                return
                            }
                            
                            if let petDoc = petSnapshot?.documents.first {
                                let petData = petDoc.data()
                                data["petBreed"] = petData["petBreed"] as? String ?? "Unknown"
                                data["petImageUrl"] = petData["petImage"] as? String ?? ""
                            } else {
                                print("No pet found for name: \(petName)")
                                data["petBreed"] = "Unknown"
                                data["petImageUrl"] = ""
                            }
                            
                            if let request = ScheduleCaretakerRequest(from: data) {
                                if request.status.lowercased() == "completed" {
                                    completed.append(request)
                                } else {
                                    upcoming.append(request)
                                }
                            }
                            group.leave()
                        }
                }
                
                group.notify(queue: .main) {
                    self.caretakerUpcomingBookings = upcoming
                    self.caretakerCompletedBookings = completed
                    self.tableView.reloadData()
                }
            }
    }
    
    /// Observe dog walker requests in "dogWalkerRequests"
    func observeDogWalkerRequests(userId: String) {
        // For dog walker, the dogWalkerId in dogWalkerRequests equals the userId.
        dogWalkerListener = Firestore.firestore().collection("dogWalkerRequests")
            .whereField("dogWalkerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching dog walker requests: \(error.localizedDescription)")
                    return
                }
                
                var upcoming: [ScheduleDogWalkerRequest] = []
                var completed: [ScheduleDogWalkerRequest] = []
                
                for doc in snapshot?.documents ?? [] {
                    var data = doc.data()
                    data["requestId"] = doc.documentID
                    if let request = ScheduleDogWalkerRequest(from: data) {
                        if request.status.lowercased() == "completed" {
                            completed.append(request)
                        } else {
                            upcoming.append(request)
                        }
                    }
                }
                
                self.dogWalkerUpcomingBookings = upcoming
                self.dogWalkerCompletedBookings = completed
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - UI Setup
    func setupSegmentedControl() {
        // Two segments: "Upcoming" and "Completed"
        bookingsSegmentedControl.removeAllSegments()
        bookingsSegmentedControl.insertSegment(withTitle: "Upcoming", at: 0, animated: false)
        bookingsSegmentedControl.insertSegment(withTitle: "Completed", at: 1, animated: false)
        bookingsSegmentedControl.selectedSegmentIndex = 0
        bookingsSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
    }
    
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    func setupGradientBackground() {
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 0.5)
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - TableView DataSource & Delegate
extension Caretaker_Bookings: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If user is caretaker, show caretaker bookings; else, show dog walker bookings.
        if isCaretaker {
            if bookingsSegmentedControl.selectedSegmentIndex == 0 {
                return caretakerUpcomingBookings.count
            } else {
                return caretakerCompletedBookings.count
            }
        } else {
            if bookingsSegmentedControl.selectedSegmentIndex == 0 {
                return dogWalkerUpcomingBookings.count
            } else {
                return dogWalkerCompletedBookings.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if isCaretaker {
            // Dequeue caretaker cell.
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CaretakerBookingsTableViewCell",
                for: indexPath
            ) as? CaretakerBookingsTableViewCell else {
                return UITableViewCell()
            }
            
            // Select the request from upcoming or completed arrays.
            let request = (bookingsSegmentedControl.selectedSegmentIndex == 0)
                          ? caretakerUpcomingBookings[indexPath.row]
                          : caretakerCompletedBookings[indexPath.row]
            
            cell.petNameLabel.text      = request.petName
            cell.petBreedLabel.text     = request.petBreed ?? "Unknown"
            cell.petOwnerLabel.text     = request.userName
            cell.petDurationLabel.text  = request.duration
            
            cell.bgView.layer.cornerRadius = 10
            cell.bgView.layer.masksToBounds = false
            cell.bgView.layer.shadowRadius = 3
            cell.bgView.layer.shadowOpacity = 0.1
            
            // Load pet image asynchronously.
            if let urlString = request.petImageUrl,
               let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.petImage.image = image
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.petImage.image = UIImage(named: "placeholder")
                        }
                    }
                }
            } else {
                cell.petImage.image = UIImage(named: "placeholder")
            }
            
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            return cell
            
        } else {
            // Dequeue dog walker cell.
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DogwalkerBookingsTableViewCell",
                for: indexPath
            ) as? DogwalkerBookingsTableViewCell else {
                return UITableViewCell()
            }
            
            let request = (bookingsSegmentedControl.selectedSegmentIndex == 0)
                          ? dogWalkerUpcomingBookings[indexPath.row]
                          : dogWalkerCompletedBookings[indexPath.row]
            
            cell.petNameLabel.text      = request.petName
            cell.petBreedLabel.text     = request.petBreed ?? "Unknown"
            cell.petOwnerLabel.text     = request.userName
            cell.petDurationLabel.text  = request.duration
            
            cell.bgView.layer.cornerRadius = 10
            cell.bgView.layer.masksToBounds = false
            cell.bgView.layer.shadowRadius = 3
            cell.bgView.layer.shadowOpacity = 0.1
            
            if let urlString = request.petImageUrl,
               let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.petImage.image = image
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.petImage.image = UIImage(named: "placeholder")
                        }
                    }
                }
            } else {
                cell.petImage.image = UIImage(named: "placeholder")
            }
            
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            return cell
        }
    }
    
    // Fixed row height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCaretaker {
            let request = (bookingsSegmentedControl.selectedSegmentIndex == 0)
                          ? caretakerUpcomingBookings[indexPath.row]
                          : caretakerCompletedBookings[indexPath.row]
            
            if let infoVC = storyboard?.instantiateViewController(withIdentifier: "CaretakerBookingInfoVC") as? Caretaker_Bookings_Information {
                infoVC.caretakerRequest = request
                navigationController?.pushViewController(infoVC, animated: true)
            }
        } else {
            let request = (bookingsSegmentedControl.selectedSegmentIndex == 0)
                          ? dogWalkerUpcomingBookings[indexPath.row]
                          : dogWalkerCompletedBookings[indexPath.row]
            
            if let infoVC = storyboard?.instantiateViewController(withIdentifier: "DogWalkerBookingInfoVC") as? Caretaker_Bookings_Information {
                infoVC.dogWalkerRequest = request
                navigationController?.pushViewController(infoVC, animated: true)
            }
        }
    }
}

