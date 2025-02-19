//
//  My Bookings.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class My_Bookings: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var bookingSegmentedControl: UISegmentedControl!
    
    // MARK: - Data Sources
    // Caretaker bookings (from "scheduleRequests")
    var caretakerUpcomingBookings: [ScheduleCaretakerRequest] = []
    var caretakerCompletedBookings: [ScheduleCaretakerRequest] = []
    var allCaretakerBookings: [ScheduleCaretakerRequest] {
         return caretakerUpcomingBookings + caretakerCompletedBookings
    }
    
    // Dog Walker bookings (from "dogWalkerRequests")
    var dogWalkerUpcomingBookings: [ScheduleDogWalkerRequest] = []
    var dogWalkerCompletedBookings: [ScheduleDogWalkerRequest] = []
    var allDogWalkerBookings: [ScheduleDogWalkerRequest] {
         return dogWalkerUpcomingBookings + dogWalkerCompletedBookings
    }
    
    var bookingsListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure segmented control with two segments.
        bookingSegmentedControl.removeAllSegments()
        bookingSegmentedControl.insertSegment(withTitle: "Caretaker", at: 0, animated: false)
        bookingSegmentedControl.insertSegment(withTitle: "Dog Walker", at: 1, animated: false)
        bookingSegmentedControl.selectedSegmentIndex = 0
        bookingSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        // Fetch the bookings for the logged-in owner.
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        let ownerId = currentUser.uid
        print("Fetching caretaker bookings for owner ID: \(ownerId)")
        
        // Observe caretaker bookings.
        bookingsListener = FirebaseManager.shared.observeOwnerBookings(for: ownerId) { [weak self] requests in
            guard let self = self else { return }
            self.caretakerUpcomingBookings = requests.filter { $0.status != "Completed" }
            self.caretakerCompletedBookings = requests.filter { $0.status == "Completed" }
            
            DispatchQueue.main.async {
                if self.bookingSegmentedControl.selectedSegmentIndex == 0 {
                    self.tableView.reloadData()
                }
            }
        }
        
        // Fetch dog walker bookings.
        let db = Firestore.firestore()
        db.collection("dogWalkerRequests")
          .whereField("userId", isEqualTo: ownerId)
          .getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching dog walker bookings: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            var dogWalkerRequests: [ScheduleDogWalkerRequest] = []
            for document in snapshot.documents {
                let data = document.data()
                if let request = ScheduleDogWalkerRequest(from: data) {
                    dogWalkerRequests.append(request)
                }
            }
            self.dogWalkerUpcomingBookings = dogWalkerRequests.filter { $0.status != "Completed" }
            self.dogWalkerCompletedBookings = dogWalkerRequests.filter { $0.status == "Completed" }
            DispatchQueue.main.async {
                if self.bookingSegmentedControl.selectedSegmentIndex == 1 {
                    self.tableView.reloadData()
                }
            }
          }
        
        // Set up a gradient background.
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
        
        // Set table view delegates.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Remove background colors.
        backgroundView.backgroundColor = .clear
        tableView.backgroundColor = .clear
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            return allCaretakerBookings.count
        } else {
            return allDogWalkerBookings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            // Use the caretaker cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingsTableViewCell
            let request = allCaretakerBookings[indexPath.row]
            cell.petNameLabel.text = request.petName
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            cell.startDateLabel.text = dateFormatter.string(from: request.startDate)
            cell.endDateLabel.text = dateFormatter.string(from: request.endDate)
            cell.configureCell(with: request)
            cell.statusButton.layer.cornerRadius = 8
            cell.statusButton.clipsToBounds = true
            
            cell.backgroundColor = .clear
            cell.bgView.layer.cornerRadius = 10
            cell.bgView.layer.shadowRadius = 5
            cell.bgView.layer.shadowOpacity = 0.1
            
            cell.statusButton.tag = indexPath.row
            cell.statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
            
            return cell
        } else {
            // Use the dog walker cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: "DogWalkerBookingCell", for: indexPath) as! DogWalkerBookingCell
            let request = allDogWalkerBookings[indexPath.row]
            cell.petNameLabel.text = request.petName
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            cell.dateLabel.text = dateFormatter.string(from: request.date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h a"
            let startTimeString = timeFormatter.string(from: request.startTime)
            let endTimeString = timeFormatter.string(from: request.endTime)
            cell.timeLabel.text = "\(startTimeString) to \(endTimeString)"
            cell.configureCell(with: request)
            cell.statusButton.setTitleColor(.white, for: .normal)
            cell.statusButton.layer.cornerRadius = 8
            cell.statusButton.clipsToBounds = true
            
            cell.backgroundColor = .clear
            cell.bgView.layer.cornerRadius = 10
            cell.bgView.layer.shadowRadius = 5
            cell.bgView.layer.shadowOpacity = 0.1
            cell.bgView.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.7).cgColor
            cell.bgView.layer.borderWidth = 1.5
            
            cell.statusButton.tag = indexPath.row
            cell.statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    // MARK: - Update Booking Status
    @objc func updateStatus(_ sender: UIButton) {
        let index = sender.tag
        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            // Update caretaker booking status.
            let request = allCaretakerBookings[index]
            let newStatus: String = {
                switch request.status {
                case "Pending": return "Accepted"
                case "Accepted": return "Ongoing"
                case "Ongoing": return "Completed"
                default: return request.status
                }
            }()
            FirebaseManager.shared.updateBookingStatus(requestId: request.requestId, newStatus: newStatus) { error in
                if error == nil {
                    self.reloadBookingData()
                }
            }
        } else {
            // Update dog walker booking status.
            let request = allDogWalkerBookings[index]
            let newStatus: String = {
                switch request.status {
                case "Pending": return "Accepted"
                case "Accepted": return "Ongoing"
                case "Ongoing": return "Completed"
                default: return request.status
                }
            }()
            Firestore.firestore().collection("dogWalkerRequests").document(request.requestId).updateData([
                "status": newStatus
            ]) { error in
                if error == nil {
                    self.reloadBookingData()
                }
            }
        }
    }
    
    // MARK: - Reload Data
    func reloadBookingData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let ownerId = currentUser.uid
        // Reload caretaker bookings.
        FirebaseManager.shared.fetchOwnerBookings(for: ownerId) { requests in
            self.caretakerUpcomingBookings = requests.filter { $0.status != "Completed" }
            self.caretakerCompletedBookings = requests.filter { $0.status == "Completed" }
            DispatchQueue.main.async {
                if self.bookingSegmentedControl.selectedSegmentIndex == 0 {
                    self.tableView.reloadData()
                }
            }
        }
        // Reload dog walker bookings.
        Firestore.firestore().collection("dogWalkerRequests")
            .whereField("userId", isEqualTo: ownerId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error reloading dog walker bookings: \(error.localizedDescription)")
                    return
                }
                guard let snapshot = snapshot else { return }
                var dogWalkerRequests: [ScheduleDogWalkerRequest] = []
                for document in snapshot.documents {
                    let data = document.data()
                    if let request = ScheduleDogWalkerRequest(from: data) {
                        dogWalkerRequests.append(request)
                    }
                }
                self.dogWalkerUpcomingBookings = dogWalkerRequests.filter { $0.status != "Completed" }
                self.dogWalkerCompletedBookings = dogWalkerRequests.filter { $0.status == "Completed" }
                DispatchQueue.main.async {
                    if self.bookingSegmentedControl.selectedSegmentIndex == 1 {
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            let request = allCaretakerBookings[indexPath.row]
            if let detailsVC = storyboard.instantiateViewController(withIdentifier: "BookingDetailsVC") as? Bookings_Information {
                detailsVC.scheduleRequest = request
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        } else {
            let request = allDogWalkerBookings[indexPath.row]
            if let detailsVC = storyboard.instantiateViewController(withIdentifier: "DogWalkerBookingDetailsVC") as? DogWalker_Profile {
                detailsVC.scheduleDogWalkerRequest = request
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    }
}
