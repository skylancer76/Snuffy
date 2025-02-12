//
//  Caretaker Home.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.


import UIKit
import FirebaseAuth
import FirebaseStorage

class Caretaker_Home: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    
    var scheduleRequests: [ScheduleCaretakerRequest] = []
    
    var caretakerId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else {
                   print("Error: No user logged in")
                   return
               }
               caretakerId = currentUser.uid
               print("Fetching schedule requests for caretaker ID: \(caretakerId!)")
               
               FirebaseManager.shared.fetchAssignedRequests(for: caretakerId!) { requests in
                   print("Fetched Requests for \(self.caretakerId!): \(requests.count)")
             
               self.scheduleRequests = requests
               self.tableView.reloadData()
           }
        
        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds                          // Match the frame of the view
        gradientLayer.colors = [
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor,  // Start color
            UIColor.clear.cgColor                                  // End color
        ]
        gradientLayer.locations = [0.0, 1.0]                       // Gradually fade
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)         // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)           // Bottom-center
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        tableView.backgroundColor = .clear
        bgView.backgroundColor = .clear
    }

    @objc func acceptTapped(_ sender: UIButton) {
          
            guard sender.tag < scheduleRequests.count, let caretakerId = self.caretakerId else { return }
            let request = scheduleRequests[sender.tag]
            FirebaseManager.shared.acceptRequest(caretakerId: caretakerId, requestId: request.requestId) { error in
                if let error = error {
                    print("Error accepting request: \(error.localizedDescription)")
                } else {
                    // Remove the accepted request and update the table view.
                    self.scheduleRequests.remove(at: sender.tag)
                    self.tableView.reloadData()
                }
            }
        }

    @objc func rejectTapped(_ sender: UIButton) {
        guard sender.tag < scheduleRequests.count, let caretakerId = self.caretakerId else { return }
        let request = scheduleRequests[sender.tag]
        FirebaseManager.shared.fetchAvailableCaretakers { sortedCaretakers in
            guard !sortedCaretakers.isEmpty else {
                print("No other caretakers available for reassignment.")
                return
            }
            
            FirebaseManager.shared.rejectRequest(
                caretakerId: caretakerId,
                requestId: request.requestId,
                sortedCaretakers: sortedCaretakers
            ) { error in
                if let error = error {
                    print("Error rejecting request: \(error.localizedDescription)")
                } else {
                    self.scheduleRequests.remove(at: sender.tag)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestTableViewCell
        let request = scheduleRequests[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.bgView.layer.cornerRadius = 10
        cell.bgView.layer.masksToBounds = false
        cell.bgView.layer.shadowRadius = 5
        cell.bgView.layer.shadowOpacity = 0.1
        cell.petNameLabel.text = request.petName
        cell.petBreedLabel.text = request.petBreed ?? "Breed Not Available"
        cell.ownerNameLabel.text = request.userName
        cell.durationLabel.text = request.duration
        cell.petImageView.layer.cornerRadius = 10
        cell.petImageView.layer.masksToBounds = true
            
        // Load Image (if available)
        if let imageUrlString = request.petImageUrl, !imageUrlString.isEmpty {
            print("Loading Image from URL: \(imageUrlString)")
            if let url = URL(string: imageUrlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            cell.petImageView.image = UIImage(data: data)
                        }
                    }
                    else {
                        print("Failed to load image data from URL: \(url)")
                        DispatchQueue.main.async {
                            cell.petImageView.image = UIImage(named: "placeholder")
                        }
                    }
                }
            }
            else {
                print("Invalid URL: \(imageUrlString)")
                cell.petImageView.image = UIImage(named: "placeholder")
            }
        }
        else {
            print("No image URL available for pet: \(request.petName)")
            cell.petImageView.image = UIImage(named: "placeholder")
        }
        
        // Accept & Reject Button Actions
        cell.acceptButton.tag = indexPath.row
        cell.rejectButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(acceptTapped(_:)), for: .touchUpInside)
        cell.rejectButton.addTarget(self, action: #selector(rejectTapped(_:)), for: .touchUpInside)
            
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }


}
