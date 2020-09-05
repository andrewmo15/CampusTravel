//
//  ViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD

class LoginViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let image: UIImageView = {
        let image = UIImage(named: "LoginIcon")
        let imageView = UIImageView(image: image)
        return imageView
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
    
    private let forgotButton: UIButton = {
        let forgotButton = UIButton()
        forgotButton.setTitle("Forgot password?", for: .normal)
        forgotButton.setTitleColor(.systemBlue, for: .normal)
        forgotButton.layer.masksToBounds = true
        forgotButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        forgotButton.addTarget(self, action: #selector(forgotButtonTapped), for: .touchUpInside)
        return forgotButton
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

    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth()
        email.delegate = self
        password.delegate = self
        links.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        view.addSubview(image)
        view.addSubview(email)
        view.addSubview(password)
        view.addSubview(login)
        view.addSubview(forgotButton)
        view.addSubview(links)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        image.frame = CGRect(x: (view.frame.width / 2) - 50, y: 150, width: 100, height: 100)
        email.frame = CGRect(x: 30, y: 300, width: view.frame.width - 60, height: 52)
        password.frame = CGRect(x: 30, y: 370, width: view.frame.width - 60, height: 52)
        login.frame = CGRect(x: 30, y: 440, width: view.frame.width - 60, height: 52)
        links.frame = CGRect(x: 30, y: 500, width: view.frame.width - 60, height: 50)
        forgotButton.frame = CGRect(x: 30, y: 550, width: view.frame.width - 60, height: 40)
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "container")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
    }
    
    @objc private func forgotButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "forgot")
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case email:
            textField.resignFirstResponder()
            password.becomeFirstResponder()
        case password:
            textField.resignFirstResponder()
            loginTapped()
        default:
            break
        }
        return true
    }
    
    @objc private func loginTapped() {
        email.resignFirstResponder()
        password.resignFirstResponder()
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
                let alert = UIAlertController(title: "Failed to log in!", message: "Check wifi or login credentials", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true)
                return
            }
            var safeEmail = emailer.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            UserDefaults.standard.set(emailer, forKey: "Email")
            UserDefaults.standard.set(safeEmail, forKey: "SafeEmail")
            Database.database().reference().child("Users").child(safeEmail).observe(.value, with: { (snapshot) in
                let mydict = snapshot.value as? NSDictionary
                let name = mydict?["name"] as? String ?? "Failed to Retrieve Name"
                UserDefaults.standard.set(name, forKey: "Name")
                let phone = mydict?["phone_number"] as? String ?? "Failed to Phone Number"
                UserDefaults.standard.set(phone, forKey: "Phone")
            })
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "container")
            vc.modalPresentationStyle = .fullScreen
            strongSelf.present(vc, animated: true)
        })
        
    }
    
    private func alertUser() {
        let alert = UIAlertController(title: "Error", message: "Please enter in all information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

}
