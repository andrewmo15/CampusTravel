//
//  EditViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditProfileViewController: UIViewController {
       
    private let firstName: UITextField = {
        let firstName = UITextField()
        let fullName = UserDefaults.standard.string(forKey: "Name")!
        let placeholderText = NSAttributedString(string: String(fullName.split(separator: " ")[0]), attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        firstName.attributedPlaceholder = placeholderText
        firstName.textColor = .black
        firstName.autocorrectionType = .no
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
        let fullName = UserDefaults.standard.string(forKey: "Name")!
        let placeholderText = NSAttributedString(string: String(fullName.split(separator: " ")[1]), attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        lastName.attributedPlaceholder = placeholderText
        lastName.textColor = .black
        lastName.autocorrectionType = .no
        lastName.layer.cornerRadius = 12
        lastName.layer.borderWidth = 1
        lastName.layer.borderColor = UIColor.lightGray.cgColor
        lastName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        lastName.leftViewMode = .always
        lastName.backgroundColor = .white
        return lastName
    }()
       
    private let phone: UITextField = {
        let phone = UITextField()
        let placeholderText = NSAttributedString(string: UserDefaults.standard.string(forKey: "Phone")!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        phone.attributedPlaceholder = placeholderText
        phone.textColor = .black
        phone.autocorrectionType = .no
        phone.layer.cornerRadius = 12
        phone.layer.borderWidth = 1
        phone.layer.borderColor = UIColor.lightGray.cgColor
        phone.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        phone.leftViewMode = .always
        phone.backgroundColor = .white
        return phone
    }()
    
    private let error: UILabel = {
        let error = UILabel()
        error.textAlignment = .left
        error.textColor = .red
        error.font = .systemFont(ofSize: 15, weight: .bold)
        error.numberOfLines = 2
        error.minimumScaleFactor = 0.1
        return error
    }()
    
    private let save: UIButton = {
        let save = UIButton()
        save.setTitle("Save", for: .normal)
        save.setTitleColor(.white, for: .normal)
        save.backgroundColor = .link
        save.layer.cornerRadius = 12
        save.layer.masksToBounds = true
        save.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        save.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return save
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(firstName)
        view.addSubview(lastName)
        view.addSubview(phone)
        view.addSubview(error)
        view.addSubview(save)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstName.frame = CGRect(x: 30, y: 150, width: view.frame.width - 60, height: 52)
        lastName.frame = CGRect(x: 30, y: 210, width: view.frame.width - 60, height: 52)
        phone.frame = CGRect(x: 30, y: 270, width: view.frame.width - 60, height: 52)
        save.frame = CGRect(x: 30, y: 330, width: view.frame.width - 60, height: 52)
        error.frame = CGRect(x: 30, y: 390, width: view.frame.width - 60, height: 80)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveTapped() {
        let safeEmail = UserDefaults.standard.object(forKey: "SafeEmail") as? String ?? " "
        if firstName.text != "" {
            Database.database().reference().child("Users").child(safeEmail).child("first_name").setValue(firstName.text)
            let last = String(UserDefaults.standard.string(forKey: "Name")!.split(separator: " ")[1])
            UserDefaults.standard.set(firstName.text! + " " + last, forKey: "Name")
        }
        if lastName.text != "" {
            Database.database().reference().child("Users").child(safeEmail).child("last_name").setValue(lastName.text)
            let first = String(UserDefaults.standard.string(forKey: "Name")!.split(separator: " ")[0])
            UserDefaults.standard.set(first + " " + lastName.text!, forKey: "Name")
        }
        error.text = " "
        if phone.text != "" {
            guard checkPhone(with: phone.text!) else {
                error.text! += "* Phone number must comform to style ##########"
                return
            }
            Database.database().reference().child("Users").child(safeEmail).child("phone_number").setValue(phone.text)
            UserDefaults.standard.set(phone.text, forKey: "Phone")
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func checkPhone(with: String) -> Bool {
        var onlyNum = true
        for character in with {
            if !character.isNumber {
                onlyNum = false
            }
        }
        return onlyNum && with.count == 10
    }
}
