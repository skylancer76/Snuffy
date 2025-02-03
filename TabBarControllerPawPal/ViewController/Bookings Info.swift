//
//  Bookings Info.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.
//

import UIKit
import FirebaseFirestore

class Bookings_Info: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var caretakerImageView: UIImageView!
    @IBOutlet weak var caretakerNameLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var bgView: UIView!
    // MARK: - Properties
    var scheduleRequest: ScheduleRequest?
    var caretaker: Caretakers?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        bgView.layer.cornerRadius = 10
        caretakerImageView.layer.cornerRadius = 8
      
        tableView.register(BookingDetailCell.self, forCellReuseIdentifier: "BookingDetailCell_Pet")
        tableView.register(BookingDetailCell.self, forCellReuseIdentifier: "BookingDetailCell_StartDate")
        tableView.register(BookingDetailCell.self, forCellReuseIdentifier: "BookingDetailCell_EndDate")
        tableView.register(BookingDetailCell.self, forCellReuseIdentifier: "BookingDetailCell_Pickup")
        tableView.register(BookingDetailCell.self, forCellReuseIdentifier: "BookingDetailCell_Payment")
        
        // If we have a schedule request, fetch the caretaker details.
        if let request = scheduleRequest {
            print("Fetching caretaker ID for booking ID: \(request.requestId)")
            fetchCaretakerIdFromBooking(bookingId: request.requestId)
        }
    }
    
    // MARK: - Firestore Fetch Methods
    func fetchCaretakerIdFromBooking(bookingId: String) {
        let db = Firestore.firestore()
        
        db.collection("scheduleRequests").document(bookingId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching booking details: \(error.localizedDescription)")
                return
            }
            
            if let data = document?.data(), let caretakerId = data["caretakerId"] as? String {
                print("Retrieved Caretaker ID: \(caretakerId)")
                // Now fetch caretaker details using this caretakerId.
                self.fetchCaretakerDetails(caretakerId: caretakerId)
            } else {
                print("No caretaker ID found for booking ID: \(bookingId)")
            }
        }
    }
    
    // Updated: Query the caretakers collection where the "caretakerId" field equals the auth UID.
    func fetchCaretakerDetails(caretakerId: String) {
        let db = Firestore.firestore()
        
        db.collection("caretakers").whereField("caretakerId", isEqualTo: caretakerId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching caretaker details: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, let document = documents.first else {
                print("No caretaker found with caretakerId: \(caretakerId)")
                return
            }
            
            let data = document.data()
            print("Fetched Caretaker Data: \(data)")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let decodedCaretaker = try JSONDecoder().decode(Caretakers.self, from: jsonData)
                self.caretaker = decodedCaretaker
                
                DispatchQueue.main.async {
                    self.updateCaretakerUI()
                }
            } catch {
                print("Error decoding caretaker data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UI Update
    func updateCaretakerUI() {
        guard let caretaker = self.caretaker else { return }
        
        caretakerNameLabel.text = caretaker.name
        experienceLabel.text = "Experience: \(caretaker.experience) years"
        addressLabel.text = caretaker.address
        
        if let imageUrl = URL(string: caretaker.profilePic) {
            caretakerImageView.loadImage(from: imageUrl)
        } else {
            caretakerImageView.image = UIImage(named: "placeholder")
        }
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailCell_Pet", for: indexPath) as! BookingDetailCell
            cell.configureCell(iconName: "pawprint.fill", title: "Pet Name", value: scheduleRequest?.petName ?? "N/A")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailCell_StartDate", for: indexPath) as! BookingDetailCell
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            cell.configureCell(iconName: "calendar", title: "Start Date", value: dateFormatter.string(from: scheduleRequest?.startDate ?? Date()))
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailCell_EndDate", for: indexPath) as! BookingDetailCell
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            cell.configureCell(iconName: "calendar", title: "End Date", value: dateFormatter.string(from: scheduleRequest?.endDate ?? Date()))
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailCell_Pickup", for: indexPath) as! BookingDetailCell
            cell.configureCell(iconName: "mappin.and.ellipse", title: "Pickup Location", value: "Akshaya The Belvedere, Urapakkam, Chennai")
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailCell_Payment", for: indexPath) as! BookingDetailCell
            cell.configureCell(iconName: "indianrupeesign.circle.fill", title: "Payment Amount", value: "₹600")
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UIImageView Extension for Async Image Loading
extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
