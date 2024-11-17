//
//  CompletedBookingViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 17/11/24.
//

import UIKit

class CompletedBookingViewController: UIViewController {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var caretakingStatusLabel: UILabel!
    @IBOutlet weak var caretakingFeesLabel: UILabel!
    @IBOutlet weak var paymentStatusLabel: UILabel!
    
    var booking: Booking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let booking = booking {
                    title = booking.name // Use a property of the booking model as the title
                } else {
                    title = "Booking Details" // Default title
                }
            
        configureUI()

        // Do any additional setup after loading the view.
    }
    private func configureUI() {
            guard let booking = booking else { return }
            
            profileImageView.image = UIImage(named: booking.image)
            nameLabel.text = booking.name
            startDateLabel.text =  booking.date.split(separator: "•").first?.trimmingCharacters(in: .whitespaces) ?? ""
            endDateLabel.text = booking.date.split(separator: "•").last?.trimmingCharacters(in: .whitespaces) ?? ""
            caretakingStatusLabel.text = booking.status ?? "Unknown"
            caretakingFeesLabel.text = " Rs 1250"
            paymentStatusLabel.text =  booking.iscompleted ? "Completed" : "Pending"
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
