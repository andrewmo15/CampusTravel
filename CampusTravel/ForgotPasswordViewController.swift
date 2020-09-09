//
//  ForgotPasswordViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/28/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let email: UITextField = {
        let email = UITextField()
        email.textColor = .black
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.layer.borderWidth = 1
        email.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Enter GT Email", attributes: [NSAttributedString.Key.font: UIFont(name: "PerspectiveSans", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        email.attributedPlaceholder = placeholderText
        email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        email.leftViewMode = .always
        email.backgroundColor = .white
        email.tintColor = .link
        return email
    }()
    
    private let reset: UIButton = {
        let reset = UIButton()
        reset.setTitle("Reset Password", for: .normal)
        reset.setTitleColor(.white, for: .normal)
        reset.backgroundColor = .black
        reset.layer.masksToBounds = true
        reset.titleLabel?.font = UIFont(name: "PerspectiveSans", size: 23)
        reset.addTarget(self, action: #selector(resetPasswordTapped), for: .touchUpInside)
        return reset
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavController()
        self.title = "Forgot Password"
        email.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        view.addSubview(email)
        view.addSubview(reset)
    }
    
    private func configureNavController() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PerspectiveSansBlack", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .black
        navigationController?.navigationBar.standardAppearance = navBarAppearance
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        email.frame = CGRect(x: 30, y: 150, width: view.frame.width - 60, height: 52)
        reset.frame = CGRect(x: 30, y: 220, width: view.frame.width - 60, height: 45)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resetPasswordTapped()
        return true
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func resetPasswordTapped() {
        email.resignFirstResponder()
        guard let emailAddress = email.text, email.text != "" else {
            let alert = UIAlertController(title: "Error!", message: "Please enter in your email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        guard emailAddress.contains("@gatech.edu") else {
            let alert = UIAlertController(title: "Error!", message: "Please a valid GT email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        spinner.show(in: view)
        resetPassword(email: emailAddress, onSuccess: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let alert = UIAlertController(title: "Success!", message: "An email has been sent to you", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .cancel) { action in
                strongSelf.dismiss(animated: true, completion: nil)
            }
            alert.addAction(dismiss)
            strongSelf.present(alert, animated: true)
        }, onError: { (errorMessage) in
            let alert = UIAlertController(title: "Failed to Send Email!", message: "Make sure this is your email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        })
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
    }
    
    private func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    @objc private func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

}
