//
//  EditViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditProfileViewController: UIViewController, UITextFieldDelegate {
       
    private let name: UITextField = {
        let name = UITextField()
        let placeholderText = NSAttributedString(string: UserDefaults.standard.string(forKey: "Name")!, attributes: [NSAttributedString.Key.font: UIFont(name: "PerspectiveSans", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        name.attributedPlaceholder = placeholderText
        name.textColor = .black
        name.autocorrectionType = .no
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.lightGray.cgColor
        name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        name.leftViewMode = .always
        name.backgroundColor = .white
        name.tintColor = .link
        return name
    }()
       
    private let phone: UITextField = {
        let phone = UITextField()
        phone.keyboardType = .phonePad
        let placeholderText = NSAttributedString(string: UserDefaults.standard.string(forKey: "Phone")!, attributes: [NSAttributedString.Key.font: UIFont(name: "PerspectiveSans", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        phone.attributedPlaceholder = placeholderText
        phone.textColor = .black
        phone.autocorrectionType = .no
        phone.layer.borderWidth = 1
        phone.layer.borderColor = UIColor.lightGray.cgColor
        phone.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        phone.leftViewMode = .always
        phone.backgroundColor = .white
        phone.tintColor = .link
        return phone
    }()
    
     private let error: UILabel = {
        let error = UILabel()
        error.textAlignment = .left
        error.textColor = .red
        error.font = UIFont(name: "PerspectiveSans", size: 10)
        error.numberOfLines = 6
        error.minimumScaleFactor = 0.1
        error.backgroundColor = .white
        return error
    }()
    
    private let save: UIButton = {
        let save = UIButton()
        save.setTitle("Save", for: .normal)
        save.setTitleColor(.white, for: .normal)
        save.backgroundColor = .black
        save.layer.masksToBounds = true
        save.titleLabel?.font = UIFont(name: "PerspectiveSans", size: 23)
        save.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return save
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavController()
        view.backgroundColor = .white
        name.delegate = self
        phone.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        view.addSubview(name)
        view.addSubview(phone)
        view.addSubview(error)
        view.addSubview(save)
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        name.frame = CGRect(x: 30, y: 150, width: view.frame.width - 60, height: 52)
        phone.frame = CGRect(x: 30, y: 220, width: view.frame.width - 60, height: 52)
        save.frame = CGRect(x: 30, y: 290, width: view.frame.width - 60, height: 45)
        error.frame = CGRect(x: 30, y: 340, width: view.frame.width - 60, height: 80)
    }
    
    private func configureNavController() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PerspectiveSansBlack", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .black
        navigationController?.navigationBar.standardAppearance = navBarAppearance
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name:
            textField.resignFirstResponder()
            phone.becomeFirstResponder()
        case phone:
            textField.resignFirstResponder()
            saveTapped()
        default:
            break
        }
        return true
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveTapped() {
        name.resignFirstResponder()
        phone.resignFirstResponder()
        let safeEmail = UserDefaults.standard.object(forKey: "SafeEmail") as? String ?? " "
        if name.text != "" {
            Database.database().reference().child("Users").child(safeEmail).child("name").setValue(name.text)
            UserDefaults.standard.set(name.text, forKey: "Name")
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
    
    @objc private func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
