//
//  Caretaker Profile.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 05/02/25.
//

import UIKit

class Caretaker_Profile: UIViewController {
    
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.backgroundColor = .clear
        segmentedControl.selectedSegmentTintColor = .systemPurple
        
        let normalTextAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)]
        
        
        let selectedTextAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 15, weight: .bold)]
        
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
   
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
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
