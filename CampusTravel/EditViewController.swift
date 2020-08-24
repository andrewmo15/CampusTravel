//
//  EditViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
       
    private let firstName: UITextField = {
        let firstName = UITextField()
        
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? " "
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
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
        
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? " "
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
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
       
    private let phone: UITextField = {
        let phone = UITextField()
        
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? " "
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        Database.database().reference().child("Users").child(safeEmail).observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            phone.placeholder = dict?["phone_number"] as? String ?? "Enter Phone Number"
        })
        
        phone.autocapitalizationType = .none
        phone.autocorrectionType = .no
        phone.returnKeyType = .continue
        phone.layer.cornerRadius = 12
        phone.layer.borderWidth = 1
        phone.layer.borderColor = UIColor.lightGray.cgColor
        phone.placeholder = "Enter Phone Number"
        phone.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        phone.leftViewMode = .always
        phone.backgroundColor = .white
        return phone
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(firstName)
        view.addSubview(lastName)
        view.addSubview(phone)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        firstName.frame = CGRect(x: 30, y: 200, width: scrollView.frame.width - 60, height: 52)
        lastName.frame = CGRect(x: 30, y: 260, width: scrollView.frame.width - 60, height: 52)
        phone.frame = CGRect(x: 30, y: 320, width: scrollView.frame.width - 60, height: 52)
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? " "
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        if firstName.text != "" {
            Database.database().reference().child("Users").child(safeEmail).child("first_name").setValue(firstName.text)
        }
        if lastName.text != "" {
            Database.database().reference().child("Users").child(safeEmail).child("last_name").setValue(lastName.text)
        }
        if phone.text != "" {
            Database.database().reference().child("Users").child(safeEmail).child("phone_number").setValue(phone.text)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
