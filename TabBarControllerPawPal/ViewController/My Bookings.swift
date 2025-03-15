//
//  My Bookings.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.


import UIKit
import FirebaseAuth
import FirebaseFirestore

class My_Bookings: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var bookingSegmentedControl: UISegmentedControl!
    
    // MARK: - Data Sources
    // These arrays track caretaker bookings (from "scheduleRequests")
    var caretakerUpcomingBookings: [ScheduleCaretakerRequest] = []
    var caretakerCompletedBookings: [ScheduleCaretakerRequest] = []
    // Combined caretaker bookings for easy indexing
    var allCaretakerBookings: [ScheduleCaretakerRequest] {
        return caretakerUpcomingBookings + caretakerCompletedBookings
    }
    
    // These arrays track dog walker bookings (from "dogWalkerRequests")
    var dogWalkerUpcomingBookings: [ScheduleDogWalkerRequest] = []
    var dogWalkerCompletedBookings: [ScheduleDogWalkerRequest] = []
    // Combined dog walker bookings for easy indexing
    var allDogWalkerBookings: [ScheduleDogWalkerRequest] {
        return dogWalkerUpcomingBookings + dogWalkerCompletedBookings
    }
    
    // Listener registrations to observe real-time updates from Firestore
    var bookingsListener: ListenerRegistration?
    var dogWalkerListener: ListenerRegistration?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the segmented control with two segments: Caretaker & Dog Walker
        bookingSegmentedControl.removeAllSegments()
        bookingSegmentedControl.insertSegment(withTitle: "Caretaker", at: 0, animated: false)
        bookingSegmentedControl.insertSegment(withTitle: "Dog Walker", at: 1, animated: false)
        bookingSegmentedControl.selectedSegmentIndex = 0
        bookingSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        // Ensure the user is logged in
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        let ownerId = currentUser.uid
        print("Fetching caretaker bookings for owner ID: \(ownerId)")
        
        // Observe caretaker bookings (real-time) via a custom FirebaseManager method
        bookingsListener = FirebaseManager.shared.observeOwnerBookings(for: ownerId) { [weak self] requests in
            guard let self = self else { return }
            
            // Separate upcoming vs completed caretaker bookings
            self.caretakerUpcomingBookings = requests.filter { $0.status != "Completed" }
            self.caretakerCompletedBookings = requests.filter { $0.status == "Completed" }
            
            DispatchQueue.main.async {
                // Only reload the table if the "Caretaker" segment is selected
                if self.bookingSegmentedControl.selectedSegmentIndex == 0 {
                    self.tableView.reloadData()
                }
            }
        }
        
        // Observe dog walker bookings (real-time) directly from Firestore
        dogWalkerListener = Firestore.firestore().collection("dogWalkerRequests")
            .whereField("userId", isEqualTo: ownerId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching dog walker bookings: \(error.localizedDescription)")
                    return
                }
                guard let snapshot = snapshot else { return }
                
                var dogWalkerRequests: [ScheduleDogWalkerRequest] = []
                for document in snapshot.documents {
                    let data = document.data()
                    // Convert Firestore data to a ScheduleDogWalkerRequest object
                    if let request = ScheduleDogWalkerRequest(from: data) {
                        dogWalkerRequests.append(request)
                    }
                }
                // Separate upcoming vs completed dog walker bookings
                self.dogWalkerUpcomingBookings = dogWalkerRequests.filter { $0.status != "Completed" }
                self.dogWalkerCompletedBookings = dogWalkerRequests.filter { $0.status == "Completed" }
                
                DispatchQueue.main.async {
                    // Only reload the table if the "Dog Walker" segment is selected
                    if self.bookingSegmentedControl.selectedSegmentIndex == 1 {
                        self.tableView.reloadData()
                    }
                }
            }
        
        // Set up a gradient background for styling
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
        
        // TableView delegates & data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Clear background colors
        backgroundView.backgroundColor = .clear
        tableView.backgroundColor = .clear
    }
    
    // Called when the user switches between "Caretaker" and "Dog Walker"
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // MARK: - TableView Data Source
    // Return the number of rows based on the selected segment
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            // Caretaker
            return allCaretakerBookings.count
        } else {
            // Dog Walker
            return allDogWalkerBookings.count
        }
    }
    
    // Configure each cell for caretaker or dog walker data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            // Caretaker Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingsTableViewCell
            let request = allCaretakerBookings[indexPath.row]
            
            // Pet Name
            cell.petNameLabel.text = request.petName
            
            // Date Formatter for start/end dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            // Display the start and end dates
            cell.startDateLabel.text = dateFormatter.string(from: request.startDate!)
            cell.endDateLabel.text = dateFormatter.string(from: request.endDate!)
            
            // Configure the rest of the caretaker cell (e.g., images, additional labels)
            cell.configureCell(with: request)
            
            // Style the status button
            cell.statusButton.layer.cornerRadius = 6
            cell.statusButton.clipsToBounds = true
            // Set the button font to size 9
            cell.statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 9)
            
            // Format the status text (e.g., "Accepted")
            let lower = request.status.lowercased()
            let formattedStatus = lower.prefix(1).uppercased() + lower.dropFirst()
            cell.statusButton.setTitle(formattedStatus, for: .normal)
            
            // Set cell background to clear for the gradient
            cell.backgroundColor = .clear
            // Round the corners of the background view inside the cell
            cell.bgView.layer.cornerRadius = 10
            
            // Attach a tag for updating the status
            cell.statusButton.tag = indexPath.row
            cell.statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
            
            return cell
            
        } else {
            // Dog Walker Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "DogWalkerBookingCell", for: indexPath) as! DogWalkerBookingCell
            let request = allDogWalkerBookings[indexPath.row]
            
            // Pet Name
            cell.petNameLabel.text = request.petName
            
            // Format the date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            cell.dateLabel.text = dateFormatter.string(from: request.date)
            
            // Format the time
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h a"
            let startTimeString = timeFormatter.string(from: request.startTime)
            let endTimeString = timeFormatter.string(from: request.endTime)
            cell.timeLabel.text = "\(startTimeString) to \(endTimeString)"
            
            // Configure the rest of the dog walker cell
            cell.configureCell(with: request)
            
            // Style the status button
            cell.statusButton.layer.cornerRadius = 6
            cell.statusButton.clipsToBounds = true
            // Set the button font to size 9
            cell.statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 9)
            
            // Format the status text (e.g., "Accepted")
            let lower = request.status.lowercased()
            let formattedStatus = lower.prefix(1).uppercased() + lower.dropFirst()
            cell.statusButton.setTitle(formattedStatus, for: .normal)
            
            // Clear background for the gradient
            cell.backgroundColor = .clear
            cell.bgView.layer.cornerRadius = 10
            
            // Attach a tag for updating the status
            cell.statusButton.tag = indexPath.row
            cell.statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    // MARK: - Update Booking Status
    // Called when the status button is tapped
    @objc func updateStatus(_ sender: UIButton) {
        let index = sender.tag
        
        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            // Caretaker booking
            let request = allCaretakerBookings[index]
            
            // Determine the next status in the sequence
            let newStatus: String = {
                switch request.status {
                case "Pending":  return "Accepted"
                case "Accepted": return "Ongoing"
                case "Ongoing":  return "Completed"
                default:         return request.status
                }
            }()
            
            // Update caretaker booking status in Firestore
            FirebaseManager.shared.updateBookingStatus(requestId: request.requestId, newStatus: newStatus) { error in
                if error == nil {
                    self.reloadBookingData()
                }
            }
            
        } else {
            // Dog Walker booking
            let request = allDogWalkerBookings[index]
            
            // Determine the next status in the sequence
            let newStatus: String = {
                switch request.status {
                case "Pending":  return "Accepted"
                case "Accepted": return "Ongoing"
                case "Ongoing":  return "Completed"
                default:         return request.status
                }
            }()
            
            // Update dog walker booking status in Firestore
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
    // Refreshes caretaker & dog walker bookings from Firestore
    func reloadBookingData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let ownerId = currentUser.uid
        
        // Reload caretaker bookings
        FirebaseManager.shared.fetchOwnerBookings(for: ownerId) { requests in
            self.caretakerUpcomingBookings = requests.filter { $0.status != "Completed" }
            self.caretakerCompletedBookings = requests.filter { $0.status == "Completed" }
            DispatchQueue.main.async {
                // Only reload if caretaker segment is active
                if self.bookingSegmentedControl.selectedSegmentIndex == 0 {
                    self.tableView.reloadData()
                }
            }
        }
        
        // Reload dog walker bookings
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
                    // Only reload if dog walker segment is active
                    if self.bookingSegmentedControl.selectedSegmentIndex == 1 {
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    // MARK: - TableView Delegate
    // Set a fixed height for each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    // Called when a row is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If booking is still pending, do not navigate
        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            // Caretaker
            let request = allCaretakerBookings[indexPath.row]
            if request.status.lowercased() == "pending" {
                return
            }
            // Navigate to caretaker booking details
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailsVC = storyboard.instantiateViewController(withIdentifier: "BookingDetailsVC") as? Bookings_Information {
                detailsVC.scheduleRequest = request
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        } else {
            // Dog Walker
            let request = allDogWalkerBookings[indexPath.row]
            if request.status.lowercased() == "pending" {
                return
            }
            // Navigate to dog walker booking details
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailsVC = storyboard.instantiateViewController(withIdentifier: "DogWalkerBookingDetailsVC") as? DogWalker_Profile {
                detailsVC.scheduleDogWalkerRequest = request
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    }
}
