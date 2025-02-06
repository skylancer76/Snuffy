//
//  My Bookings.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.
//

import UIKit
import FirebaseAuth

class My_Bookings: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var bookingSegmentedControl: UISegmentedControl!
    
    var upcomingBookings: [ScheduleRequest] = []
    var completedBookings: [ScheduleRequest] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Segemented Control Configuration
        bookingSegmentedControl.selectedSegmentIndex = 0
        bookingSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
               
        // Fetch Bookings for the logged-in owner
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        
        
        let ownerId = currentUser.uid
        print("Fetching bookings for owner ID: \(ownerId)")
        
        FirebaseManager.shared.fetchOwnerBookings(for: ownerId) { requests in
            self.upcomingBookings = requests.filter { $0.status != "Completed" }
            self.completedBookings = requests.filter { $0.status == "Completed" }
            self.tableView.reloadData()
        }
        
        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds                           // Match the frame of the view
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,     // Start color
            UIColor.clear.cgColor                                   // End color
        ]
        gradientLayer.locations = [0.0, 1.0]                        // Gradually fade
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)          // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)            // Bottom-center
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Table View Delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        // Remove Background Colour
        backgroundView.backgroundColor = .clear
        tableView.backgroundColor = .clear
        
    }
    
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
            tableView.reloadData()
        }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingSegmentedControl.selectedSegmentIndex == 0 ? upcomingBookings.count : completedBookings.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingsTableViewCell
        
        let request = bookingSegmentedControl.selectedSegmentIndex == 0 ? upcomingBookings[indexPath.row] : completedBookings[indexPath.row]
        
        cell.petNameLabel.text = request.petName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        cell.startDateLabel.text = "Start: \(dateFormatter.string(from: request.startDate))"
        cell.endDateLabel.text = "End: \(dateFormatter.string(from: request.endDate))"
        
        // Set the title of the status button
        cell.statusButton.setTitle(request.status, for: .normal)
        
        // Set background color based on the booking status.
        switch request.status {
        case "Pending":
            cell.statusButton.backgroundColor = .orange
        case "Accepted":
            cell.statusButton.backgroundColor = .systemGreen  // Change as desired.
        case "Ongoing":
            cell.statusButton.backgroundColor = .blue
        case "Completed":
            cell.statusButton.backgroundColor = .systemPurple
        default:
            cell.statusButton.backgroundColor = .gray
        }
        
        // Ensure the button is styled properly.
        cell.statusButton.setTitleColor(.white, for: .normal)
        cell.statusButton.layer.cornerRadius = 8
        cell.statusButton.clipsToBounds = true
        
        cell.backgroundColor = .clear
        cell.bgView.layer.cornerRadius = 10
        cell.bgView.layer.masksToBounds = true
        cell.bgView.layer.shadowRadius = 5
        cell.bgView.layer.shadowOpacity = 0.2
        
        cell.statusButton.tag = indexPath.row
        cell.statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    @objc func updateStatus(_ sender: UIButton) {
        let index = sender.tag
        var request = bookingSegmentedControl.selectedSegmentIndex == 0 ? upcomingBookings[index] : completedBookings[index]

        let newStatus: String = {
            switch request.status {
            case "Pending":
                return "Accepted"
            case "Accepted":
                return "Ongoing"
            case "Ongoing":
                return "Completed"
            default:
                return request.status
            }
        }()
        
        FirebaseManager.shared.updateBookingStatus(requestId: request.requestId, newStatus: newStatus) { error in
            if error == nil {
                request.status = newStatus
                self.reloadBookingData()
            }
        }
    }
    
    
    func reloadBookingData() {
        guard let currentUser = Auth.auth().currentUser else { return }
            
        let ownerId = currentUser.uid
        FirebaseManager.shared.fetchOwnerBookings(for: ownerId) { requests in
            self.upcomingBookings = requests.filter { $0.status != "Completed" }
            self.completedBookings = requests.filter { $0.status == "Completed" }
            self.tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = bookingSegmentedControl.selectedSegmentIndex == 0 ? upcomingBookings[indexPath.row] : completedBookings[indexPath.row]
            
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "BookingDetailsVC") as? Bookings_Info {
            detailsVC.scheduleRequest = request
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
