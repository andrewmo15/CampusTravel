//
//  ListingsViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListingsViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    var myList = [Listing]()
    var otherList = [Listing]()
    var acceptedList = [Listing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadTable()
    }
    
    private func loadTable() {
        let safeEmail = UserDefaults.standard.object(forKey: "SafeEmail") as? String ?? " "
        Database.database().reference().child("Listings").observe(.value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            if snapshot.childrenCount > 0 {
                strongSelf.otherList.removeAll()
                strongSelf.myList.removeAll()
                for code in snapshot.children.allObjects as! [DataSnapshot] {
                    let listingKey = code.key
                    let listingObject = code.value as? [String: AnyObject]
                    let listingEmail = listingObject?["email"] as! String
                    let listingDestination = listingObject?["destination"] as! String
                    let listingMeeting = listingObject?["meeting_location"] as! String
                    let listingTime = listingObject?["time_date"] as! String
                    
                    let listing = Listing(email: listingEmail, time: listingTime, destination: listingDestination, meeting: listingMeeting, listingID: listingKey, accepted: "No one")
                    if listingEmail == safeEmail {
                        strongSelf.myList.append(listing)
                    } else {
                        strongSelf.otherList.append(listing)
                    }
                }
                strongSelf.table.reloadData()
            }
        })
        Database.database().reference().child("Accepted").observe(.value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            if snapshot.childrenCount > 0 {
                strongSelf.acceptedList.removeAll()
                for code in snapshot.children.allObjects as! [DataSnapshot] {
                    let listingKey = code.key
                    let listingObject = code.value as? [String: AnyObject]
                    let listingEmail = listingObject?["email"] as! String
                    let listingDestination = listingObject?["destination"] as! String
                    let listingMeeting = listingObject?["meeting_location"] as! String
                    let listingTime = listingObject?["time_date"] as! String
                    let listingAccepted = listingObject?["acceptedBy"] as! String
                    
                    if listingEmail == safeEmail || safeEmail == listingAccepted {
                        let listing = Listing(email: listingEmail, time: listingTime, destination: listingDestination, meeting: listingMeeting, listingID: listingKey, accepted: listingAccepted)
                        strongSelf.acceptedList.append(listing)
                    }
                }
            }
            strongSelf.table.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIt" {
            let vc = segue.destination as! ViewListingViewController
            vc.currentListing = sender as? Listing
        }
    }
}

extension ListingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return acceptedList.count
        case 1:
            return myList.count
        case 2:
            return otherList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = acceptedList[indexPath.row].destination
            cell.detailTextLabel?.text = acceptedList[indexPath.row].time
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = myList[indexPath.row].destination
            cell.detailTextLabel?.text = myList[indexPath.row].time
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.textLabel?.text = otherList[indexPath.row].destination
            cell.detailTextLabel?.text = otherList[indexPath.row].time
            cell.accessoryType = .disclosureIndicator
        default:
            cell.textLabel?.text = "Error"
            cell.detailTextLabel?.text = "Something went wrong"
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Accepted Listings"
        case 1:
            return "My Listings"
        case 2:
            return "Other Listings"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let listing = acceptedList[indexPath.row]
            performSegue(withIdentifier: "showIt", sender: listing)
        case 1:
            let listing = myList[indexPath.row]
            performSegue(withIdentifier: "showIt", sender: listing)
        case 2:
            let listing = otherList[indexPath.row]
            performSegue(withIdentifier: "showIt", sender: listing)
        default:
            break
        }
    }
}

struct Listing {
    let email: String
    let time: String
    let destination: String
    let meeting: String
    let listingID: String
    let accepted: String
}
