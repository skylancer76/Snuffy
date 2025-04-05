//
//  Pet Particular Medication.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 05/04/25.
//

import UIKit

class Pet_Particular_Medication: UITableViewController {
    
    var petId: String?
    var selectedMedication: PetMedicationDetails?
    
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var medicineTypeLabel: UILabel!
    @IBOutlet weak var purposeConditionLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if let medication = selectedMedication {
            medicineNameLabel.text = medication.medicineName
            medicineTypeLabel.text = medication.medicineType
            purposeConditionLabel.text = medication.purpose
            frequencyLabel.text = medication.frequency
            dosageLabel.text = medication.dosage
            startDateLabel.text = medication.startDate
            endDateLabel.text = medication.endDate
        }
    }


}
