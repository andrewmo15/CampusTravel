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
    @IBOutlet weak var table: UITableView!
    var currentListing: Listing?
    var listing = [String]()
    
    private let acceptedBy: UILabel = {
        let acceptedBy = UILabel()
        acceptedBy.font = UIFont(name: "PerspectiveSansBlack", size: 20)
        acceptedBy.textAlignment = .center
        acceptedBy.textColor = UIColor(red: 42 / 255.0, green: 168 / 255.0, blue: 242 / 255.0, alpha: 1)
        acceptedBy.numberOfLines = 2
        return acceptedBy
    }()
    
    private let accept: UIButton = {
        let accept = UIButton()
        accept.setTitle("Accept", for: .normal)
        accept.setTitleColor(.white, for: .normal)
        accept.backgroundColor = UIColor(red: 42 / 255.0, green: 168 / 255.0, blue: 242 / 255.0, alpha: 1)
        accept.layer.cornerRadius = 12
        accept.layer.masksToBounds = true
        accept.titleLabel?.font = UIFont(name: "PerspectiveSansBlack", size: 20)
        accept.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        return accept
    }()
    
    private let contact: UIButton = {
        let contact = UIButton()
        contact.setTitle("Contact", for: .normal)
        contact.setTitleColor(.white, for: .normal)
        contact.backgroundColor = UIColor(red: 42 / 255.0, green: 168 / 255.0, blue: 242 / 255.0, alpha: 1)
        contact.layer.cornerRadius = 12
        contact.layer.masksToBounds = true
        contact.titleLabel?.font = UIFont(name: "PerspectiveSansBlack", size: 20)
        contact.addTarget(self, action: #selector(contactTapped), for: .touchUpInside)
        return contact
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .white
        listing.append(currentListing!.destination)
        listing.append(currentListing!.time)
        listing.append(currentListing!.meeting)
        let email = currentListing?.email
        let safeEmail = UserDefaults.standard.string(forKey: "SafeEmail")
        if email == safeEmail && currentListing?.accepted == "No one" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editListing))
        } else if (currentListing?.accepted == "No one" && email != safeEmail) {
            view.addSubview(accept)
        } else {
            if email == safeEmail {
                Database.database().reference().child("Users").child(currentListing!.accepted).observe(.value, with: { [weak self] (snapshot) in
                    guard let strongSelf = self else {
                        return
                    }
                    let dict = snapshot.value as? NSDictionary
                    strongSelf.acceptedBy.text = dict?["name"] as? String ?? "Failed To Retrieve Name"
                    strongSelf.acceptedBy.text? += " accepted your listing"
                })
            } else {
                acceptedBy.text = "You accepted their listing"
            }
            view.addSubview(acceptedBy)
            view.addSubview(contact)
        }
        if email == safeEmail {
            self.title = "You"
        } else {
            Database.database().reference().child("Users").child(currentListing!.email).observe(.value, with: { [weak self] (snapshot) in
                guard let strongSelf = self else {
                    return
                }
                let dict = snapshot.value as? NSDictionary
                let text = dict?["name"] as? String ?? "Failed To Retrieve Name"
                strongSelf.title = text
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        acceptedBy.frame = CGRect(x: 30, y: view.frame.height * 0.8, width: view.frame.width - 60, height: 52)
        accept.frame = CGRect(x: 30, y: view.frame.height * 0.87, width: view.frame.width - 60, height: 52)
        contact.frame = CGRect(x: 30, y: view.frame.height * 0.87, width: view.frame.width - 60, height: 52)
    }
    
    @objc private func acceptTapped() {
        let confirm = UIAlertController(title: "Are you sure?", message: "This action cannot be undone", preferredStyle: .alert)
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
            strongSelf.navigationController?.popToRootViewController(animated: true)
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        confirm.addAction(yes)
        confirm.addAction(no)
        present(confirm, animated: true, completion: nil)
    }
    
    @objc private func contactTapped() {
        if messageComposer.canSendText() {
            let email = currentListing?.email
            let safeEmail = UserDefaults.standard.string(forKey: "SafeEmail")
            if safeEmail == email {
                Database.database().reference().child("Users").child(currentListing!.accepted).observe(.value, with: { [weak self] (snapshot) in
                    guard let strongSelf = self else {
                        return
                    }
                    let mydict = snapshot.value as? NSDictionary
                    let contact = mydict?["phone_number"] as? String ?? "Failed to get phone number"
                    let messageComposeVC = strongSelf.messageComposer.configuredMessageComposeViewController(person: contact)
                    strongSelf.present(messageComposeVC, animated: true, completion: nil)
                })
            } else {
                Database.database().reference().child("Users").child(currentListing!.email).observe(.value, with: { [weak self] (snapshot) in
                    guard let strongSelf = self else {
                        return
                    }
                    let mydict = snapshot.value as? NSDictionary
                    let contact = mydict?["phone_number"] as? String ?? "Failed to get phone number"
                    let messageComposeVC = strongSelf.messageComposer.configuredMessageComposeViewController(person: contact)
                    strongSelf.present(messageComposeVC, animated: true, completion: nil)
                })
            }
        } else {
            let alert = UIAlertController(title: "Error!", message: "Cannot open iMessage", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc private func editListing() {
        let vc = EditListingViewController()
        vc.currentListing = currentListing
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewListingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellView", for: indexPath)
        cell.textLabel?.font = UIFont(name: "PerspectiveSans", size: 20)
        cell.detailTextLabel?.font = UIFont(name: "PerspectiveSans", size: 15)
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        cell.backgroundColor = .clear
        cell.textLabel?.text = listing[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listing.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 1
      }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Destination"
        case 1:
            return "Departure Time/Date"
        case 2:
            return "Meeting location"
        default:
            return nil
        }
    }
}
