//
//  My Bookings.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 31/12/24.
//

import UIKit
import FirebaseFirestore

class My_Bookings: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var tableView: UITableView!
    var isCompleted: Bool = false
        var caretakers: [Caretakers] = []
        var bookings: [Bookings] = []
    
    var filteredBookings: [Bookings] {
            return bookings.filter { $0.isCompleted == isCompleted }
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        fetchCaretakers()
    }
    func fetchCaretakers() {
            FirebaseManager.shared.fetchCaretakerData { [weak self] (caretakers, error) in
                if let error = error {
                    print("Error fetching caretakers: \(error.localizedDescription)")
                    return
                }
                guard let caretakers = caretakers else {
                    print("No caretakers found.")
                    return
                }

                // Store caretakers and extract all bookings
                self?.caretakers = caretakers
                self?.bookings = caretakers.flatMap { $0.bookings ?? [] }
                self?.tableView.reloadData()
            }
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return filteredBookings.count
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyBooking", for: indexPath)
            let booking = filteredBookings[indexPath.row]
            if let cell = cell as? My_Bookings_Cell {
                cell.nameLabel.text = booking.name
                cell.statusLabel.text = booking.status ?? "Completed"
                cell.date.text = booking.date
                cell.profileImage.image = UIImage(named: booking.image)
                cell.cellView.layer.cornerRadius = 15
                cell.cellView.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.cellView.layer.shadowOpacity = 0.1
                cell.cellView.layer.shadowRadius = 3


                // Adjust status label color
                cell.statusLabel.textColor = booking.status == "Completed" ? .systemBlue : .systemGreen
            }
            return cell
        }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }

        // MARK: - TableView Delegate
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            let selectedBooking = filteredBookings[indexPath.row]
//            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "CompletedBookingViewController") as? CompletedBookingViewController {
//                detailVC.booking = selectedBooking
//                navigationController?.pushViewController(detailVC, animated: true)
//            } else {
//                print("Could not instantiate CompletedBookingViewController")
//            }
//        }
    @IBAction func setCompleted(_ sender: UISegmentedControl) {
            isCompleted = sender.selectedSegmentIndex == 1
            tableView.reloadData()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


