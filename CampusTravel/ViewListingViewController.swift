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
    
    private let acceptedBy: UILabel = {
        let acceptedBy = UILabel()
        acceptedBy.textAlignment = .center
        acceptedBy.font = .systemFont(ofSize: 20, weight: .bold)
        return acceptedBy
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
    
    private let contact: UIButton = {
        let contact = UIButton()
        contact.setTitle("Contact", for: .normal)
        contact.setTitleColor(.white, for: .normal)
        contact.backgroundColor = .link
        contact.layer.cornerRadius = 12
        contact.layer.masksToBounds = true
        contact.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        contact.addTarget(self, action: #selector(contactTapped), for: .touchUpInside)
        return contact
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        destination.text = currentListing?.destination
        time.text = currentListing?.time
        meeting.text = currentListing?.meeting
        let email = currentListing?.email
        let safeEmail = UserDefaults.standard.string(forKey: "SafeEmail")
        if email == safeEmail && currentListing?.accepted == "No one" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteListing))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        } else if (currentListing?.accepted == "No one" && email != safeEmail) {
            view.addSubview(accept)
        } else {
            if email == safeEmail {
                Database.database().reference().child("Users").child(currentListing!.accepted).observe(.value, with: { [weak self] (snapshot) in
                    guard let strongSelf = self else {
                        return
                    }
                    let dict = snapshot.value as? NSDictionary
                    strongSelf.acceptedBy.text = "Accepted by: "
                    strongSelf.acceptedBy.text? += dict?["first_name"] as? String ?? "Failed To Retrieve Name"
                    strongSelf.acceptedBy.text? += " "
                    strongSelf.acceptedBy.text? += dict?["last_name"] as? String ?? ""
                })
                view.addSubview(acceptedBy)
            }
            view.addSubview(contact)
        }
        Database.database().reference().child("Users").child(currentListing!.email).observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            var text = dict?["first_name"] as? String ?? "Failed To Retrieve Name"
            text += " "
            text += dict?["last_name"] as? String ?? ""
            self.title = text
        })
        view.addSubview(destination)
        view.addSubview(time)
        view.addSubview(meeting)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        destination.frame = CGRect(x: 30, y: 200, width: scrollView.frame.width - 60, height: 52)
        time.frame = CGRect(x: 30, y: 260, width: scrollView.frame.width - 60, height: 52)
        meeting.frame = CGRect(x: 30, y: 320, width: scrollView.frame.width - 60, height: 52)
        acceptedBy.frame = CGRect(x: 30, y: 380, width: scrollView.frame.width - 60, height: 52)
        contact.frame = CGRect(x: 30, y: 440, width: scrollView.frame.width - 60, height: 52)
        accept.frame = CGRect(x: 30, y: 440, width: scrollView.frame.width - 60, height: 52)
    }
    
    @objc func acceptTapped() {
        let confirm = UIAlertController(title: "Are You Sure?", message: "This action cannot be undone", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            let safeEmail = UserDefaults.standard.string(forKey: "SafeEmail")
            Database.database().reference().child("Accepted").child(strongSelf.currentListing!.listingID).setValue([
                "acceptedBy": safeEmail,
                "destination": strongSelf.currentListing?.destination,
                "email": strongSelf.currentListing?.email,
                "meeting_location": strongSelf.currentListing?.meeting,
                "time_date": strongSelf.currentListing?.time
            ])
            Database.database().reference().child("Listings").child(strongSelf.currentListing!.listingID).removeValue()
            strongSelf.navigationController?.popViewController(animated: true)
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        confirm.addAction(yes)
        confirm.addAction(no)
        present(confirm, animated: true, completion: nil)
    }
    
    @objc func contactTapped() {
        print("yes")
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
