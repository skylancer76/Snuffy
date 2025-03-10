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
    @IBOutlet weak var bookingsSegmentedController: UISegmentedControl!
    
    // Store all accepted requests here
    var acceptedRequests: [ScheduleCaretakerRequest] = []
    
    // Keep a reference to the snapshot listener, so we can remove it when the view is deinitialized
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1) Setup UI (gradient background, etc.)
        setupGradientBackground()
        
        // 2) Set delegates/datasource
        tableView.delegate = self
        tableView.dataSource = self
        
        // 3) Observe the accepted bookings in Firestore
        observeAcceptedRequests()
    }
    
    deinit {
        // Stop listening when this view controller is deallocated
        listener?.remove()
    }
    
    func setupGradientBackground() {
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
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 0.5)
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        tableView.backgroundColor = .clear
        bgView.backgroundColor    = .clear
    }
    
    func observeAcceptedRequests() {
        guard let caretakerId = Auth.auth().currentUser?.uid else {
            print("No caretaker logged in")
            return
        }
        
        let db = Firestore.firestore()
        
        // Listen for any changes to "scheduleRequests" that match caretakerId and status == "accepted"
        listener = db.collection("scheduleRequests")
            .whereField("caretakerId", isEqualTo: caretakerId)
            .whereField("status", isEqualTo: "accepted")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error observing accepted requests: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var tempRequests: [ScheduleCaretakerRequest] = []
                for doc in documents {
                    var data = doc.data()
                    data["requestId"] = doc.documentID
                    
                    // Convert Firestore data to our ScheduleCaretakerRequest model
                    if let request = ScheduleCaretakerRequest(from: data) {
                        tempRequests.append(request)
                    }
                }
                
                // Update our array & reload table
                self.acceptedRequests = tempRequests
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension Caretaker_Bookings: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acceptedRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // "CaretakerBookingsTableViewCell" is the reuse identifier in your storyboard
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CaretakerBookingsTableViewCell", for: indexPath) as? CaretakerBookingsTableViewCell else {
            return UITableViewCell()
        }
        
        let request = acceptedRequests[indexPath.row]
        
        // Fill out the cell labels/images
        cell.petNameLabel.text      = request.petName
        cell.petBreedLabel.text     = request.petBreed
        cell.petOwnerLabel.text     = request.userName
        cell.petDurationLabel.text  = request.duration
        
        // Load the pet image from URL (if available)
        if let imageUrlString = request.petImageUrl,
           let url = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
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
        
        return cell
    }
    
    // Optional: if you want a specific row height or automatic dimension
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
