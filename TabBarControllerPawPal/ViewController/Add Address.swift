//
//  Add Address.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 07/02/25.
//

//import UIKit
//import MapKit
//import CoreLocation
//import FirebaseFirestore
//
//class Add_Address: UITableViewController, CLLocationManagerDelegate {
//    
//
//    
//    // MARK: - Outlets (connected to table view cells)
//    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var houseFloorTextField: UITextField!
//    @IBOutlet weak var buildingBlockTextField: UITextField!
//    @IBOutlet weak var landmarkAreaTextField: UITextField!
//    
//    // These variables come from the Schedule_Request screen:
//    var selectedPetName: String = ""
//    var startDate: Date = Date()
//    var endDate: Date = Date()
//    var isPetPickup: Bool = false
//    var isPetDropoff: Bool = false
//    var instructions: String = ""
//    
//    private let locationManager = CLLocationManager()
//    private var currentPlacemark: CLPlacemark?
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        locationManager.delegate = self
//                locationManager.desiredAccuracy = kCLLocationAccuracyBest
//                locationManager.requestWhenInUseAuthorization()
//                locationManager.startUpdatingLocation()
//                
//                // Show user location on the map (blue dot):
//                mapView.showsUserLocation = true
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            guard let location = locations.last else { return }
//            
//            // Center the map on user location
//            let region = MKCoordinateRegion(
//                center: location.coordinate,
//                latitudinalMeters: 500,
//                longitudinalMeters: 500
//            )
//            mapView.setRegion(region, animated: true)
//            
//            // Reverse-geocode to get building name/address
//        let geocoder = CLGeocoder()
//                geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
//                    guard let self = self else { return }
//                    if let error = error {
//                        print("Reverse geocode error: \(error.localizedDescription)")
//                        return
//                    }
//                    if let placemark = placemarks?.first {
//                        self.currentPlacemark = placemark
//                        if let name = placemark.name {
//                            // Auto-fill the buildingBlockTextField
//                            self.buildingBlockTextField.text = name
//                        }
//                    }
//                }
//            }
//        
//        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//            print("Location manager failed with error: \(error.localizedDescription)")
//        }
//    
//    
//    @IBAction func scheduleRequestButtonTapped(_ sender: UIButton) {
//        // 1. Gather address data from text fields
//               let houseFloor = houseFloorTextField.text ?? ""
//               let buildingBlock = buildingBlockTextField.text ?? ""
//               let landmarkArea = landmarkAreaTextField.text ?? ""
//               
//               // 2. Make a dictionary of address info
//               var addressData: [String: Any] = [
//                   "houseFloor": houseFloor,
//                   "buildingBlock": buildingBlock,
//                   "landmarkArea": landmarkArea
//               ]
//               
//               // Optionally include latitude/longitude in the data
//               if let placemark = currentPlacemark,
//                  let coordinate = placemark.location?.coordinate {
//                   addressData["latitude"] = coordinate.latitude
//                   addressData["longitude"] = coordinate.longitude
//               }
//               
//               // 3. Merge this address data with the rest of the booking info & save
//               //    We look up the Schedule_Request VC in the navigation stack:
//               if let navController = self.navigationController {
//                   if let scheduleRequestVC = navController.viewControllers
//                       .first(where: { $0 is Schedule_Request }) as? Schedule_Request {
//                       
//                       scheduleRequestVC.saveScheduleRequest(addressData: addressData) { [weak self] error in
//                           if let error = error {
//                               print("Error scheduling request: \(error)")
//                               self?.showAlert(title: "Error", message: "Could not schedule request.")
//                           } else {
//                               // On success, pop back
//                               self?.navigationController?.popViewController(animated: true)
//                           }
//                       }
//                       return
//                   }
//               }
//               
//               // Option B: If you wanted to write directly to Firestore here,
//               // replicate the same logic from scheduleRequestVC.saveScheduleRequest(...)
//           
//    }
//    
//    private func showAlert(title: String, message: String) {
//            let alert = UIAlertController(title: title,
//                                          message: message,
//                                          preferredStyle: .alert)
//            alert.addAction(.init(title: "OK", style: .default))
//            present(alert, animated: true)
//        }
//    
//    
//    
//    

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//}
import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

