//
//  RegisterViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
       
    private let firstName: UITextField = {
        let firstName = UITextField()
        firstName.textColor = .black
        firstName.autocorrectionType = .no
        firstName.layer.cornerRadius = 12
        firstName.layer.borderWidth = 1
        firstName.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter First Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        firstName.attributedPlaceholder = placeholderText
        firstName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        firstName.leftViewMode = .always
        firstName.backgroundColor = .white
        return firstName
    }()
       
    private let lastName: UITextField = {
        let lastName = UITextField()
        lastName.textColor = .black
        lastName.autocorrectionType = .no
        lastName.layer.cornerRadius = 12
        lastName.layer.borderWidth = 1
        lastName.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter Last Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        lastName.attributedPlaceholder = placeholderText
        lastName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        lastName.leftViewMode = .always
        lastName.backgroundColor = .white
        return lastName
    }()
       
    private let email: UITextField = {
        let email = UITextField()
        email.textColor = .black
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.layer.cornerRadius = 12
        email.layer.borderWidth = 1
        email.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter GT Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        email.attributedPlaceholder = placeholderText
        email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        email.leftViewMode = .always
        email.backgroundColor = .white
        return email
    }()
       
    private let phone: UITextField = {
        let phone = UITextField()
        phone.textColor = .black
        phone.autocapitalizationType = .none
        phone.autocorrectionType = .no
        phone.layer.cornerRadius = 12
        phone.layer.borderWidth = 1
        phone.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter Phone Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        phone.attributedPlaceholder = placeholderText
        phone.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        phone.leftViewMode = .always
        phone.backgroundColor = .white
        return phone
    }()
       
    private let password: UITextField = {
        let password = UITextField()
        password.textColor = .black
        password.autocapitalizationType = .none
        password.autocorrectionType = .no
        password.layer.cornerRadius = 12
        password.layer.borderWidth = 1
        password.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        password.attributedPlaceholder = placeholderText
        password.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        password.leftViewMode = .always
        password.backgroundColor = .white
        password.isSecureTextEntry = true
        return password
    }()
       
    private let signUp: UIButton = {
        let signUp = UIButton()
        signUp.setTitle("Sign Up", for: .normal)
        signUp.setTitleColor(.white, for: .normal)
        signUp.backgroundColor = .link
        signUp.layer.cornerRadius = 12
        signUp.layer.masksToBounds = true
        signUp.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        signUp.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return signUp
    }()
    
    private let error: UILabel = {
        let error = UILabel()
        error.textAlignment = .left
        error.textColor = .red
        error.font = .systemFont(ofSize: 10, weight: .bold)
        error.numberOfLines = 6
        error.minimumScaleFactor = 0.1
        return error
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(firstName)
        view.addSubview(lastName)
        view.addSubview(email)
        view.addSubview(phone)
        view.addSubview(password)
        view.addSubview(signUp)
        view.addSubview(error)
    }
       
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstName.frame = CGRect(x: 30, y: 120, width: view.frame.width - 60, height: 52)
        lastName.frame = CGRect(x: 30, y: 190, width: view.frame.width - 60, height: 52)
        email.frame = CGRect(x: 30, y: 260, width: view.frame.width - 60, height: 52)
        phone.frame = CGRect(x: 30, y: 330, width: view.frame.width - 60, height: 52)
        password.frame = CGRect(x: 30, y: 400, width: view.frame.width - 60, height: 52)
        signUp.frame = CGRect(x: 30, y: 470, width: view.frame.width - 60, height: 52)
        error.frame = CGRect(x: 30, y: 520, width: view.frame.width - 60, height: 104)
    }
    
    @objc private func signUpTapped() {
        guard let first = firstName.text, let last = lastName.text, let emailer = email.text, let phonee = phone.text, let pass = password.text, !first.isEmpty, !last.isEmpty, !phonee.isEmpty, !last.isEmpty, !emailer.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter in all information", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        error.text = " "
        guard checkPassword(password: pass), emailer.contains("@gatech.edu"), checkPhone(with: phonee) else {
            if !checkPassword(password: pass) {
                error.text! += "* Password must have one letter, one number, and 6 letters long\n"
            }
            if !emailer.contains("@gatech.edu") {
                error.text! += "* Must be a valid Georgia tech email\n"
            }
            if !checkPhone(with: phonee) {
                error.text! += "* Phone must comform to style ##########"
            }
            return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().createUser(withEmail: emailer, password: pass, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard authResult != nil, error == nil else {
                let alert = UIAlertController(title: "Error", message: "Failed to sign up", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true)
                return
            }
            var safeEmail = emailer.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            UserDefaults.standard.set(safeEmail, forKey: "SafeEmail")
            UserDefaults.standard.set(emailer, forKey: "Email")
            UserDefaults.standard.set(first + " " + last, forKey: "Name")
            UserDefaults.standard.set(phonee, forKey: "Phone")
            Database.database().reference().child("UIDs").child(FirebaseAuth.Auth.auth().currentUser!.uid).setValue(safeEmail)
            Database.database().reference().child("Users").child(safeEmail).setValue([
                "first_name": first,
                "last_name": last,
                "phone_number": phonee,
            ])
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "container")
            vc.modalPresentationStyle = .fullScreen
            strongSelf.present(vc, animated: true)
        })
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
    
    private func checkPassword(password: String) -> Bool {
        var letter = false
        var number = false
        for character in password {
            if character.isLetter {
                letter = true
            }
            if character.isNumber {
                number = true
            }
        }
        return letter && number && (password.count >= 6)
    }
}
