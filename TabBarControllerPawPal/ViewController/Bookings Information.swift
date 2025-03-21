//
//  Bookings Information.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 09/02/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MessageUI


class Bookings_Information: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    // MARK: - IBOutlets for Caretaker Section (static cells)
    @IBOutlet weak var caretakerImageView: UIImageView!
    @IBOutlet weak var caretakerNameLabel: UILabel!
    @IBOutlet weak var caretakerAddressLabel: UILabel!
    @IBOutlet var caretakerChatImageView: UIImageView!
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
    
    var scheduleRequest: ScheduleCaretakerRequest?
    var caretaker: Caretakers?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        caretakerImageView.layer.cornerRadius = 8
        caretakerImageView.clipsToBounds = true
        caretakerCallImageView.gestureRecognizers?.forEach(caretakerCallImageView.removeGestureRecognizer)
        
   
        caretakerCallImageView.gestureRecognizers?.forEach(caretakerCallImageView.removeGestureRecognizer)
        caretakerChatImageView.gestureRecognizers?.forEach(caretakerChatImageView.removeGestureRecognizer)

     
        let callTapGesture = UITapGestureRecognizer(target: self, action: #selector(callCaretakerTapped))
        caretakerCallImageView.addGestureRecognizer(callTapGesture)
        caretakerCallImageView.isUserInteractionEnabled = true // Ensure it's clickable

       
        let chatTapGesture = UITapGestureRecognizer(target: self, action: #selector(openChat))
        caretakerChatImageView.addGestureRecognizer(chatTapGesture)
        caretakerChatImageView.isUserInteractionEnabled = true

        
        
        if let request = scheduleRequest {
            updateBookingUI(with: request)
            fetchCaretakerIdFromBooking(bookingId: request.requestId)
        } else {
            print("scheduleRequest is nil") // Debugging
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
            print("Attempting to open call URL: \(url)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Failed to initiate call") // Debugging
        }
    }
    
    @objc func openChat() {
        print("Chat button tapped")
        
        // Use iMessage (MFMessageComposeViewController) to open the messaging interface
        guard let caretakerPhone = caretaker?.phoneNumber, !caretakerPhone.isEmpty else {
            print("Caretaker phone number is nil or empty")
            return
        }
        
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = self
            messageVC.recipients = [caretakerPhone]
            messageVC.body = "Hi, I would like to chat about my booking."
            
            // Check if attachments are supported
            if messageVC.responds(to: #selector(MFMessageComposeViewController.addAttachmentData(_:typeIdentifier:filename:))) {
                // Example: Attach an image (make sure "sampleImage" exists in your assets or bundle)
                if let image = UIImage(named: "sampleImage"), let imageData = image.pngData() {
                    let attached = messageVC.addAttachmentData(imageData, typeIdentifier: "public.png", filename: "sampleImage.png")
                    print("Image attachment added: \(attached)")
                }
                
                // Example: Attach a document (for example, a PDF from your app bundle)
                if let docURL = Bundle.main.url(forResource: "sampleDocument", withExtension: "pdf"),
                   let docData = try? Data(contentsOf: docURL) {
                    let attached = messageVC.addAttachmentData(docData, typeIdentifier: "com.adobe.pdf", filename: "sampleDocument.pdf")
                    print("Document attachment added: \(attached)")
                }
            } else {
                print("Attachments are not supported on this device.")
            }
            
            present(messageVC, animated: true, completion: nil)
        } else {
            print("Device cannot send messages.")
        }
    }
    
        
        // MARK: - MFMessageComposeViewControllerDelegate
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
        }
        
    // MARK: - Booking UI
    private func updateBookingUI(with request: ScheduleCaretakerRequest) {
        
        // Pet Name
        petNameLabel.text = request.petName
        
        // Format the start/end dates & times separately
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        // Start date/time
        startDateLabel.text = dateFormatter.string(from: request.startDate!)
        startTimeLabel.text = timeFormatter.string(from: request.startDate!)
        
        // End date/time
        endDateLabel.text = dateFormatter.string(from: request.endDate!)
        endTimeLabel.text = timeFormatter.string(from: request.endDate!)
        
        // Status
        statusLabel.text = request.status.capitalized  // e.g. "Accepted"
        
        // Pickup location (shortened)
        pickupLocationLabel.text = shortPickupAddress(for: request)
        
        
    }
    
    
    
    // MARK: - Short Address Helper
    private func shortPickupAddress(for request: ScheduleCaretakerRequest) -> String {
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
        caretakerAddressLabel.text = caretaker.address
        
        // If caretaker has phone
        if let phone = caretaker.phoneNumber, !phone.isEmpty {
            
            caretakerCallImageView.isHidden = false
        } else {
            
            caretakerCallImageView.isHidden = true
        }
        
        // Load caretaker image
        if let url = URL(string: caretaker.profilePic!) {
            caretakerImageView.loadImage(from: url)
        } else {
            caretakerImageView.image = UIImage(named: "placeholder")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1) If "Track Pet" cell is tapped (assumed section 2, row 0)
        if indexPath.section == 2 && indexPath.row == 0 {
            guard let caretaker = self.caretaker,
                  let latitude = caretaker.latitude,
                  let longitude = caretaker.longitude else {
                print("Error: Caretaker location not available")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mapVC = storyboard.instantiateViewController(withIdentifier: "Track_Pet_Map") as? Track_Pet_Map {
                mapVC.caretakerLatitude = latitude
                mapVC.caretakerLongitude = longitude
                navigationController?.pushViewController(mapVC, animated: true)
            }
        }
        // 2) If caretaker cell is tapped (assumed section 0, row 0)
        else if indexPath.section == 0 && indexPath.row == 0 {
            guard let caretaker = self.caretaker else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let caretakerProfileVC = storyboard.instantiateViewController(withIdentifier: "Caretaker_Profile") as? Caretaker_Profile {
                // Pass the caretaker’s ID and set the profile type
                caretakerProfileVC.profileId = caretaker.caretakerId
                caretakerProfileVC.profileType = .caretaker
                navigationController?.pushViewController(caretakerProfileVC, animated: true)
            }
        }
    }

}
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
