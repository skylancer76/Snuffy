//
//  Add Address.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 07/02/25.
//

//import UIKit
//import MapKit
//import FirebaseFirestore
//import FirebaseAuth
//
//// MARK: - Protocol to Pass Address Data
//protocol AddAddressDelegate: AnyObject {
//    func didSubmitAddress(addressData: [String: Any])
//}
//
//enum RequestType {
//    case caretaker
//    case dogwalker
//}
//
//// MARK: - Autocomplete Table Handler
//class AutocompleteTableHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
//    var searchResults: [MKLocalSearchCompletion] = []
//    var didSelectResult: ((MKLocalSearchCompletion) -> Void)?
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchResults.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell", for: indexPath)
//        let result = searchResults[indexPath.row]
//        cell.textLabel?.text = result.title + ", " + result.subtitle
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let result = searchResults[indexPath.row]
//        didSelectResult?(result)
//    }
//}
//
//// MARK: - Add Address View Controller
//class Add_Address: UITableViewController, MKMapViewDelegate {
//
//    // MARK: - Outlets
//    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var locationTextField: UITextField!
//    @IBOutlet weak var houseNoTextField: UITextField!
//    @IBOutlet weak var buildingNoTextField: UITextField!
//    @IBOutlet weak var landmarkTextField: UITextField!
//    
//    // MARK: - Properties
//    weak var delegate: AddAddressDelegate?
//    private var selectedCoordinate: CLLocationCoordinate2D?
//    
//    // Autocomplete properties
//    var autocompleteTableView: UITableView!
//    var searchCompleter: MKLocalSearchCompleter!
//    var autocompleteHandler: AutocompleteTableHandler!
//    
//    // Passed Data from previous screen(s)
//    var selectedPetName: String = ""
//    var startDate: Date = Date()
//    var endDate: Date = Date()
//    var isPetPickup: Bool = false
//    var isPetDropoff: Bool = false
//    var instructions: String = ""
//    
//    // New property to indicate request type (default is caretaker)
//    var requestType: RequestType = .caretaker
//    
//    // MARK: - View Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupMapView()
//        setupLocationTextField()
//        
//        // Set a default location (Chennai, in this example)
//        setDefaultLocationToChennai()
//        
//        // Setup autocomplete search completer and table view.
//        setupSearchCompleter()
//        setupAutocompleteTableView()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Position the autocomplete table view below the location text field.
//        if let frame = locationTextField.superview?.convert(locationTextField.frame, to: self.view) {
//            autocompleteTableView.frame = CGRect(x: frame.origin.x, y: frame.maxY, width: frame.width, height: 200)
//        }
//    }
//    
//    // MARK: - Setup Map View
//    private func setupMapView() {
//        mapView.delegate = self
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
//        mapView.addGestureRecognizer(tapGesture)
//    }
//    
//    // MARK: - Setup Location TextField with Search Capability
//    private func setupLocationTextField() {
//        locationTextField.clearButtonMode = .whileEditing
//        locationTextField.delegate = self
//    }
//    
//    // MARK: - Setup Search Completer
//    private func setupSearchCompleter() {
//        searchCompleter = MKLocalSearchCompleter()
//        searchCompleter.delegate = self
//        searchCompleter.region = mapView.region
//    }
//    
//    // MARK: - Setup Autocomplete Table View
//    private func setupAutocompleteTableView() {
//        autocompleteTableView = UITableView(frame: .zero, style: .plain)
//        autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AutoCompleteCell")
//        autocompleteTableView.isHidden = true
//        
//        autocompleteHandler = AutocompleteTableHandler()
//        autocompleteHandler.didSelectResult = { [weak self] result in
//            guard let self = self else { return }
//            let searchQuery = result.title + " " + result.subtitle
//            let searchRequest = MKLocalSearch.Request()
//            searchRequest.naturalLanguageQuery = searchQuery
//            searchRequest.region = self.mapView.region
//            let search = MKLocalSearch(request: searchRequest)
//            search.start { response, error in
//                guard let coordinate = response?.mapItems.first?.placemark.coordinate, error == nil else {
//                    print("Error in local search: \(error?.localizedDescription ?? "No error description")")
//                    return
//                }
//                self.selectedCoordinate = coordinate
//                DispatchQueue.main.async {
//                    self.mapView.removeAnnotations(self.mapView.annotations)
//                    let annotation = MKPointAnnotation()
//                    annotation.coordinate = coordinate
//                    self.mapView.addAnnotation(annotation)
//                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//                    self.mapView.setRegion(region, animated: true)
//                    self.getAddressFromCoordinates(coordinate: coordinate)
//                    self.autocompleteTableView.isHidden = true
//                    self.locationTextField.resignFirstResponder()
//                }
//            }
//        }
//        
//        autocompleteTableView.delegate = autocompleteHandler
//        autocompleteTableView.dataSource = autocompleteHandler
//        self.view.addSubview(autocompleteTableView)
//    }
//    
//    // MARK: - Set Default Map Region to Chennai
//    private func setDefaultLocationToChennai() {
//        let chennaiCoordinate = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)
//        let region = MKCoordinateRegion(center: chennaiCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        mapView.setRegion(region, animated: true)
//        selectedCoordinate = chennaiCoordinate
//        getAddressFromCoordinates(coordinate: chennaiCoordinate)
//    }
//    
//    // MARK: - Handle Map Tap for Selecting Location & Adding a Marker
//    @objc func mapTapped(_ sender: UITapGestureRecognizer) {
//        let location = sender.location(in: mapView)
//        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
//        selectedCoordinate = coordinate
//        mapView.removeAnnotations(mapView.annotations)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        mapView.addAnnotation(annotation)
//        getAddressFromCoordinates(coordinate: coordinate)
//    }
//    
//    // MARK: - Convert Coordinates to Address
//    private func getAddressFromCoordinates(coordinate: CLLocationCoordinate2D) {
//        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
//            guard let self = self,
//                  let placemark = placemarks?.first,
//                  error == nil else {
//                print("Error retrieving address: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            let addressString = [
//                placemark.name,
//                placemark.subLocality,
//                placemark.locality,
//                placemark.administrativeArea,
//                placemark.country
//            ].compactMap { $0 }.joined(separator: ", ")
//            
//            DispatchQueue.main.async {
//                self.locationTextField.text = addressString
//            }
//        }
//    }
//    
//    // MARK: - Schedule Request Button Tapped
//    @IBAction func scheduleRequestTapped(_ sender: UIButton) {
//        guard let locationText = locationTextField.text, !locationText.isEmpty,
//              let houseNo = houseNoTextField.text, !houseNo.isEmpty,
//              let buildingNo = buildingNoTextField.text, !buildingNo.isEmpty else {
//            showAlert(title: "Error", message: "Please fill in all required fields.")
//            return
//        }
//        
//        let addressData: [String: Any] = [
//            "location": locationText,
//            "houseNo": houseNo,
//            "buildingNo": buildingNo,
//            "landmark": landmarkTextField.text ?? "",
//            "latitude": selectedCoordinate?.latitude ?? 0.0,
//            "longitude": selectedCoordinate?.longitude ?? 0.0
//        ]
//        
//        // Call the appropriate save function based on the request type.
//        switch requestType {
//        case .caretaker:
//            saveCaretakerRequest(addressData: addressData)
//        case .dogwalker:
//            saveDogWalkerRequest(addressData: addressData)
//        }
//    }
//    
//    // MARK: - Save Caretaker Request
//    private func saveCaretakerRequest(addressData: [String: Any]) {
//        guard let currentUser = Auth.auth().currentUser else {
//            showAlert(title: "Error", message: "You must be logged in.")
//            return
//        }
//        let requestId = UUID().uuidString
//        let userId = currentUser.uid
//        
//        fetchUserName(userId: userId) { [weak self] userName in
//            guard let self = self else { return }
//            var requestData: [String: Any] = [
//                "requestId": requestId,
//                "userId": userId,
//                "userName": userName,
//                "petName": self.selectedPetName,
//                "startDate": Timestamp(date: self.startDate),
//                "endDate": Timestamp(date: self.endDate),
//                "petPickup": self.isPetPickup,
//                "petDropoff": self.isPetDropoff,
//                "instructions": self.instructions,
//                "status": "available",
//                "timestamp": Timestamp(date: Date())
//            ]
//            
//            // Merge additional address data.
//            for (key, value) in addressData {
//                requestData[key] = value
//            }
//            
//            FirebaseManager.shared.saveScheduleRequestData(data: requestData) { error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        print("Error scheduling caretaker request: \(error.localizedDescription)")
//                        self.showAlert(title: "Error", message: "Could not schedule request.")
//                    } else {
//                        let userLocation = self.selectedCoordinate.map {
//                            CLLocation(latitude: $0.latitude, longitude: $0.longitude)
//                        }
//                        FirebaseManager.shared.autoAssignCaretaker(
//                            petName: self.selectedPetName,
//                            requestId: requestId,
//                            userLocation: userLocation
//                        ) { assignError in
//                            if let assignError = assignError {
//                                print("Auto-assign caretaker error: \(assignError.localizedDescription)")
//                            } else {
//                                print("Caretaker assigned for request: \(requestId)")
//                            }
//                        }
//                        self.performSegue(withIdentifier: "showRequestScheduled", sender: self)
//                    }
//                }
//            }
//        }
//    }
//    
//    // MARK: - Save Dogwalker Request
//    private func saveDogWalkerRequest(addressData: [String: Any]) {
//        guard let currentUser = Auth.auth().currentUser else {
//            showAlert(title: "Error", message: "You must be logged in.")
//            return
//        }
//        let requestId = UUID().uuidString
//        let userId = currentUser.uid
//        
//        fetchUserName(userId: userId) { [weak self] userName in
//                    guard let self = self else { return }
//                    
//                    // For dog walker requests, the startDate and endDate represent the chosen start and end times.
//                    // Derive the 'date' field by extracting the date component from startDate.
//                    let calendar = Calendar.current
//                    let dateComponents = calendar.dateComponents([.year, .month, .day], from: self.startDate)
//                    guard let dateOnly = calendar.date(from: dateComponents) else {
//                        self.showAlert(title: "Error", message: "Invalid date selected.")
//                        return
//                    }
//                    
//                    // Calculate the duration between startDate and endDate.
//                    let interval = self.endDate.timeIntervalSince(self.startDate)
//                    let hours = Int(interval) / 3600
//                    let minutes = (Int(interval) % 3600) / 60
//                    let durationString = "\(hours)h \(minutes)m"
//                    
//                    var requestData: [String: Any] = [
//                        "requestId": requestId,
//                        "userId": userId,
//                        "userName": userName,
//                        "petName": self.selectedPetName,
//                        "date": Timestamp(date: dateOnly),
//                        "startTime": Timestamp(date: self.startDate),
//                        "endTime": Timestamp(date: self.endDate),
//                        "duration": durationString,
//                        "instructions": self.instructions,
//                        "status": "available",
//                        "dogWalkerId": "",
//                        "timestamp": Timestamp(date: Date())
//                    ]
//                    
//            
//            for (key, value) in addressData {
//                requestData[key] = value
//            }
//            
//            FirebaseManager.shared.saveDogWalkerRequestData(data: requestData) { error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        print("Error scheduling dogwalker request: \(error.localizedDescription)")
//                        self.showAlert(title: "Error", message: "Could not schedule request.")
//                    } else {
//                        let userLocation = self.selectedCoordinate.map {
//                            CLLocation(latitude: $0.latitude, longitude: $0.longitude)
//                        }
//                        FirebaseManager.shared.autoAssignDogWalker(
//                            petName: self.selectedPetName,
//                            requestId: requestId,
//                            userLocation: userLocation
//                        ) { assignError in
//                            if let assignError = assignError {
//                                print("Auto-assign dogwalker error: \(assignError.localizedDescription)")
//                            } else {
//                                print("Dogwalker assigned for request: \(requestId)")
//                            }
//                        }
//                        self.performSegue(withIdentifier: "showRequestScheduled", sender: self)
//                    }
//                }
//            }
//        }
//    }
//    
//    func fetchUserName(userId: String, completion: @escaping (String) -> Void) {
//        let usersCollection = Firestore.firestore().collection("users")
//        usersCollection.document(userId).getDocument { document, error in
//            if let error = error {
//                print("Failed to fetch user name: \(error.localizedDescription)")
//                completion("Anonymous User")
//            } else if let document = document, document.exists,
//                      let data = document.data(),
//                      let name = data["name"] as? String, !name.isEmpty {
//                completion(name)
//            } else {
//                completion("Anonymous User")
//            }
//        }
//    }
//    
//    // MARK: - Show Alert Helper
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UITextFieldDelegate for Search & Autocomplete
//extension Add_Address: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == locationTextField {
//            if let searchText = textField.text, !searchText.isEmpty {
//                let geocoder = CLGeocoder()
//                geocoder.geocodeAddressString(searchText) { [weak self] placemarks, error in
//                    guard let self = self else { return }
//                    if let error = error {
//                        print("Geocode error: \(error.localizedDescription)")
//                        return
//                    }
//                    
//                    if let placemark = placemarks?.first, let location = placemark.location {
//                        let coordinate = location.coordinate
//                        self.selectedCoordinate = coordinate
//                        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//                        DispatchQueue.main.async {
//                            self.mapView.setRegion(region, animated: true)
//                            self.mapView.removeAnnotations(self.mapView.annotations)
//                            let annotation = MKPointAnnotation()
//                            annotation.coordinate = coordinate
//                            self.mapView.addAnnotation(annotation)
//                        }
//                    }
//                }
//            }
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == locationTextField {
//            let currentText = textField.text ?? ""
//            guard let stringRange = Range(range, in: currentText) else { return true }
//            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
//            searchCompleter.queryFragment = updatedText
//            autocompleteTableView.isHidden = updatedText.isEmpty
//            
//            if updatedText.isEmpty {
//                autocompleteHandler.searchResults = []
//                autocompleteTableView.reloadData()
//            }
//        }
//        return true
//    }
//}
//
//// MARK: - MKLocalSearchCompleterDelegate for Autocomplete
//extension Add_Address: MKLocalSearchCompleterDelegate {
//    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        autocompleteHandler.searchResults = completer.results
//        autocompleteTableView.reloadData()
//    }
//    
//    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
//        print("Search completer error: \(error.localizedDescription)")
//    }
//}
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
        // Update the existing request document with the address data.
        if let requestId = currentRequestId {
            let requestRef = Firestore.firestore().collection("dogWalkerRequests").document(requestId)
            requestRef.updateData(addressData) { error in
                if let error = error {
                    print("Error updating dog walker request with address: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Could not update the request with address.")
                } else {
                    print("Successfully updated dog walker request with address!")
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
            }
        } else {
            print("No current request ID found; cannot update address.")
        }
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
