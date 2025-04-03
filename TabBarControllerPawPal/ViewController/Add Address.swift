//
//  Add Address.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 07/02/25.
//


import UIKit
import MapKit
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

// MARK: - Autocomplete Table Handler
class AutocompleteTableHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
    var searchResults: [MKLocalSearchCompletion] = []
    var didSelectResult: ((MKLocalSearchCompletion) -> Void)?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell", for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title + ", " + result.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        didSelectResult?(result)
    }
}

// MARK: - Protocol to Pass Address Data
    protocol AddAddressDelegate: AnyObject {
        func didSubmitAddress(addressData: [String: Any])
    }

    enum RequestType {
        case caretaker
        case dogwalker
    }

// MARK: - Add Address View Controller
class Add_Address: UITableViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var houseNoTextField: UITextField!
    @IBOutlet weak var buildingNoTextField: UITextField!
    @IBOutlet weak var landmarkTextField: UITextField!
    
    // MARK: - Properties
    weak var delegate: AddAddressDelegate?
    var currentRequestId: String?   // Received from previous screen
    private var selectedCoordinate: CLLocationCoordinate2D?
    
    // Autocomplete properties
    var autocompleteTableView: UITableView!
    var searchCompleter: MKLocalSearchCompleter!
    var autocompleteHandler: AutocompleteTableHandler!
    
    // Passed Data from previous screen(s)
    var selectedPetName: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isPetPickup: Bool = false
    var isPetDropoff: Bool = false
    var instructions: String = ""
    
    // Request type (default is caretaker)
    var requestType: RequestType = .caretaker
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationTextField()
        setDefaultLocationToChennai()
        setupSearchCompleter()
        setupAutocompleteTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let frame = locationTextField.superview?.convert(locationTextField.frame, to: self.view) {
            autocompleteTableView.frame = CGRect(x: frame.origin.x, y: frame.maxY, width: frame.width, height: 200)
        }
    }
    
    // MARK: - Setup Methods
    private func setupMapView() {
        mapView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    private func setupLocationTextField() {
        locationTextField.clearButtonMode = .whileEditing
        locationTextField.delegate = self
    }
    
    private func setupSearchCompleter() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        searchCompleter.region = mapView.region
    }
    
    private func setupAutocompleteTableView() {
        autocompleteTableView = UITableView(frame: .zero, style: .plain)
        autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AutoCompleteCell")
        autocompleteTableView.isHidden = true
        
        autocompleteHandler = AutocompleteTableHandler()
        autocompleteHandler.didSelectResult = { [weak self] result in
            guard let self = self else { return }
            let searchQuery = result.title + " " + result.subtitle
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchQuery
            searchRequest.region = self.mapView.region
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                guard let coordinate = response?.mapItems.first?.placemark.coordinate, error == nil else {
                    print("Error in local search: \(error?.localizedDescription ?? "No error description")")
                    return
                }
                self.selectedCoordinate = coordinate
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    self.mapView.addAnnotation(annotation)
                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    self.mapView.setRegion(region, animated: true)
                    self.getAddressFromCoordinates(coordinate: coordinate)
                    self.autocompleteTableView.isHidden = true
                    self.locationTextField.resignFirstResponder()
                }
            }
        }
        
        autocompleteTableView.delegate = autocompleteHandler
        autocompleteTableView.dataSource = autocompleteHandler
        self.view.addSubview(autocompleteTableView)
    }
    
    private func setDefaultLocationToChennai() {
        let chennaiCoordinate = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)
        let region = MKCoordinateRegion(center: chennaiCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        selectedCoordinate = chennaiCoordinate
        getAddressFromCoordinates(coordinate: chennaiCoordinate)
    }
    
    @objc func mapTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        selectedCoordinate = coordinate
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        getAddressFromCoordinates(coordinate: coordinate)
    }
    
    private func getAddressFromCoordinates(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self,
                  let placemark = placemarks?.first,
                  error == nil else {
                print("Error retrieving address: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let addressString = [
                placemark.name,
                placemark.subLocality,
                placemark.locality,
                placemark.administrativeArea,
                placemark.country
            ].compactMap { $0 }.joined(separator: ", ")
            DispatchQueue.main.async {
                self.locationTextField.text = addressString
            }
        }
    }
    
    // MARK: - IBAction for Scheduling (Update) Request
    
    @IBAction func scheduleRequestTapped(_ sender: UIButton) {
        guard let locationText = locationTextField.text, !locationText.isEmpty,
              let houseNo = houseNoTextField.text, !houseNo.isEmpty,
              let buildingNo = buildingNoTextField.text, !buildingNo.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all required fields.")
            return
        }
        
        let addressData: [String: Any] = [
            "location": locationText,
            "houseNo": houseNo,
            "buildingNo": buildingNo,
            "landmark": landmarkTextField.text ?? "",
            "latitude": selectedCoordinate?.latitude ?? 0.0,
            "longitude": selectedCoordinate?.longitude ?? 0.0
        ]
        
        // Check the request type.
        if requestType == .caretaker {
            // For caretaker requests, pass the data via the delegate.
            delegate?.didSubmitAddress(addressData: addressData)
            return
        }
        
        // For dogwalker requests, we expect a currentRequestId.
        guard let requestId = currentRequestId else {
            print("No current request ID found; cannot update address.")
            showAlert(title: "Error", message: "No request ID found for updating the dogwalker request.")
            return
        }
        
        let requestRef = Firestore.firestore().collection("dogWalkerRequests").document(requestId)
        
        // Check if the document exists
        requestRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching dogwalker request: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Could not retrieve the request.")
                return
            }
            
            if let document = document, document.exists {
                // Document exists, update it.
                self.updateDogwalkerRequest(requestRef: requestRef, addressData: addressData, requestId: requestId)
            } else {
                // Document doesn't exist, create it.
                requestRef.setData(addressData, merge: true) { error in
                    if let error = error {
                        print("Error creating dogwalker request with address: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Could not create the request with address.")
                    } else {
                        print("Successfully created dogwalker request with address!")
                        self.afterDogwalkerUpdate(addressData: addressData, requestId: requestId)
                    }
                }
            }
        }
    }

    private func updateDogwalkerRequest(requestRef: DocumentReference, addressData: [String: Any], requestId: String) {
        requestRef.updateData(addressData) { error in
            if let error = error {
                print("Error updating dog walker request with address: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Could not update the request with address.")
            } else {
                print("Successfully updated dog walker request with address!")
                self.afterDogwalkerUpdate(addressData: addressData, requestId: requestId)
            }
        }
    }

    private func afterDogwalkerUpdate(addressData: [String: Any], requestId: String) {
        let petName = self.selectedPetName
        let userLocation: CLLocation? = {
            if let lat = addressData["latitude"] as? Double,
               let lon = addressData["longitude"] as? Double {
                return CLLocation(latitude: lat, longitude: lon)
            }
            return nil
        }()
        FirebaseManager.shared.autoAssignDogWalker(
            petName: petName,
            requestId: requestId,
            userLocation: userLocation
        ) { assignError in
            if let assignError = assignError {
                print("Auto-assign dogwalker error: \(assignError.localizedDescription)")
            } else {
                print("Dogwalker assigned for request: \(requestId)")
            }
        }
        self.performSegue(withIdentifier: "showRequestScheduled", sender: self)
    }

    // MARK: - Alert Helper
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate & MKLocalSearchCompleterDelegate Extensions
    extension Add_Address: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == locationTextField {
                if let searchText = textField.text, !searchText.isEmpty {
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(searchText) { [weak self] placemarks, error in
                        guard let self = self else { return }
                        if let error = error {
                            print("Geocode error: \(error.localizedDescription)")
                            return
                        }
                        if let placemark = placemarks?.first, let location = placemark.location {
                            let coordinate = location.coordinate
                            self.selectedCoordinate = coordinate
                            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                            DispatchQueue.main.async {
                                self.mapView.setRegion(region, animated: true)
                                self.mapView.removeAnnotations(self.mapView.annotations)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = coordinate
                                self.mapView.addAnnotation(annotation)
                            }
                        }
                    }
                }
                textField.resignFirstResponder()
            }
            return true
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == locationTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return true }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            searchCompleter.queryFragment = updatedText
            autocompleteTableView.isHidden = updatedText.isEmpty
            
            if updatedText.isEmpty {
                autocompleteHandler.searchResults = []
                autocompleteTableView.reloadData()
            }
        }
        return true
    }
}

    extension Add_Address: MKLocalSearchCompleterDelegate {
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            autocompleteHandler.searchResults = completer.results
            autocompleteTableView.reloadData()
        }
        
        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            print("Search completer error: \(error.localizedDescription)")
        }
    }
