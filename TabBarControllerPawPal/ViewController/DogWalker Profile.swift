//
//  DogWalker Profile.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 13/02/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DogWalker_Profile: UITableViewController {
    
    @IBOutlet weak var walkerImageView: UIImageView!
    @IBOutlet weak var walkerNameLabel: UILabel!
    @IBOutlet weak var walkerRatingLabel: UILabel!
    @IBOutlet weak var walkerAddressLabel: UILabel!
    @IBOutlet var walkerChatImageView: UIImageView!
    @IBOutlet weak var walkerCallImageView: UIImageView!
    
    // Booking details
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pickupLocationLabel: UILabel!
    
    
    
    var scheduleDogWalkerRequest: ScheduleDogWalkerRequest? 
    var dogWalker: DogWalker?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        walkerImageView.layer.cornerRadius = 8
                walkerImageView.clipsToBounds = true

                let callTapGesture = UITapGestureRecognizer(target: self, action: #selector(callWalkerTapped))
                walkerCallImageView.addGestureRecognizer(callTapGesture)
                walkerCallImageView.isUserInteractionEnabled = true

                let chatTapGesture = UITapGestureRecognizer(target: self, action: #selector(openChat))
                walkerChatImageView.addGestureRecognizer(chatTapGesture)
                walkerChatImageView.isUserInteractionEnabled = true
                
                if let request = scheduleDogWalkerRequest {
                    updateDogWalkerBookingUI(with: request)
                    fetchDogWalkerDetails(dogWalkerId: request.dogWalkerId)
                }
    }

    
    @objc func callWalkerTapped() {
            guard let phone = dogWalker?.phoneNumber, !phone.isEmpty else { return }
            if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        @objc func openChat() {
            guard let walkerId = dogWalker?.dogWalkerId, let userId = Auth.auth().currentUser?.uid else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatsViewController") as? Chats {
                chatVC.userId = userId
                chatVC.caretakerId = walkerId
                navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    
    
    private func shortPickupAddress(for request: ScheduleDogWalkerRequest) -> String {
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
    
    private func updateDogWalkerBookingUI(with request: ScheduleDogWalkerRequest) {
            petNameLabel.text = request.petName

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h a"

            dateLabel.text = dateFormatter.string(from: request.date)
            startTimeLabel.text = timeFormatter.string(from: request.startTime)
            endTimeLabel.text = timeFormatter.string(from: request.endTime)
            statusLabel.text = request.status.capitalized
            pickupLocationLabel.text = shortPickupAddress(for: request)
        }
    
    
    private func fetchDogWalkerDetails(dogWalkerId: String) {
        Firestore.firestore().collection("dogwalkers")
            .document(dogWalkerId)
            .getDocument { (document, error) in
                if let data = document?.data() {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let decodedWalker = try JSONDecoder().decode(DogWalker.self, from: jsonData)
                        self.dogWalker = decodedWalker
                        DispatchQueue.main.async {
                            self.updateDogWalkerUI(decodedWalker)
                        }
                    } catch {
                        print("Error decoding dog walker data: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    private func updateDogWalkerUI(_ walker: DogWalker) {
            walkerNameLabel.text = walker.name
            walkerRatingLabel.text = "Rating: \(walker.rating)"
            walkerAddressLabel.text = walker.address

            if let url = URL(string: walker.profilePic) {
                walkerImageView.loadImage(from: url)
            } else {
                walkerImageView.image = UIImage(named: "placeholder")
            }
        }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check if "Track Pet" cell is tapped
        if indexPath.section == 2 && indexPath.row == 0 {  // Update based on correct section/row
            guard let dogWalker = self.dogWalker,
                  let latitude = dogWalker.latitude,
                  let longitude = dogWalker.longitude else {
                print("Error: Caretaker location not available")
                return
            }
            
            // Navigate to MapViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mapVC = storyboard.instantiateViewController(withIdentifier: "Track_Pet_Map") as? Track_Pet_Map {
                mapVC.caretakerLatitude = latitude
                mapVC.caretakerLongitude = longitude
                navigationController?.pushViewController(mapVC, animated: true)
            }
        }
    }
    }
    // MARK: - Table view data source

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


