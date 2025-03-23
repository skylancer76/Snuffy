//
//  Vaccinations_Details.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 23/03/25.
//
//
//import UIKit
//import FirebaseFirestore
//
//class Vaccinations_Details: UIViewController {
//    
//    // MARK: - Properties
//    var petId: String?
//    private var collectionView: UICollectionView!
//    var vaccinationDetails: [VaccinationDetails] = []
//    let db = Firestore.firestore()
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("Pet ID in Vaccinations_Details: \(petId ?? "nil")")
//        setupNavigationBar()
//        setupGradientBackground()
//        setupCollectionView()
//        
//        if let petId = petId {
//            fetchVaccinationData(petId: petId)
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if let petId = petId {
//            fetchVaccinationData(petId: petId)
//        }
//    }
//    
//    // MARK: - Setup Methods
//    private func setupNavigationBar() {
//        title = "Vaccinations Details"
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
//                                        target: self,
//                                        action: #selector(addVaccinationTapped))
//        navigationItem.rightBarButtonItem = addButton
//    }
//    
//    private func setupGradientBackground() {
//        let gradientView = UIView(frame: view.bounds)
//        gradientView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(gradientView)
//        view.sendSubviewToBack(gradientView)
//        NSLayoutConstraint.activate([
//            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
//            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = view.bounds
//        gradientLayer.colors = [
//            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
//            UIColor.clear.cgColor
//        ]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
//        gradientView.layer.insertSublayer(gradientLayer, at: 0)
//    }
//    
//    private func setupCollectionView() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 16
//        layout.itemSize = CGSize(width: 300, height: 250)
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .clear
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.isPagingEnabled = false
//        collectionView.register(VaccinationCollectionViewCell.self,
//                                forCellWithReuseIdentifier: VaccinationCollectionViewCell.reuseIdentifier)
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        view.addSubview(collectionView)
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
//            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//    
//    // MARK: - Data Fetching
//    func fetchVaccinationData(petId: String) {
//        let collectionRef = db.collection("Pets").document(petId).collection("Vaccinations")
//        collectionRef.getDocuments { snapshot, error in
//            if let error = error {
//                print("❌ Error fetching vaccination data: \(error.localizedDescription)")
//                return
//            }
//            guard let documents = snapshot?.documents else {
//                print("❌ No vaccination documents found.")
//                return
//            }
//            self.vaccinationDetails.removeAll()
//            for doc in documents {
//                let data = doc.data()
//                let vaccineName = data["vaccineName"] as? String ?? ""
//                let vaccineType = data["vaccineType"] as? String ?? ""
//                let dateOfVaccination = data["dateOfVaccination"] as? String ?? ""
//                let expiryDate = data["expiryDate"] as? String ?? ""
//                let nextDueDate = data["nextDueDate"] as? String ?? ""
//                let vaccination = VaccinationDetails(
//                    vaccineId: doc.documentID,
//                    vaccineName: vaccineName,
//                    vaccineType: vaccineType,
//                    dateOfVaccination: dateOfVaccination,
//                    expiryDate: expiryDate,
//                    nextDueDate: nextDueDate
//                )
//                self.vaccinationDetails.append(vaccination)
//            }
//            print("✅ Fetched \(self.vaccinationDetails.count) vaccination(s).")
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        }
//    }
//    
//    // MARK: - Navigation
//    @objc func addVaccinationTapped() {
//        print("➕ Add Vaccination Tapped")
//        guard let petId = petId else {
//            print("❌ petId is nil, cannot show Add_Vaccination.")
//            return
//        }
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        if let addVaccinationVC = mainStoryboard.instantiateViewController(withIdentifier: "AddVaccinationVC") as? Add_Vaccination {
//            addVaccinationVC.petId = petId
//            navigationController?.pushViewController(addVaccinationVC, animated: true)
//        } else {
//            print("❌ Could not instantiate Add_Vaccination. Check Storyboard ID 'AddVaccinationVC'.")
//        }
//    }
//    
//    // MARK: - Deletion
//    @objc func deleteVaccination(at index: Int) {
//        let vaccination = vaccinationDetails[index]
//        guard let petId = petId,
//              let vaccineId = vaccination.vaccineId else { return }
//        db.collection("Pets").document(petId).collection("Vaccinations").document(vaccineId).delete { error in
//            if let error = error {
//                print("❌ Error deleting document: \(error.localizedDescription)")
//            } else {
//                print("✅ Document deleted.")
//                self.vaccinationDetails.remove(at: index)
//                DispatchQueue.main.async {
//                    self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//extension Vaccinations_Details: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return vaccinationDetails.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: VaccinationCollectionViewCell.reuseIdentifier,
//                for: indexPath) as? VaccinationCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        let vaccination = vaccinationDetails[indexPath.item]
//        cell.configure(with: vaccination)
//        cell.onDeleteButtonTapped = { [weak self] in
//            self?.deleteVaccination(at: indexPath.item)
//        }
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // Optionally handle selection.
//    }
//}
import UIKit
import FirebaseFirestore

class Vaccinations_Details: UIViewController {

    var petId: String?

    private var collectionView: UICollectionView!
    private var vaccinationDetails: [VaccinationDetails] = []
    private var petImageURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Vaccinations Details"
        view.backgroundColor = .white

        setupTopGradient()
        setupCollectionView()
        setupNavigationBar()

        if let petId = petId {
            fetchVaccinationData(petId: petId)
            fetchPetImageURL(petId: petId)
        }
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVaccinationTapped))
    }

    private func setupTopGradient() {
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.systemPink.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(
            width: UIScreen.main.bounds.width * 0.88,
            height: UIScreen.main.bounds.height * 0.55 // 55% height
        )

        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)



        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast

        collectionView.register(VaccinationCollectionViewCell.self, forCellWithReuseIdentifier: VaccinationCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func fetchVaccinationData(petId: String) {
        let db = Firestore.firestore()
        db.collection("Pets").document(petId).collection("Vaccinations").getDocuments { snapshot, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            self.vaccinationDetails = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                return VaccinationDetails(
                    vaccineId: doc.documentID,
                    vaccineName: data["vaccineName"] as? String ?? "",
                    vaccineType: data["vaccineType"] as? String ?? "",
                    dateOfVaccination: data["dateOfVaccination"] as? String ?? "",
                    expiryDate: data["expiryDate"] as? String ?? "",
                    nextDueDate: data["nextDueDate"] as? String ?? ""
                )
            } ?? []

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    private func fetchPetImageURL(petId: String) {
        let db = Firestore.firestore()
        db.collection("Pets").document(petId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let url = data["petImage"] as? String {
                self.petImageURL = url
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }

    @objc private func addVaccinationTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddVaccinationVC") as? Add_Vaccination {
            vc.petId = petId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - CollectionView DataSource
extension Vaccinations_Details: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vaccinationDetails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VaccinationCollectionViewCell.reuseIdentifier, for: indexPath) as! VaccinationCollectionViewCell
        let item = vaccinationDetails[indexPath.item]
        cell.configure(with: item, petImageURL: petImageURL)
        return cell
    }
}
