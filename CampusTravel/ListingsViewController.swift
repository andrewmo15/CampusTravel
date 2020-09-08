//
//  ListingsViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/23/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SideMenu

class ListingsViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    var menu: SideMenuNavigationController?
    var myList = [Listing]()
    var otherList = [Listing]()
    var acceptedList = [Listing]()
    var expiredList = [Listing]()
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var search: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavController()
        menu = SideMenuNavigationController(rootViewController: MenuListController())
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: false)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        table.delegate = self
        table.dataSource = self
        table.refreshControl = UIRefreshControl()
        table.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        table.backgroundColor = .white
        loadTable()
        if UserDefaults.standard.integer(forKey: "HowTo") == 1 {
            UserDefaults.standard.set(0, forKey: "HowTo")
            let page = PageViewController()
            page.modalPresentationStyle = .fullScreen
            present(page, animated: true)
        }
        configureAdd()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        configureNavController()
        view.backgroundColor = .white
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
        if UserDefaults.standard.integer(forKey: "HowTo") == 1 {
            UserDefaults.standard.set(0, forKey: "HowTo")
            let page = PageViewController()
            page.modalPresentationStyle = .fullScreen
            present(page, animated: true)
        }
        configureAdd()
    }
    
    private func configureNavController() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PerspectiveSansBlack", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PerspectiveSansBlack", size: 35)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(red: 42 / 255.0, green: 168 / 255.0, blue: 242 / 255.0, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    private func configureAdd() {
        add.frame = CGRect(x: view.frame.width - 100, y: view.frame.height - 120, width: 80, height: 80)
        add.layer.cornerRadius = 40
        add.layer.masksToBounds = true
        add.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
    }
    
    @IBAction func didTapMenu(_ sender: Any) {
        present(menu!, animated: true)
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
                    formatter.dateFormat = "E, MM/dd/yyyy, h:mm a"
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
                strongSelf.clearExpired()
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
                    formatter.dateFormat = "E, MM/dd/yyyy, h:mm a"
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
            strongSelf.clearExpired()
            strongSelf.table.reloadData()
        })
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
        if segue.identifier == "showSearch" {
            let vc = segue.destination as! SearchViewController
            vc.myList = myList
            vc.acceptedList = acceptedList
            vc.otherList = otherList
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
        cell.textLabel?.font = UIFont(name: "PerspectiveSans", size: 20)
        cell.detailTextLabel?.font = UIFont(name: "PerspectiveSans", size: 15)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = acceptedList[indexPath.row].destination
            cell.detailTextLabel?.text = acceptedList[indexPath.row].time
        case 1:
            cell.textLabel?.text = myList[indexPath.row].destination
            cell.detailTextLabel?.text = myList[indexPath.row].time
        case 2:
            cell.textLabel?.text = otherList[indexPath.row].destination
            cell.detailTextLabel?.text = otherList[indexPath.row].time
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
    var email: String
    var time: String
    var destination: String
    var meeting: String
    var listingID: String
    var accepted: String
}
