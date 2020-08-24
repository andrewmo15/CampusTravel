//
//  ProfileViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let name: UILabel = {
        let name = UILabel()
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? " "
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        Database.database().reference().child(safeEmail).observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            name.text = dict?["first_name"] as? String ?? "Failed To Retrieve Name"
            name.text? += " "
            name.text? += dict?["last_name"] as? String ?? ""
        })
        name.textAlignment = .center
        name.font = .systemFont(ofSize: 30, weight: .bold)
        return name
    }()
    
    private let phone: UILabel = {
        let phone = UILabel()
        let email = UserDefaults.standard.object(forKey: "Email") as? String ?? " "
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        Database.database().reference().child(safeEmail).observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            phone.text = dict?["phone_number"] as? String ?? "Failed To Retrieve Phone"
        })
        phone.textAlignment = .center
        phone.font = .systemFont(ofSize: 30, weight: .bold)
        return phone
       }()
    
    private let email: UILabel = {
        let email = UILabel()
        email.text = UserDefaults.standard.object(forKey: "Email") as? String ?? " "
        email.textAlignment = .center
        email.font = .systemFont(ofSize: 30, weight: .bold)
        return email
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        view.addSubview(name)
        view.addSubview(email)
        view.addSubview(phone)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        name.frame = CGRect(x: 30, y: 200, width: scrollView.frame.width - 60, height: 100)
        email.frame = CGRect(x: 30, y: 320, width: scrollView.frame.width - 60, height: 100)
        phone.frame = CGRect(x: 30, y: 440, width: scrollView.frame.width - 60, height: 100)
    }
    
    @IBAction func signOut(_ sender: Any) {
        let confirm = UIAlertController(title: "Are You Sure?", message: "Do you want to sign out?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            do {
                try FirebaseAuth.Auth.auth().signOut()
                strongSelf.dismiss(animated: true, completion: nil)
            } catch {
                let alert = UIAlertController(title: "Error", message: "Failed to log in", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true)
            }
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        confirm.addAction(yes)
        confirm.addAction(no)
        present(confirm, animated: true, completion: nil)
    }
    
}
