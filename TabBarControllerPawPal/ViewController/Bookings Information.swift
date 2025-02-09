//
//  Bookings Information.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 09/02/25.
//

import UIKit
import Firebase
import FirebaseFirestore

class Bookings_Information: UITableViewController {
    
    // MARK: - IBOutlets for Caretaker Section (static cells)
    @IBOutlet weak var caretakerImageView: UIImageView!
    @IBOutlet weak var caretakerNameLabel: UILabel!
    @IBOutlet weak var caretakerExperienceLabel: UILabel!
    @IBOutlet weak var caretakerAddressLabel: UILabel!
    
    @IBOutlet weak var caretakerCallImageView: UIImageView!
    
    // MARK: - IBOutlets for Booking Section (static cells)
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pickupLocationLabel: UILabel!
    //    @IBOutlet weak var instructionsLabel: UILabel!
    
    var scheduleRequest: ScheduleRequest?
    var caretaker: Caretakers?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        caretakerImageView.layer.cornerRadius = 8
        caretakerImageView.clipsToBounds = true
        caretakerCallImageView.gestureRecognizers?.forEach(caretakerCallImageView.removeGestureRecognizer)
        
        // Make the caretakerCallImageView tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(callCaretakerTapped))
        caretakerCallImageView.addGestureRecognizer(tapGesture)
        
        // If we have a schedule request, populate the booking info,
        // then fetch caretaker data from Firestore
        if let request = scheduleRequest {
            updateBookingUI(with: request)
            fetchCaretakerIdFromBooking(bookingId: request.requestId)
        } else {
            print("scheduleRequest is nil") // Debugging
        }
    }
    
    // MARK: - Booking UI
    private func updateBookingUI(with request: ScheduleRequest) {
        
        // Pet Name
        petNameLabel.text = request.petName
        
        // Format the start/end dates & times separately
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        // Start date/time
        startDateLabel.text = dateFormatter.string(from: request.startDate)
        startTimeLabel.text = timeFormatter.string(from: request.startDate)
        
        // End date/time
        endDateLabel.text = dateFormatter.string(from: request.endDate)
        endTimeLabel.text = timeFormatter.string(from: request.endDate)
        
        // Status
        statusLabel.text = request.status.capitalized  // e.g. "Accepted"
        
        // Pickup location (shortened)
        pickupLocationLabel.text = shortPickupAddress(for: request)
        
        
    }
    
    
    // MARK: - Short Address Helper
    private func shortPickupAddress(for request: ScheduleRequest) -> String {
        // Gather minimal fields for a short address
        var components: [String] = []
        
        if let bNo = request.buildingNo, !bNo.isEmpty {
            components.append(bNo.trimmingCharacters(in: .whitespaces))
        }
        if let hNo = request.houseNo, !hNo.isEmpty {
            components.append(hNo.trimmingCharacters(in: .whitespaces))
        }
        if let mark = request.landmark, !mark.isEmpty {
            components.append(mark.trimmingCharacters(in: .whitespaces))
        }
        
        // Optionally skip or include `location` if it’s too long
        // if let loc = request.location, !loc.isEmpty {
        //     components.append(loc.trimmingCharacters(in: .whitespaces))
        // }
        
        return components.joined(separator: ", ")
    }
    
    
    // MARK: - Firestore Fetch Methods
    private func fetchCaretakerIdFromBooking(bookingId: String) {
        let db = Firestore.firestore()
        
        db.collection("scheduleRequests").document(bookingId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching booking details: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data(),
                  let caretakerId = data["caretakerId"] as? String else {
                print("No caretaker ID found for booking ID: \(bookingId)")
                return
            }
            
            // Now fetch caretaker details
            self.fetchCaretakerDetails(caretakerId: caretakerId)
        }
    }
    
    private func fetchCaretakerDetails(caretakerId: String) {
        let db = Firestore.firestore()
        
        db.collection("caretakers")
            .whereField("caretakerId", isEqualTo: caretakerId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching caretaker details: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snapshot?.documents, let doc = docs.first else {
                    print("No caretaker found with caretakerId: \(caretakerId)")
                    return
                }
                
                let data = doc.data()
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let decodedCaretaker = try JSONDecoder().decode(Caretakers.self, from: jsonData)
                    self.caretaker = decodedCaretaker
                    
                    DispatchQueue.main.async {
                        self.updateCaretakerUI(decodedCaretaker)
                    }
                } catch {
                    print("Error decoding caretaker data: \(error.localizedDescription)")
                }
            }
    }
    
    // MARK: - Caretaker UI
    private func updateCaretakerUI(_ caretaker: Caretakers) {
        caretakerNameLabel.text = caretaker.name
        caretakerExperienceLabel.text = "Experience: \(caretaker.experience) years"
        caretakerAddressLabel.text = caretaker.address
        
        // If caretaker has phone
        if let phone = caretaker.phoneNumber, !phone.isEmpty {
            
            caretakerCallImageView.isHidden = false
        } else {
            
            caretakerCallImageView.isHidden = true
        }
        
        // Load caretaker image
        if let url = URL(string: caretaker.profilePic) {
            caretakerImageView.loadImage(from: url)
        } else {
            caretakerImageView.image = UIImage(named: "placeholder")
        }
    }
    
    
    
    @objc func callCaretakerTapped() {
        print("Call button tapped") // Debugging
        
        guard let phone = caretaker?.phoneNumber, !phone.isEmpty else {
            print("No phone number available") // Debugging
            return
        }
        
        let formattedPhone = phone.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(formattedPhone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            print("Calling: \(formattedPhone)") // Debugging
        } else {
            print("Failed to initiate call") // Debugging
        }
    }
    
    
    //    // MARK: - Table view data source
    //
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}
