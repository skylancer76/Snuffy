//
//  MyBookingViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 14/11/24.
//

import UIKit

class MyBookingViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    
    @IBOutlet var tableView: UITableView!
    var isCompleted: Bool = false
    var filteredBookings: [Booking]{
        return bookings.filter{
            $0.iscompleted == isCompleted
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredBookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyBookingCell", for: indexPath)
        let booking = filteredBookings[indexPath.row]
        if let cell = cell as? MyBookingTableViewCell{
            cell.nameLabel.text = booking.name
            cell.statusLabel.text = booking.status ?? "Completed"
            cell.date.text = booking.date
            cell.image1.image = UIImage(named: booking.image)
            
            if cell.statusLabel.text == "Completed"{
                cell.statusLabel.textColor = .blue
            }
            else{
                cell.statusLabel.textColor = .systemGreen
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

        
        
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let detailVC = segue.destination as? CompletedBookingViewController,
//               let indexPath = tableView.indexPathForSelectedRow {
//                detailVC.booking = filteredBookings[indexPath.row]
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBooking = filteredBookings[indexPath.row]
        
        // Instantiate CompletedBookingViewController using its Storyboard ID
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "CompletedBookingViewController") as? CompletedBookingViewController {
            detailVC.booking = selectedBooking // Pass data to the detail view controller
            
            // Push onto the navigation stack
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            print("Could not instantiate CompletedBookingViewController")
        }
    }
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
            // Do any additional setup after loading the view.
        }
        
        
        @IBAction func setCompleted(_ sender: UISegmentedControl) {
            
            isCompleted = sender.selectedSegmentIndex == 1
            tableView.reloadData()
        }
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }

