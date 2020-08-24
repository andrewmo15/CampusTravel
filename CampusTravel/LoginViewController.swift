//
//  ViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
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
    
    private let login: UIButton = {
        let login = UIButton()
        login.setTitle("Log In", for: .normal)
        login.setTitleColor(.white, for: .normal)
        login.backgroundColor = .link
        login.layer.cornerRadius = 12
        login.layer.masksToBounds = true
        login.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        login.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return login
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(email)
        view.addSubview(password)
        view.addSubview(login)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        email.frame = CGRect(x: 30, y: 200, width: scrollView.frame.width - 60, height: 52)
        password.frame = CGRect(x: 30, y: 260, width: scrollView.frame.width - 60, height: 52)
        login.frame = CGRect(x: 30, y: 320, width: scrollView.frame.width - 60, height: 52)
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "tabbar")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    @objc private func loginTapped() {
        guard let emailer = email.text, let pass = password.text, !emailer.isEmpty, !pass.isEmpty else {
            alertUser()
            return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: emailer, password: pass, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard authResult != nil, error == nil else {
                let alert = UIAlertController(title: "Error", message: "Failed to log in", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true)
                return
            }
            UserDefaults.standard.set(emailer, forKey: "Email")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "tabbar")
            vc.modalPresentationStyle = .fullScreen
            strongSelf.present(vc, animated: true)
        })
        
    }
    
    private func alertUser() {
        let alert = UIAlertController(title: "Error", message: "Please enter in all information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}

