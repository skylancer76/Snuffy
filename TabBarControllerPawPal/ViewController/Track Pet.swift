//
//  Track Pet.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 04/01/25.
//

import UIKit
import MapKit
import Firebase

// MARK: - Custom Pin Class
class PetPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var pet: PetLiveUpdate

    init(pet: PetLiveUpdate) {
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
    private var petsUpdate: [PetLiveUpdate] = []
    private var imageCollectionView: UICollectionView!
    private var chatButton: UIButton!
    private var selectedPet: PetLiveUpdate? // Track the currently selected pet for slideshow

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up map
        setupMap()

        // Load pets from Firebase
        fetchPetsFromFirebase()

        // Set up floating panel
        setupFloatingPanel()
    }

    // MARK: - Firebase Integration
    func fetchPetsFromFirebase() {
        let db = Firestore.firestore()

        db.collection("petsLive").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching pets: \(error.localizedDescription)")
                return
            }

            self.petsUpdate.removeAll()
            for document in querySnapshot?.documents ?? [] {
                if let pet = PetLiveUpdate(from: document.data()) {
                    self.petsUpdate.append(pet)
                } else {
                    print("Failed to initialize PetLiveUpdate from document: \(document.data())")
                }
            }

            // Refresh map with new pins
            DispatchQueue.main.async {
                self.addPetPins()
            }
        }
    }

    // MARK: - Map Setup
    func setupMap() {
        mapView.delegate = self
        let defaultLocation = CLLocationCoordinate2D(latitude: 12.8230, longitude: 80.0444)
        let region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    // MARK: - Add Pins to Map
    func addPetPins() {
        mapView.removeAnnotations(mapView.annotations) // Clear old pins
        for pet in petsUpdate {
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

    // MARK: - Floating Panel Gestures
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

    func showFloatingPanel(for pet: PetLiveUpdate) {
        selectedPet = pet
        floatingPanel.subviews.forEach { if $0 != floatingPanelHandle { $0.removeFromSuperview() } }

        // Title Label
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: floatingPanel.frame.width - 40, height: 30))
        titleLabel.text = pet.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        floatingPanel.addSubview(titleLabel)

        // Image Collection View
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: floatingPanel.frame.width - 40, height: 300) // Increased size
        layout.minimumLineSpacing = 10

        imageCollectionView = UICollectionView(frame: CGRect(x: 20, y: 60, width: floatingPanel.frame.width - 40, height: 300), collectionViewLayout: layout)
        imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.backgroundColor = .clear
        floatingPanel.addSubview(imageCollectionView)
        imageCollectionView.reloadData()

        // Description Label
        let descriptionLabel = UILabel(frame: CGRect(x: 20, y: 370, width: floatingPanel.frame.width - 40, height: 60))
        descriptionLabel.text = pet.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        floatingPanel.addSubview(descriptionLabel)

        // Chat Button
        chatButton = UIButton(frame: CGRect(x: (floatingPanel.frame.width - 150) / 2, y: 450, width: 150, height: 50))
        chatButton.setTitle("Message", for: .normal)
        chatButton.setTitleColor(.white, for: .normal)
        chatButton.backgroundColor = .systemPurple
        chatButton.layer.cornerRadius = 8
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        floatingPanel.addSubview(chatButton)
    }

    @objc func chatButtonTapped() {
        guard let selectedPet = selectedPet else { return }
        print("Message button tapped for pet: \(selectedPet.name)")
        // Navigate to a chat screen or perform any action
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
        imageView.layer.cornerRadius = 10
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
        annotationView?.glyphImage = UIImage(systemName: "pawprint.fill")
        annotationView?.markerTintColor = .systemPurple

        // Add callout button
        let infoButton = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = infoButton

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let petPin = view.annotation as? PetPin else { return }
        showFloatingPanel(for: petPin.pet)
        expandFloatingPanel()
    }
}
