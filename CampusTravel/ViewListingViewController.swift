//
//  ViewListingViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MessageUI

class ViewListingViewController: UIViewController {
    
    let messageComposer = MessageComposer()
    
    var currentListing: Listing?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let destination: UILabel = {
        let destination = UILabel()
        destination.textAlignment = .left
        destination.numberOfLines = 3
        destination.font = .systemFont(ofSize: 20, weight: .bold)
        return destination
    }()
    
    private let time: UILabel = {
        let time = UILabel()
        time.textAlignment = .left
        time.numberOfLines = 2
        time.font = .systemFont(ofSize: 20, weight: .bold)
        return time
    }()
    
    private let meeting: UILabel = {
        let meeting = UILabel()
        meeting.textAlignment = .left
        meeting.numberOfLines = 3
        meeting.font = .systemFont(ofSize: 20, weight: .bold)
        return meeting
    }()
    
    private let acceptedBy: UILabel = {
        let acceptedBy = UILabel()
        acceptedBy.textAlignment = .left
        acceptedBy.numberOfLines = 2
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
    
    private let myView: UIView = {
        let myView = UIView()
        myView.backgroundColor = UIColor.lightGray
        myView.layer.cornerRadius = 5
        return myView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        view.addSubview(myView)
        destination.text = "Destination:\n" + currentListing!.destination
        time.text = "Time/Date:\n" + currentListing!.time
        meeting.text = "Meeting location:\n" + currentListing!.meeting
        let email = currentListing?.email
        let safeEmail = UserDefaults.standard.string(forKey: "SafeEmail")
        if email == safeEmail && currentListing?.accepted == "No one" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteListing))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.systemRed
        } else if (currentListing?.accepted == "No one" && email != safeEmail) {
            view.addSubview(accept)
        } else {
            if email == safeEmail {
                Database.database().reference().child("Users").child(currentListing!.accepted).observe(.value, with: { [weak self] (snapshot) in
                    guard let strongSelf = self else {
                        return
                    }
                    let dict = snapshot.value as? NSDictionary
                    strongSelf.acceptedBy.text = "Accepted by:\n"
                    strongSelf.acceptedBy.text? += dict?["first_name"] as? String ?? "Failed To Retrieve Name"
                    strongSelf.acceptedBy.text? += " "
                    strongSelf.acceptedBy.text? += dict?["last_name"] as? String ?? ""
                })
            } else {
                acceptedBy.text = "Accepted by: You"
            }
            view.addSubview(acceptedBy)
            view.addSubview(contact)
        }
        if email == safeEmail {
            self.title = "You"
        } else {
            Database.database().reference().child("Users").child(currentListing!.email).observe(.value, with: { (snapshot) in
                let dict = snapshot.value as? NSDictionary
                var text = dict?["first_name"] as? String ?? "Failed To Retrieve Name"
                text += " "
                text += dict?["last_name"] as? String ?? ""
                self.title = text
            })
        }
        view.addSubview(destination)
        view.addSubview(time)
        view.addSubview(meeting)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        destination.frame = CGRect(x: 40, y: 150, width: scrollView.frame.width - 60, height: 80)
        time.frame = CGRect(x: 40, y: 230, width: scrollView.frame.width - 60, height: 80)
        meeting.frame = CGRect(x: 40, y: 310, width: scrollView.frame.width - 60, height: 80)
        acceptedBy.frame = CGRect(x: 40, y: 390, width: scrollView.frame.width - 60, height: 80)
        accept.frame = CGRect(x: 40, y: 420, width: scrollView.frame.width - 60, height: 52)
        contact.frame = CGRect(x: 40, y: 500, width: scrollView.frame.width - 60, height: 52)
        myView.frame = CGRect(x: 20, y: 140, width: scrollView.frame.width - 30, height: 350)
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
        if messageComposer.canSendText() {
            let email = currentListing?.email
            let safeEmail = UserDefaults.standard.string(forKey: "SafeEmail")
            if safeEmail == email {
                Database.database().reference().child("Users").child(currentListing!.accepted).observe(.value, with: { [weak self] (snapshot) in
                    guard let strongSelf = self else {
                        return
                    }
                    let mydict = snapshot.value as? NSDictionary
                    let contact = mydict?["phone_number"] as? String ?? "Error, cannot get phone number"
                    let messageComposeVC = strongSelf.messageComposer.configuredMessageComposeViewController(person: contact)
                    strongSelf.present(messageComposeVC, animated: true, completion: nil)
                })
            } else {
                Database.database().reference().child("Users").child(currentListing!.email).observe(.value, with: { [weak self] (snapshot) in
                    guard let strongSelf = self else {
                        return
                    }
                    let mydict = snapshot.value as? NSDictionary
                    let contact = mydict?["phone_number"] as? String ?? "Error, cannot get phone number"
                    let messageComposeVC = strongSelf.messageComposer.configuredMessageComposeViewController(person: contact)
                    strongSelf.present(messageComposeVC, animated: true, completion: nil)
                })
            }
        } else {
            let alert = UIAlertController(title: "Error!", message: "Cannot open iMessage!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
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
