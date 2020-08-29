//
//  ForgotPasswordViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/28/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
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
    
    private let reset: UIButton = {
        let reset = UIButton()
        reset.setTitle("Reset Password", for: .normal)
        reset.setTitleColor(.white, for: .normal)
        reset.backgroundColor = .link
        reset.layer.cornerRadius = 12
        reset.layer.masksToBounds = true
        reset.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        reset.addTarget(self, action: #selector(resetPasswordTapped), for: .touchUpInside)
        return reset
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(email)
        view.addSubview(reset)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        email.frame = CGRect(x: 30, y: 150, width: view.frame.width - 60, height: 52)
        reset.frame = CGRect(x: 30, y: 220, width: view.frame.width - 60, height: 52)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func resetPasswordTapped() {
        guard let emailAddress = email.text, email.text != "" else {
            let alert = UIAlertController(title: "Whoops!", message: "Please enter your email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        guard emailAddress.contains("@gatech.edu") else {
            let alert = UIAlertController(title: "Whoops!", message: "Please a valid GT email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        resetPassword(email: emailAddress, onSuccess: {
            let alert = UIAlertController(title: "Success!", message: "An email has been sent to you", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }, onError: { (errorMessage) in
            let alert = UIAlertController(title: "Error!", message: "Failed to send email...", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        })
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

}
