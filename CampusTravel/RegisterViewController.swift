//
//  RegisterViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
       
    private let firstName: UITextField = {
        let firstName = UITextField()
        firstName.autocapitalizationType = .none
        firstName.autocorrectionType = .no
        firstName.returnKeyType = .continue
        firstName.layer.cornerRadius = 12
        firstName.layer.borderWidth = 1
        firstName.layer.borderColor = UIColor.lightGray.cgColor
        firstName.placeholder = "Enter First Name"
        firstName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        firstName.leftViewMode = .always
        firstName.backgroundColor = .white
        return firstName
    }()
       
    private let lastName: UITextField = {
        let lastName = UITextField()
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
       
    private let email: UITextField = {
        let email = UITextField()
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.returnKeyType = .continue
        email.layer.cornerRadius = 12
        email.layer.borderWidth = 1
        email.layer.borderColor = UIColor.lightGray.cgColor
        email.placeholder = "Enter Valid Email"
        email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        email.leftViewMode = .always
        email.backgroundColor = .white
        return email
    }()
       
    private let phone: UITextField = {
        let phone = UITextField()
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
       
    private let password: UITextField = {
        let password = UITextField()
        password.autocapitalizationType = .none
        password.autocorrectionType = .no
        password.returnKeyType = .done
        password.layer.cornerRadius = 12
        password.layer.borderWidth = 1
        password.layer.borderColor = UIColor.lightGray.cgColor
        password.placeholder = "Enter Password"
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Log In"
        view.backgroundColor = .white
        view.addSubview(firstName)
        view.addSubview(lastName)
        view.addSubview(email)
        view.addSubview(phone)
        view.addSubview(password)
        view.addSubview(signUp)
    }
       
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        firstName.frame = CGRect(x: 30, y: 200, width: scrollView.frame.width - 60, height: 52)
        lastName.frame = CGRect(x: 30, y: 260, width: scrollView.frame.width - 60, height: 52)
        email.frame = CGRect(x: 30, y: 320, width: scrollView.frame.width - 60, height: 52)
        phone.frame = CGRect(x: 30, y: 380, width: scrollView.frame.width - 60, height: 52)
        password.frame = CGRect(x: 30, y: 440, width: scrollView.frame.width - 60, height: 52)
        signUp.frame = CGRect(x: 30, y: 500, width: scrollView.frame.width - 60, height: 52)
    }
    
    @objc private func signUpTapped() {
        guard let first = firstName.text, let last = lastName.text, let emailer = email.text, let phonee = phone.text, let pass = password.text, !first.isEmpty, !last.isEmpty, !phonee.isEmpty, !last.isEmpty, !emailer.isEmpty, pass.count >= 6 else {
            alertUser()
            return
        }
        spinner.show(in: view)
        DatabaseManager.shared.userExists(with: emailer, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            guard !exists else {
                strongSelf.alertUser(message: "Email address already exists")
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: emailer, password: pass, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    let alert = UIAlertController(title: "Error", message: "Failed to sign up", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    strongSelf.present(alert, animated: true)
                    return
                }
                UserDefaults.standard.set(emailer, forKey: "Email")
                DatabaseManager.shared.insertUser(with: User(firstName: first, lastName: last, emailAddress: emailer, phoneNumber: phonee))
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "tabbar")
                vc.modalPresentationStyle = .fullScreen
                strongSelf.present(vc, animated: true)
            })
        })
    }
    
    private func alertUser(message: String = "Please enter in all information") {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