// MARK: - Delegate Protocol
protocol AddAddressDelegate: AnyObject {
    func didSubmitAddress(addressData: [String: Any])
}

class Add_Address: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var houseFloorTextField: UITextField!
    @IBOutlet weak var buildingBlockTextField: UITextField!
    @IBOutlet weak var landmarkAreaTextField: UITextField!
    
    // Data passed from Schedule_Request
    var selectedPetName: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isPetPickup: Bool = false
    var isPetDropoff: Bool = false
    var instructions: String = ""
    
    // Delegate to send address data back.
    weak var delegate: AddAddressDelegate?
    
    private let locationManager = CLLocationManager()
    
    // Annotation for marking the map’s center.
    private var centerAnnotation: MKPointAnnotation?
    
    // Optionally store the last reverse‑geocoded placemark.
    private var currentPlacemark: CLPlacemark?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up location manager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set up the map view.
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Add tap gesture recognizer so the user can reposition the marker.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Map Tap Handler
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        updateMarkerAndReverseGeocode(coordinate: coordinate)
        // Optionally center the map on the tapped coordinate.
        mapView.setCenter(coordinate, animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        updateMarkerAndReverseGeocode(coordinate: center)
    }
    
    /// Updates (or creates) the annotation and reverse‑geocodes the given coordinate.
    private func updateMarkerAndReverseGeocode(coordinate: CLLocationCoordinate2D) {
        // Guard against invalid coordinates (NaN values).
        guard !coordinate.latitude.isNaN, !coordinate.longitude.isNaN else {
            print("Invalid coordinate: \(coordinate)")
            return
        }
        
        if let annotation = centerAnnotation {
            annotation.coordinate = coordinate
        } else {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            centerAnnotation = annotation
        }
        
        // Reverse‑geocode to update the building name.
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Reverse geocode error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                self.currentPlacemark = placemark
                let name = placemark.name ?? ""
                DispatchQueue.main.async {
                    self.buildingBlockTextField.text = name
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Center the map on the user's current location.
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation() // Stop updates if not needed continuously.
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
        // Optionally, set a default coordinate if location updates fail.
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)
        let region = MKCoordinateRegion(center: defaultCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - IBAction for the Schedule Request Button
    @IBAction func scheduleRequestButtonTapped(_ sender: UIButton) {
        print("Schedule Request Button Tapped")
        // Validate the map's center coordinate.
        var center = mapView.centerCoordinate
        if center.latitude.isNaN || center.longitude.isNaN {
            if let userCoordinate = mapView.userLocation.location?.coordinate,
               !userCoordinate.latitude.isNaN, !userCoordinate.longitude.isNaN {
                center = userCoordinate
            } else {
                showAlert(title: "Location Error", message: "Could not determine your location. Please try again.")
                return
            }
        }
        
        // Gather address details.
        let houseFloor = houseFloorTextField.text ?? ""
        let buildingBlock = buildingBlockTextField.text ?? ""
        let landmarkArea = landmarkAreaTextField.text ?? ""
        
        let addressDetails: [String: Any] = [
            "houseFloor": houseFloor,
            "buildingBlock": buildingBlock,
            "landmarkArea": landmarkArea,
            "latitude": center.latitude,
            "longitude": center.longitude
        ]
        
        let addressData = ["address": addressDetails]
        print("Submitting address data: \(addressData)")
        
        // Ensure the delegate is set before calling.
        if let delegate = delegate {
            delegate.didSubmitAddress(addressData: addressData)
        } else {
            print("Delegate is nil")
            showAlert(title: "Error", message: "Internal error: delegate not set.")
        }
    }
    
    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
