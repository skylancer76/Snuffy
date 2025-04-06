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
    var caretakerUpcomingBookings: [ScheduleCaretakerRequest] = []
    var caretakerCompletedBookings: [ScheduleCaretakerRequest] = []
    var allCaretakerBookings: [ScheduleCaretakerRequest] {
        return caretakerUpcomingBookings + caretakerCompletedBookings
    }
    
    var dogWalkerUpcomingBookings: [ScheduleDogWalkerRequest] = []
    var dogWalkerCompletedBookings: [ScheduleDogWalkerRequest] = []
    var allDogWalkerBookings: [ScheduleDogWalkerRequest] {
        return dogWalkerUpcomingBookings + dogWalkerCompletedBookings
    }
    
    // MARK: - Firestore Listeners
    var bookingsListener: ListenerRegistration?
    var dogWalkerListener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookingSegmentedControl.removeAllSegments()
        bookingSegmentedControl.insertSegment(withTitle: "Caretaker", at: 0, animated: false)
        bookingSegmentedControl.insertSegment(withTitle: "Dog Walker", at: 1, animated: false)
        bookingSegmentedControl.selectedSegmentIndex = 0
        bookingSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListeners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bookingsListener?.remove()
        dogWalkerListener?.remove()
    }
    
    func setupUI() {
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

        backgroundView.backgroundColor = .clear
        tableView.backgroundColor = .clear
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }

    // MARK: - Setup Listeners
    func setupListeners() {
        bookingsListener?.remove()
        dogWalkerListener?.remove()
        
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        
        let ownerId = currentUser.uid
        print("Listening for bookings for ownerId: \(ownerId)")
        
        // Caretaker listener
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
        
        // Dog Walker listener
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

    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingSegmentedControl.selectedSegmentIndex == 0
            ? allCaretakerBookings.count
            : allDogWalkerBookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingsTableViewCell
            let request = allCaretakerBookings[indexPath.row]

            cell.petNameLabel.text = request.petName

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none

            cell.startDateLabel.text = dateFormatter.string(from: request.startDate!)
            cell.endDateLabel.text = dateFormatter.string(from: request.endDate!)
            cell.configureCell(with: request)

            cell.statusButton.layer.cornerRadius = 6
            cell.statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 9)
            let status = request.status.capitalized
            cell.statusButton.setTitle(status, for: .normal)

            cell.backgroundColor = .clear
            cell.bgView.layer.cornerRadius = 10
            cell.contentView.layer.shadowRadius = 3
            cell.contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.contentView.layer.shadowOpacity = 0.2
            cell.contentView.layer.masksToBounds = false
            cell.statusButton.tag = indexPath.row
            cell.statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DogWalkerBookingCell", for: indexPath) as! DogWalkerBookingCell
            let request = allDogWalkerBookings[indexPath.row]

            cell.petNameLabel.text = request.petName

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            cell.dateLabel.text = dateFormatter.string(from: request.date)

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h a"
            let startTimeString = timeFormatter.string(from: request.startTime)
            let endTimeString = timeFormatter.string(from: request.endTime)
            cell.timeLabel.text = "\(startTimeString) to \(endTimeString)"

            cell.configureCell(with: request)

            cell.statusButton.layer.cornerRadius = 6
            cell.statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 9)
            cell.statusButton.setTitle(request.status.capitalized, for: .normal)

            cell.backgroundColor = .clear
            cell.bgView.layer.cornerRadius = 10
            cell.contentView.layer.shadowRadius = 3
            cell.contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.contentView.layer.shadowOpacity = 0.2
            cell.contentView.layer.masksToBounds = false
            cell.statusButton.tag = indexPath.row
            cell.statusButton.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)

            return cell
        }
    }

    // MARK: - Status Update
    @objc func updateStatus(_ sender: UIButton) {
        let index = sender.tag

        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            let request = allCaretakerBookings[index]
            let newStatus = nextStatus(from: request.status)

            FirebaseManager.shared.updateBookingStatus(requestId: request.requestId, newStatus: newStatus) { error in
                if error == nil {
                    self.reloadBookingData()
                }
            }
        } else {
            let request = allDogWalkerBookings[index]
            let newStatus = nextStatus(from: request.status)

            Firestore.firestore().collection("dogWalkerRequests").document(request.requestId).updateData([
                "status": newStatus
            ]) { error in
                if error == nil {
                    self.reloadBookingData()
                }
            }
        }
    }

    func nextStatus(from current: String) -> String {
        switch current {
        case "Pending": return "Accepted"
        case "Accepted": return "Ongoing"
        case "Ongoing": return "Completed"
        default: return current
        }
    }

    // MARK: - Reload Bookings
    func reloadBookingData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let ownerId = currentUser.uid

        FirebaseManager.shared.fetchOwnerBookings(for: ownerId) { requests in
            self.caretakerUpcomingBookings = requests.filter { $0.status != "Completed" }
            self.caretakerCompletedBookings = requests.filter { $0.status == "Completed" }
            DispatchQueue.main.async {
                if self.bookingSegmentedControl.selectedSegmentIndex == 0 {
                    self.tableView.reloadData()
                }
            }
        }

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
        if bookingSegmentedControl.selectedSegmentIndex == 0 {
            let request = allCaretakerBookings[indexPath.row]
            if request.status.lowercased() == "pending" {
                showPendingAlert(role: "caretaker")
                return
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailsVC = storyboard.instantiateViewController(withIdentifier: "BookingDetailsVC") as? Bookings_Information {
                detailsVC.scheduleRequest = request
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        } else {
            let request = allDogWalkerBookings[indexPath.row]
            if request.status.lowercased() == "pending" {
                showPendingAlert(role: "dog walker")
                return
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailsVC = storyboard.instantiateViewController(withIdentifier: "DogWalkerBookingDetailsVC") as? DogWalker_Profile {
                detailsVC.scheduleDogWalkerRequest = request
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    }

    func showPendingAlert(role: String) {
        let alert = UIAlertController(
            title: "Request Pending",
            message: "Your booking request is still pending. Please wait until the \(role) accepts your request.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
