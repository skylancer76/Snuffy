//
//  Caretaker Bookings Information.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 11/03/25.
//

import UIKit

class Caretaker_Bookings_Information: UITableViewController {
    
    // MARK: - IBOutlets for Caretaker Booking Info (Static Cells)
    @IBOutlet weak var caretakerPetParentName: UILabel?
    @IBOutlet weak var caretakerStartDate: UILabel?
    @IBOutlet weak var caretakerStartTime: UILabel?
    @IBOutlet weak var caretakerEndDate: UILabel?
    @IBOutlet weak var caretakerEndTime: UILabel?
    @IBOutlet weak var caretakerStatus: UILabel?
    @IBOutlet weak var caretakerPetLocation: UILabel?
    
    // MARK: - IBOutlets for Dog Walker Booking Info (Static Cells)
    @IBOutlet weak var dogWalkerPetParentName: UILabel?
    @IBOutlet weak var dogWalkerDate: UILabel?
    @IBOutlet weak var dogWalkerStartTime: UILabel?
    @IBOutlet weak var dogWalkerEndTime: UILabel?
    @IBOutlet weak var dogWalkerStatus: UILabel?
    @IBOutlet weak var dogWalkerPetLocation: UILabel?
    
    // MARK: - Model Properties
    // Only one of these will be non-nil depending on the request type.
    var caretakerRequest: ScheduleCaretakerRequest?
    var dogWalkerRequest: ScheduleDogWalkerRequest?
    
    
    // NEW: A property to hold the pet name
    var petName: String? {
        return caretakerRequest?.petName ?? dogWalkerRequest?.petName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the UI based on the type of booking.
        if let caretakerReq = caretakerRequest {
            configureCaretakerUI(with: caretakerReq)
        } else if let dogReq = dogWalkerRequest {
            configureDogWalkerUI(with: dogReq)
        }
    }
    
    // MARK: - Prepare for Segue to Pet Profile
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "goToPetProfile" || segue.identifier == "goToPetProfileDogwalker" {
            if let destination = segue.destination as? Caretaker_Pet_Profile {
                // Pass the petName along
                destination.petName = self.petName
            }
        }
    }
    
    
    @IBAction func petDetailsButtonTapped(_ sender: Any) {
   
    }
    
    
    @IBAction func petDetailsButtonTapped1(_ sender: Any) {
        
    }
    
    
    
    
    
    // MARK: - Configure UI for Caretaker Booking
    func configureCaretakerUI(with request: ScheduleCaretakerRequest) {
        caretakerPetParentName?.text = request.userName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        caretakerStartDate?.text = dateFormatter.string(from: request.startDate!)
        caretakerStartTime?.text = timeFormatter.string(from: request.startDate!)
        caretakerEndDate?.text = dateFormatter.string(from: request.endDate!)
        caretakerEndTime?.text = timeFormatter.string(from: request.endDate!)
        
        caretakerStatus?.text = request.status.capitalized
        
        caretakerPetLocation?.text = shortPickupAddress(for: request)
    }
    
    // MARK: - Configure UI for Dog Walker Booking
    func configureDogWalkerUI(with request: ScheduleDogWalkerRequest) {
        dogWalkerPetParentName?.text = request.userName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dogWalkerDate?.text = dateFormatter.string(from: request.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        dogWalkerStartTime?.text = timeFormatter.string(from: request.startTime)
        dogWalkerEndTime?.text = timeFormatter.string(from: request.endTime)
        
        dogWalkerStatus?.text = request.status.capitalized
        
        dogWalkerPetLocation?.text = shortPickupAddress(for: request)
    }
    
    // MARK: - Helper: Short Address for Caretaker Request
    private func shortPickupAddress(for request: ScheduleCaretakerRequest) -> String {
        var components: [String] = []
        if let bNo = request.buildingNo, !bNo.isEmpty {
            components.append(bNo.trimmingCharacters(in: .whitespaces))
        }
        if let hNo = request.houseNo, !hNo.isEmpty {
            components.append(hNo.trimmingCharacters(in: .whitespaces))
        }
        if let landmark = request.landmark, !landmark.isEmpty {
            components.append(landmark.trimmingCharacters(in: .whitespaces))
        }
        return components.joined(separator: ", ")
    }
    
    // MARK: - Helper: Short Address for Dog Walker Request
    private func shortPickupAddress(for request: ScheduleDogWalkerRequest) -> String {
        var components: [String] = []
        if let building = request.buildingNo, !building.isEmpty {
            components.append(building.trimmingCharacters(in: .whitespaces))
        }
        if let house = request.houseNo, !house.isEmpty {
            components.append(house.trimmingCharacters(in: .whitespaces))
        }
        if let landmark = request.landmark, !landmark.isEmpty {
            components.append(landmark.trimmingCharacters(in: .whitespaces))
        }
        return components.joined(separator: ", ")
    }
}
