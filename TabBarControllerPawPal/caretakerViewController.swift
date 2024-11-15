//
//  caretakerViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 07/11/24.
//

import UIKit

class caretakerViewController: UIViewController {

    
    @IBOutlet weak var galleryStackView: UIStackView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
 
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var ratingsLabel: UILabel!
    
    @IBOutlet weak var experienceLabel: UILabel!
    
    @IBOutlet weak var rateLabel: UILabel!
    
    
    @IBOutlet weak var verifiedLabel: UILabel!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    var caretaker: Caretaker?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCaretakerData()
                updateUI()
      
    }
    func loadCaretakerData() {
            
            caretaker = Caretaker(
                name: "Katie",
                title: "Top Pet Sitter",
                ratings: 35,
                experience: "5+ Yrs Experience",
                rate: "Rs 400/Day",
                verified: true,
//                location: "See Location",
                about: "About",
                galleryImages: ["cat1", "cat2", "cat3"]
            )
        }
    
//    func updateUI() {
//            guard let caretaker = caretaker else { return }
//            
//            nameLabel.text = caretaker.name
//            titleLabel.text = caretaker.title
//            ratingsLabel.text = "\(caretaker.ratings) Ratings"
//            experienceLabel.text = caretaker.experience
//            rateLabel.text = caretaker.rate
//            verifiedLabel.text = caretaker.verified ? "Verified" : "Not Verified"
////            locationButton.setTitle(caretaker.location, for: .normal)
//            aboutLabel.text = caretaker.about
//        
//        profileImageView.image = UIImage(named: "Profile Image")
//               
//               
//               galleryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//               
//               // Add images to the gallery stack view
//               for imageName in caretaker.galleryImages {
//                   let imageView = UIImageView()
//                   imageView.image = UIImage(named: imageName)
//                   imageView.contentMode = .scaleAspectFill
//                   imageView.clipsToBounds = true
//                   imageView.layer.cornerRadius = 8
//                   imageView.translatesAutoresizingMaskIntoConstraints = false
//                   imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
//                   imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
//                   galleryStackView.addArrangedSubview(imageView)
//               }
//           }
//    
    func updateUI() {
          guard let caretaker = caretaker else { return }
          
          nameLabel.text = caretaker.name
          titleLabel.text = caretaker.title
          ratingsLabel.text = "\(caretaker.ratings) Ratings"
          experienceLabel.text = caretaker.experience
          rateLabel.text = caretaker.rate
          verifiedLabel.text = caretaker.verified ? "Verified" : "Not Verified"
          aboutLabel.text = caretaker.about
          
          profileImageView.image = UIImage(named: "Profile Image")
          
          galleryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
          
          // Add images to the gallery stack view
          for imageName in caretaker.galleryImages {
              let imageView = UIImageView()
              imageView.image = UIImage(named: imageName)
              imageView.contentMode = .scaleAspectFill
              imageView.clipsToBounds = true
              imageView.layer.cornerRadius = 8
              imageView.translatesAutoresizingMaskIntoConstraints = false
              imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
              imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
              galleryStackView.addArrangedSubview(imageView)
          }
      }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
