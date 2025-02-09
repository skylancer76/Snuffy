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
    
    var upcomingBookings: [ScheduleCaretakerRequest] = []
    var completedBookings: [ScheduleCaretakerRequest] = []
    var bookingsListener: ListenerRegistration?
    var selectedBooking: ScheduleCaretakerRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Segmented Control
        bookingSegmentedControl.selectedSegmentIndex = 0
        bookingSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        // Fetch Bookings for the logged-in owner.
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        
        let ownerId = currentUser.uid
        print("Fetching bookings for owner ID: \(ownerId)")
        
        // Observe changes with snapshot listener.
        bookingsListener = FirebaseManager.shared.observeOwnerBookings(for: ownerId) { [weak self] requests in
            guard let self = self else { return }
            self.upcomingBookings = requests.filter { $0.status != "Completed" }
            self.completedBookings = requests.filter { $0.status == "Completed" }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        // Set Gradient View
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingSegmentedControl.selectedSegmentIndex == 0 ? upcomingBookings.count : completedBookings.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingsTableViewCell
        
        let request = bookingSegmentedControl.selectedSegmentIndex == 0 ? upcomingBookings[indexPath.row] : completedBookings[indexPath.row]
        
        // Configure basic cell properties.
        cell.petNameLabel.text = request.petName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        cell.startDateLabel.text = dateFormatter.string(from: request.startDate)
        cell.endDateLabel.text = dateFormatter.string(from: request.endDate)
        
        // Set the status button title.
        cell.statusButton.setTitle(request.status, for: .normal)
        
        // Update the button’s tintColor based on status.
        switch request.status {
        case "Pending":
            cell.statusButton.tintColor = .systemBlue
        case "Accepted":
            cell.statusButton.tintColor = .systemGreen
        case "Ongoing":
            cell.statusButton.tintColor = .systemOrange
        case "Completed":
            cell.statusButton.tintColor = .systemGreen
        default:
            cell.statusButton.tintColor = .gray
        }
        
        // Additional button styling.
        cell.statusButton.setTitleColor(.white, for: .normal)
        cell.statusButton.layer.cornerRadius = 8
        cell.statusButton.clipsToBounds = true
        
        // Configure the cell’s background view.
        cell.backgroundColor = .clear
        cell.bgView.layer.cornerRadius = 10
        cell.bgView.layer.shadowRadius = 5
        cell.bgView.layer.shadowOpacity = 0.1
        cell.bgView.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.7).cgColor
        cell.bgView.layer.borderWidth = 1.5
        
        // Set the button tag and add target for status updates.
        cell.statusButton.tag = indexPath.row
        cell.statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
        

        
        return cell
    }
    
    @objc func updateStatus(_ sender: UIButton) {
        let index = sender.tag
        let request = bookingSegmentedControl.selectedSegmentIndex == 0 ? upcomingBookings[index] : completedBookings[index]
        
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
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "BookingDetailsVC") as? Bookings_Information {
                detailsVC.scheduleRequest = request
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
}
