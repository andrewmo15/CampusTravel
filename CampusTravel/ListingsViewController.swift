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
    
    var list = [Listing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        loadTable()
        
    }
    
    private func loadTable() {
        Database.database().reference().child("Listings").observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.list.removeAll()
                
                for email in snapshot.children.allObjects as! [DataSnapshot] {
                    let listingObject = email.value as? [String: AnyObject]
                    let listingEmail = listingObject?["email"]
                    let listingDestination = listingObject?["destination"]
                    let listingMeeting = listingObject?["meeting_location"]
                    let listingTime = listingObject?["time_date"]
                    
                    let listing = Listing(email: listingEmail as! String, time: listingTime as! String, destination: listingDestination as! String, meeting: listingMeeting as! String)
                    
                    self.list.append(listing)
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
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].destination
        cell.detailTextLabel?.text = list[indexPath.row].time
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let listing = list[indexPath.row]
        performSegue(withIdentifier: "showIt", sender: listing)
    }
}

struct Listing {
    let email: String
    let time: String
    let destination: String
    let meeting: String
}
