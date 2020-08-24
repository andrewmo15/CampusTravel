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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        loadTable()
        
    }
    
    private func loadTable() {
        let safeEmail = UserDefaults.standard.object(forKey: "SafeEmail") as? String ?? " "
        Database.database().reference().child("Listings").observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.otherList.removeAll()
                self.myList.removeAll()
                
                for email in snapshot.children.allObjects as! [DataSnapshot] {
                    let listingKey = email.key
                    let listingObject = email.value as? [String: AnyObject]
                    let listingEmail = listingObject?["email"]
                    let listingDestination = listingObject?["destination"]
                    let listingMeeting = listingObject?["meeting_location"]
                    let listingTime = listingObject?["time_date"]
                    
                    let listing = Listing(email: listingEmail as! String, time: listingTime as! String, destination: listingDestination as! String, meeting: listingMeeting as! String, listingID: listingKey)
                    
                    if listingEmail as! String == safeEmail {
                        self.myList.append(listing)
                    } else {
                        self.otherList.append(listing)
                    }
                }
                
                self.table.reloadData()
            }
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
            return myList.count
        case 1:
            return otherList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = myList[indexPath.row].destination
            cell.detailTextLabel?.text = myList[indexPath.row].time
            cell.accessoryType = .disclosureIndicator
        case 1:
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "My Listings"
        case 1:
            return "Other Listings"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let listing = myList[indexPath.row]
            performSegue(withIdentifier: "showIt", sender: listing)
        case 1:
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
}
