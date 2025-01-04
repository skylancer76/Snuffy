//
//  Track Pet.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 04/01/25.
//

import UIKit
import MapKit

// MARK: - Pet Data Model
struct Pet {
    let name: String
    let description: String
    let image: String
    let location: CLLocationCoordinate2D
    let im: [String] // Array for slideshow images
}

// MARK: - Custom Pin Class
class PetPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var pet: Pet

    init(pet: Pet) {
        self.pet = pet
        self.title = pet.name
        self.subtitle = nil
        self.coordinate = pet.location
    }
}

// MARK: - Main View Controller
class Track_Pet: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    private var floatingPanel: UIView!
    private var floatingPanelHandle: UIView!
    private var floatingPanelPanGesture: UIPanGestureRecognizer!
    private var floatingPanelInitialOffset: CGFloat!
    private var pets: [Pet] = []
    private var imageCollectionView: UICollectionView!
    private var chatButton: UIButton!
    private var selectedPet: Pet? // Track the currently selected pet for slideshow
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up map
        setupMap()
        
        // Load pets and add pins
        loadPets()
        addPetPins()
        
        // Set up floating panel
        setupFloatingPanel()
    }
    
    // MARK: - Map Setup
    func setupMap() {
        mapView.delegate = self
        let defaultLocation = CLLocationCoordinate2D(latitude: 12.8230, longitude: 80.0444)
        let region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Load Pet Data
    func loadPets() {
        pets = [
            Pet(name: "Buzzo", description: "Found near the Community Park SRM.", image: "paw", location: CLLocationCoordinate2D(latitude: 12.8230, longitude: 80.0444), im: ["pick1", "pick2", "pick3"]),
            Pet(name: "Fluffy", description: "Spotted near the main gate.", image: "paw", location: CLLocationCoordinate2D(latitude: 12.8210, longitude: 80.0424), im: ["pick1", "pick2", "pick3"]),
            Pet(name: "Max", description: "Seen by the sports complex.", image: "paw", location: CLLocationCoordinate2D(latitude: 12.8250, longitude: 80.0454), im: ["pick1", "pick2", "pick3"])
        ]
    }
    
    // MARK: - Add Pins to Map
    func addPetPins() {
        for pet in pets {
            let pin = PetPin(pet: pet)
            mapView.addAnnotation(pin)
        }
    }
    
    // MARK: - Floating Panel Setup
    func setupFloatingPanel() {
        floatingPanel = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height * 3 / 4))
        floatingPanel.backgroundColor = .white
        floatingPanel.layer.cornerRadius = 16
        floatingPanel.layer.shadowColor = UIColor.black.cgColor
        floatingPanel.layer.shadowOpacity = 0.2
        floatingPanel.layer.shadowOffset = CGSize(width: 0, height: -2)
        floatingPanel.layer.shadowRadius = 4
        
        // Add handle to the floating panel
        floatingPanelHandle = UIView(frame: CGRect(x: (floatingPanel.frame.width - 40) / 2, y: 8, width: 40, height: 5))
        floatingPanelHandle.backgroundColor = UIColor.lightGray
        floatingPanelHandle.layer.cornerRadius = 2.5
        floatingPanel.addSubview(floatingPanelHandle)
        
        floatingPanelPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleFloatingPanelPan))
        floatingPanelPanGesture.delegate = self
        floatingPanel.addGestureRecognizer(floatingPanelPanGesture)
        
        view.addSubview(floatingPanel)
    }

    @objc func handleFloatingPanelPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let newY = floatingPanel.frame.origin.y + translation.y
        
        if gesture.state == .changed {
            if newY >= view.frame.height / 4 && newY <= view.frame.height {
                floatingPanel.frame.origin.y = newY
            }
        } else if gesture.state == .ended {
            let velocity = gesture.velocity(in: view).y
            if velocity > 0 {
                hideFloatingPanel()
            } else {
                expandFloatingPanel()
            }
        }
        
        gesture.setTranslation(.zero, in: view)
    }

    func expandFloatingPanel() {
        UIView.animate(withDuration: 0.3) {
            self.floatingPanel.frame.origin.y = self.view.frame.height / 4
        }
    }

    func hideFloatingPanel() {
        UIView.animate(withDuration: 0.3) {
            self.floatingPanel.frame.origin.y = self.view.frame.height
        }
    }

    
    func showFloatingPanel(for pet: Pet) {
        selectedPet = pet
        floatingPanel.subviews.forEach { if $0 != floatingPanelHandle { $0.removeFromSuperview() } }
        
        // Collection View for Slideshow
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let imageHeight = floatingPanel.frame.height / 1.8 // Adjusted to cover more space
        layout.itemSize = CGSize(width: floatingPanel.frame.width - 32, height: imageHeight) // Left and right padding of 16 each
        layout.minimumLineSpacing = 16 // Spacing between items
        
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 30, width: floatingPanel.frame.width, height: imageHeight), collectionViewLayout: layout)
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Padding for the collection view
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        imageCollectionView.isPagingEnabled = true
        imageCollectionView.backgroundColor = .white
        floatingPanel.addSubview(imageCollectionView)
        
        // Title Label
        let titleLabel = UILabel(frame: CGRect(x: 16, y: imageCollectionView.frame.maxY + 8, width: floatingPanel.frame.width - 100, height: 30))
        titleLabel.text = pet.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        floatingPanel.addSubview(titleLabel)
        
        // Chat Button
        chatButton = UIButton(frame: CGRect(x: floatingPanel.frame.width - 90, y: imageCollectionView.frame.maxY + 8, width: 70, height: 30))
        chatButton.setImage(UIImage(systemName: "message"), for: .normal)
        chatButton.tintColor = .white
        chatButton.backgroundColor = .systemPurple
        chatButton.layer.cornerRadius = 4
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        floatingPanel.addSubview(chatButton)
        
        // Description Label
        let descriptionLabel = UILabel(frame: CGRect(x: 16, y: titleLabel.frame.maxY + 16, width: floatingPanel.frame.width - 32, height: 60))
        descriptionLabel.text = pet.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .gray
        floatingPanel.addSubview(descriptionLabel)
        
        expandFloatingPanel()
    }
    
    // MARK: - Chat Button Action
    @objc func chatButtonTapped() {
        print("Chat button tapped!")
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPet?.im.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.image = UIImage(named: selectedPet?.im[indexPath.item] ?? "")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10 // Round the corners
        imageView.layer.masksToBounds = true // Ensure the corners are clipped
        cell.contentView.addSubview(imageView)
        
        return cell
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        guard let petPin = annotation as? PetPin else { return nil }
        
        let identifier = "petPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: petPin, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = petPin
        }
        
        // Customize marker appearance
        annotationView?.glyphImage = UIImage(systemName: "pawprint.fill") // Pawprint icon
        annotationView?.markerTintColor = .systemPurple // Purple marker color
        
        // Add callout button
        let infoButton = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = infoButton
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let petPin = view.annotation as? PetPin else { return }
        showFloatingPanel(for: petPin.pet)
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let petPin = annotationView.annotation as? PetPin else { return }
        print("Tapped callout for pet: \(petPin.pet.name)")
        // Add additional actions here if needed
    }
}
