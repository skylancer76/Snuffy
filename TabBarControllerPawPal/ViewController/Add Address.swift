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

// MARK: - Protocol to Pass Address Data
protocol AddAddressDelegate: AnyObject {
    func didSubmitAddress(addressData: [String: Any])
}

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
    // Location manager calls are commented out:
    // private let locationManager = CLLocationManager()
    private var selectedCoordinate: CLLocationCoordinate2D?
    
    // Autocomplete properties
    var autocompleteTableView: UITableView!
    var searchCompleter: MKLocalSearchCompleter!
    var autocompleteHandler: AutocompleteTableHandler!
    
    // Passed Data
    var selectedPetName: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isPetPickup: Bool = false
    var isPetDropoff: Bool = false
    var instructions: String = ""
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationTextField()
        
        // Location Manager calls are commented out:
        // setupLocationManager()
        // locationManager.startUpdatingLocation()
        
        // Force default location to Chennai.
        setDefaultLocationToChennai()
        
        // Setup autocomplete search completer and table view.
        setupSearchCompleter()
        setupAutocompleteTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Position the autocomplete table view below the location text field.
        if let frame = locationTextField.superview?.convert(locationTextField.frame, to: self.view) {
            autocompleteTableView.frame = CGRect(x: frame.origin.x, y: frame.maxY, width: frame.width, height: 200)
        }
    }
    
    // MARK: - Setup Map View
    private func setupMapView() {
        mapView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup Location TextField with Search Capability
    private func setupLocationTextField() {
        locationTextField.clearButtonMode = .whileEditing
        locationTextField.delegate = self
    }
    
    // MARK: - Setup Search Completer
    private func setupSearchCompleter() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        // Optionally, restrict results to the current map region.
        searchCompleter.region = mapView.region
    }
    
    // MARK: - Setup Autocomplete Table View
    private func setupAutocompleteTableView() {
        autocompleteTableView = UITableView(frame: .zero, style: .plain)
        autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AutoCompleteCell")
        autocompleteTableView.isHidden = true
        
        // Create and assign the autocomplete handler.
        autocompleteHandler = AutocompleteTableHandler()
        autocompleteHandler.didSelectResult = { [weak self] result in
            guard let self = self else { return }
            // Form the search query from the selected result.
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
                    // Update the marker on the map.
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    // Update the map region.
                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    self.mapView.setRegion(region, animated: true)
                    
                    // Update the text field with the reverse-geocoded address.
                    self.getAddressFromCoordinates(coordinate: coordinate)
                    
                    // Hide autocomplete suggestions.
                    self.autocompleteTableView.isHidden = true
                    self.locationTextField.resignFirstResponder()
                }
            }
        }
        
        autocompleteTableView.delegate = autocompleteHandler
        autocompleteTableView.dataSource = autocompleteHandler
        
        // Add the autocomplete table view as a subview.
        self.view.addSubview(autocompleteTableView)
    }
    
    // MARK: - Set Default Map Region to Chennai
    private func setDefaultLocationToChennai() {
        // Chennai's approximate coordinates.
        let chennaiCoordinate = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)
        let region = MKCoordinateRegion(center: chennaiCoordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        selectedCoordinate = chennaiCoordinate
        // Update the text field with the address.
        getAddressFromCoordinates(coordinate: chennaiCoordinate)
    }
    
    // MARK: - Handle Map Tap for Selecting Location & Adding a Marker
    @objc func mapTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        selectedCoordinate = coordinate
        
        // Remove any existing annotations and add a new marker.
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        getAddressFromCoordinates(coordinate: coordinate)
    }
    
    // MARK: - Convert Coordinates to Address
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
    
    // MARK: - Schedule Request Button Tapped
    @IBAction func scheduleRequestTapped(_ sender: UIButton) {
        guard let locationText = locationTextField.text, !locationText.isEmpty,
              let houseNo = houseNoTextField.text, !houseNo.isEmpty,
              let buildingNo = buildingNoTextField.text, !buildingNo.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all required fields.")
            return
        }
        
        // Prepare address data.
        let addressData: [String: Any] = [
            "location": locationText,
            "houseNo": houseNo,
            "buildingNo": buildingNo,
            "landmark": landmarkTextField.text ?? "",
            "latitude": selectedCoordinate?.latitude ?? 0.0,
            "longitude": selectedCoordinate?.longitude ?? 0.0
        ]
        
        // Save Request to Firebase.
        saveScheduleRequest(addressData: addressData)
    }
    
    // MARK: - Save Schedule Request to Firebase
    private func saveScheduleRequest(addressData: [String: Any]) {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "You must be logged in.")
            return
        }
        
        let requestId = UUID().uuidString
        let userId = currentUser.uid
        let userName = currentUser.displayName ?? "Anonymous User"
        
        // Request Data.
        var requestData: [String: Any] = [
            "requestId": requestId,
            "userId": userId,
            "userName": userName,
            "petName": selectedPetName,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "petPickup": isPetPickup,
            "petDropoff": isPetDropoff,
            "instructions": instructions,
            "status": "available",
            "timestamp": Timestamp(date: Date())
        ]
        
        // Merge Address Data.
        for (key, value) in addressData {
            requestData[key] = value
        }
        
        // Save to Firebase.
        FirebaseManager.shared.saveScheduleRequestData(data: requestData) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Error scheduling request: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Could not schedule request.")
                } else {
                    // Create a CLLocation from the selected coordinate (if available)
                    let userLocation = self.selectedCoordinate.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
                    
                    // Auto-assign caretaker immediately after saving the request.
                    FirebaseManager.shared.autoAssignCaretaker(petName: self.selectedPetName, requestId: requestId, userLocation: userLocation) { assignError in
                        if let assignError = assignError {
                            print("Auto-assign caretaker error: \(assignError.localizedDescription)")
                        } else {
                            print("Caretaker assigned for request: \(requestId)")
                        }
                    }
                    
                    self.performSegue(withIdentifier: "showRequestScheduled", sender: self)
                }
            }
        }
    }
    
    // MARK: - Show Alert Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate for Search & Autocomplete
extension Add_Address: UITextFieldDelegate {
    // When the user presses the Return key.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == locationTextField {
            if let searchText = textField.text, !searchText.isEmpty {
                // Perform a full search.
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
                        let region = MKCoordinateRegion(center: coordinate,
                                                        latitudinalMeters: 1000,
                                                        longitudinalMeters: 1000)
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
    
    // Update autocomplete suggestions as the user types.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == locationTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return true }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            searchCompleter.queryFragment = updatedText
            // Show or hide the autocomplete table view based on text emptiness.
            autocompleteTableView.isHidden = updatedText.isEmpty
            
            // Clear previous autocomplete results if text is empty.
            if updatedText.isEmpty {
                autocompleteHandler.searchResults = []
                autocompleteTableView.reloadData()
            }
        }
        return true
    }
}

// MARK: - MKLocalSearchCompleterDelegate for Autocomplete
extension Add_Address: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        autocompleteHandler.searchResults = completer.results
        autocompleteTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}

