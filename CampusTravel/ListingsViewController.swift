//
//  ListingsViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SideMenu

class ListingsViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    var menu: SideMenuNavigationController?
    
    var myList = [Listing]()
    var otherList = [Listing]()
    var acceptedList = [Listing]()
    var expiredList = [Listing]()
    
    private let addListing: UIButton = {
        let accept = UIButton()
        accept.setTitle("Add A Listing!", for: .normal)
        accept.setTitleColor(.white, for: .normal)
        accept.backgroundColor = .link
        accept.layer.cornerRadius = 12
        accept.layer.masksToBounds = true
        accept.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        accept.addTarget(self, action: #selector(addListingTapped), for: .touchUpInside)
        return accept
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(addListing)
        menu = SideMenuNavigationController(rootViewController: MenuListController())
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: false)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        table.delegate = self
        table.dataSource = self
        table.refreshControl = UIRefreshControl()
        table.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        loadTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addListing.frame = CGRect(x: 30, y: view.frame.height * 0.87, width: view.frame.width - 60, height: 52)
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        present(menu!, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadTable()
    }
    
    @objc private func refresh() {
        loadTable()
        DispatchQueue.main.async {
            self.table.refreshControl?.endRefreshing()
        }
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
                    
                    let currentDateTime = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm E, d MMM y"
                    let listingDate = formatter.date(from: listingTime)
                    
                    let listing = Listing(email: listingEmail, time: listingTime, destination: listingDestination, meeting: listingMeeting, listingID: listingKey, accepted: "No one")
                    if (listingDate! < currentDateTime) {
                        strongSelf.expiredList.append(listing)
                    } else if listingEmail == safeEmail {
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
                    
                    let currentDateTime = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm E, d MMM y"
                    let listingDate = formatter.date(from: listingTime)
                    
                    if (listingDate! < currentDateTime) {
                        let listing = Listing(email: listingEmail, time: listingTime, destination: listingDestination, meeting: listingMeeting, listingID: listingKey, accepted: listingAccepted)
                        strongSelf.expiredList.append(listing)
                    } else if listingEmail == safeEmail || safeEmail == listingAccepted {
                        let listing = Listing(email: listingEmail, time: listingTime, destination: listingDestination, meeting: listingMeeting, listingID: listingKey, accepted: listingAccepted)
                        strongSelf.acceptedList.append(listing)
                    }
                }
            }
            strongSelf.table.reloadData()
        })
        clearExpired()
    }
    
    private func clearExpired() {
        for thing in expiredList {
            Database.database().reference().child("Accepted").child(thing.listingID).removeValue()
            Database.database().reference().child("Listings").child(thing.listingID).removeValue()
        }
        expiredList.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIt" {
            let vc = segue.destination as! ViewListingViewController
            vc.currentListing = sender as? Listing
        }
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
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
    
    @objc private func addListingTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "adder")
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
