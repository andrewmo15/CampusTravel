//
//  ViewListingViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewListingViewController: UIViewController {
    
    var currentListing: Listing?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let destination: UILabel = {
        let phone = UILabel()
        phone.textAlignment = .center
        phone.font = .systemFont(ofSize: 20, weight: .bold)
        return phone
       }()
    
    private let time: UILabel = {
        let time = UILabel()
        time.textAlignment = .center
        time.font = .systemFont(ofSize: 20, weight: .bold)
        return time
    }()
    
    private let meeting: UILabel = {
        let meeting = UILabel()
        meeting.textAlignment = .center
        meeting.font = .systemFont(ofSize: 20, weight: .bold)
        return meeting
    }()
    
    private let phone: UILabel = {
        let phone = UILabel()
        phone.textAlignment = .center
        phone.font = .systemFont(ofSize: 20, weight: .bold)
        return phone
    }()
    
    private let accept: UIButton = {
        let accept = UIButton()
        accept.setTitle("Accept", for: .normal)
        accept.setTitleColor(.white, for: .normal)
        accept.backgroundColor = .link
        accept.layer.cornerRadius = 12
        accept.layer.masksToBounds = true
        accept.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        accept.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        return accept
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        destination.text = currentListing?.destination
        time.text = currentListing?.time
        meeting.text = currentListing?.meeting
        Database.database().reference().child("Users").child(currentListing!.email).observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            self.phone.text = dict?["phone_number"] as? String ?? "Failed To Retrieve Phone Number"
        })
        Database.database().reference().child("Users").child(currentListing!.email).observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            var text = dict?["first_name"] as? String ?? "Failed To Retrieve Name"
            text += " "
            text += dict?["last_name"] as? String ?? ""
            self.title = text
        })
        Database.database().reference().child("Listings").child(currentListing!.listingID).observe(.value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            let dict = snapshot.value as? NSDictionary
            let email = dict?["email"] as? String ?? "Error"
            let safeEmail = UserDefaults.standard.string(forKey: "SafeEmail")
            if email == safeEmail {
                strongSelf.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: strongSelf, action: #selector(strongSelf.deleteListing))
                strongSelf.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
            } else {
                strongSelf.view.addSubview(strongSelf.accept)
            }
        })
        
        view.addSubview(scrollView)
        view.addSubview(destination)
        view.addSubview(time)
        view.addSubview(meeting)
        view.addSubview(phone)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        destination.frame = CGRect(x: 30, y: 200, width: scrollView.frame.width - 60, height: 52)
        time.frame = CGRect(x: 30, y: 260, width: scrollView.frame.width - 60, height: 52)
        meeting.frame = CGRect(x: 30, y: 320, width: scrollView.frame.width - 60, height: 52)
        phone.frame = CGRect(x: 30, y: 380, width: scrollView.frame.width - 60, height: 52)
        accept.frame = CGRect(x: 30, y: 440, width: scrollView.frame.width - 60, height: 52)
    }
    
    @objc func acceptTapped() {
        let safeEmail = UserDefaults.standard.string(forKey: "SafeEmail")
        Database.database().reference().child("Listings").child(currentListing!.listingID).child("acceptedBy").setValue(safeEmail)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteListing() {
        let confirm = UIAlertController(title: "Are You Sure?", message: "Do you want to delete?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            Database.database().reference().child("Listings").child(strongSelf.currentListing!.listingID).removeValue()
            strongSelf.navigationController?.popViewController(animated: true)
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        confirm.addAction(yes)
        confirm.addAction(no)
        present(confirm, animated: true, completion: nil)
    }
}
