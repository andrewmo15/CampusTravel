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

class RegisterViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
       
    private let name: UITextField = {
        let name = UITextField()
        name.textColor = .black
        name.autocorrectionType = .no
        name.layer.cornerRadius = 12
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        name.attributedPlaceholder = placeholderText
        name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        name.leftViewMode = .always
        name.backgroundColor = .white
        return name
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
    
    private let links: UITextView = {
        let links = UITextView()
        let text = "By continuing, you agree to our Terms and Conditions and Privacy Policy"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.link, value: "https://github.com/andrewmo15/GTTravel", range: NSRange(location: 32, length: 20))
        attributedString.addAttribute(.link, value: "https://github.com/andrewmo15/GTTravel", range: NSRange(location: 57, length: text.count - 57))
        links.attributedText = attributedString
        links.textColor = UIColor.lightGray
        return links
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
        name.delegate = self
        email.delegate = self
        phone.delegate = self
        password.delegate = self
        links.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        view.addSubview(name)
        view.addSubview(email)
        view.addSubview(phone)
        view.addSubview(password)
        view.addSubview(signUp)
        view.addSubview(links)
        view.addSubview(error)
    }
       
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        name.frame = CGRect(x: 30, y: 120, width: view.frame.width - 60, height: 52)
        email.frame = CGRect(x: 30, y: 190, width: view.frame.width - 60, height: 52)
        phone.frame = CGRect(x: 30, y: 260, width: view.frame.width - 60, height: 52)
        password.frame = CGRect(x: 30, y: 330, width: view.frame.width - 60, height: 52)
        signUp.frame = CGRect(x: 30, y: 400, width: view.frame.width - 60, height: 52)
        links.frame = CGRect(x: 30, y: 460, width: view.frame.width - 60, height: 50)
        error.frame = CGRect(x: 30, y: 510, width: view.frame.width - 60, height: 70)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name:
            textField.resignFirstResponder()
            email.becomeFirstResponder()
        case email:
            textField.resignFirstResponder()
            phone.becomeFirstResponder()
        case phone:
            textField.resignFirstResponder()
            password.becomeFirstResponder()
        case password:
            textField.resignFirstResponder()
            signUpTapped()
        default:
            break
        }
        return true
    }
    
    @objc private func signUpTapped() {
        name.resignFirstResponder()
        email.resignFirstResponder()
        phone.resignFirstResponder()
        password.resignFirstResponder()
        guard let myname = name.text, let emailer = email.text, let phonee = phone.text, let pass = password.text, !myname.isEmpty, !phonee.isEmpty, !emailer.isEmpty, !pass.isEmpty else {
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
                let alert = UIAlertController(title: "Failed to sign up!", message: "Check your wifi again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true)
                return
            }
            var safeEmail = emailer.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            UserDefaults.standard.set(safeEmail, forKey: "SafeEmail")
            UserDefaults.standard.set(emailer, forKey: "Email")
            UserDefaults.standard.set(myname, forKey: "Name")
            UserDefaults.standard.set(phonee, forKey: "Phone")
            UserDefaults.standard.set(1, forKey: "HowTo")
            Database.database().reference().child("UIDs").child(FirebaseAuth.Auth.auth().currentUser!.uid).setValue(safeEmail)
            Database.database().reference().child("Users").child(safeEmail).setValue([
                "name": myname,
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
    
    @objc private func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
