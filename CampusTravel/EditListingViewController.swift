//
//  EditListingViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/24/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditListingViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
       
    private let firstName: UITextField = {
        let firstName = UITextField()
        
        let safeEmail = UserDefaults.standard.object(forKey: "SafeEmail") as? String ?? " "
        Database.database().reference().child("Users").child(safeEmail).observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            firstName.placeholder = dict?["first_name"] as? String ?? "Enter First Name"
        })
        
        firstName.autocapitalizationType = .none
        firstName.autocorrectionType = .no
        firstName.returnKeyType = .continue
        firstName.layer.cornerRadius = 12
        firstName.layer.borderWidth = 1
        firstName.layer.borderColor = UIColor.lightGray.cgColor
        firstName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        firstName.leftViewMode = .always
        firstName.backgroundColor = .white
        return firstName
    }()
       
    private let lastName: UITextField = {
        let lastName = UITextField()
        
        let safeEmail = UserDefaults.standard.object(forKey: "SafeEmail") as? String ?? " "
        Database.database().reference().child("Users").child(safeEmail).observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            lastName.placeholder = dict?["last_name"] as? String ?? "Enter Last Name"
        })
        
        lastName.autocapitalizationType = .none
        lastName.autocorrectionType = .no
        lastName.returnKeyType = .continue
        lastName.layer.cornerRadius = 12
        lastName.layer.borderWidth = 1
        lastName.layer.borderColor = UIColor.lightGray.cgColor
        lastName.placeholder = "Enter Last Name"
        lastName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        lastName.leftViewMode = .always
        lastName.backgroundColor = .white
        return lastName
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        // Do any additional setup after loading the view.
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        self.dismiss(animated: true, completion: nil)
    }

}
