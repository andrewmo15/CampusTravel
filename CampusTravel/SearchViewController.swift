//
//  SearchViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 9/7/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var myList: [Listing]?
    var otherList: [Listing]?
    var acceptedList: [Listing]?
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var search: UISearchBar!
    
    var myFiltered = [Listing]()
    var otherFiltered = [Listing]()
    var acceptedFiltered = [Listing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        table.backgroundColor = .white
        search.barTintColor = .white
        search.delegate = self
        table.delegate = self
        table.dataSource = self
        search.placeholder = "Search for a listing"
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        myFiltered.removeAll()
        otherFiltered.removeAll()
        acceptedFiltered.removeAll()
        for listing in myList! {
            if listing.destination.lowercased().contains(searchText.lowercased()) {
                myFiltered.append(listing)
            }
        }
        for listing in otherList! {
            if listing.destination.lowercased().contains(searchText.lowercased()) {
                otherFiltered.append(listing)
            }
        }
        for listing in acceptedList! {
            if listing.destination.lowercased().contains(searchText.lowercased()) {
                acceptedFiltered.append(listing)
            }
        }
        table.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIt2" {
            let vc = segue.destination as! ViewListingViewController
            vc.currentListing = sender as? Listing
        }
    }

}
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return acceptedFiltered.count
        case 1:
            return myFiltered.count
        case 2:
            return otherFiltered.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "PerspectiveSans", size: 20)
        cell.detailTextLabel?.font = UIFont(name: "PerspectiveSans", size: 15)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        cell.backgroundColor = .clear
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = acceptedFiltered[indexPath.row].destination
            cell.detailTextLabel?.text = acceptedFiltered[indexPath.row].time
        case 1:
            cell.textLabel?.text = myFiltered[indexPath.row].destination
            cell.detailTextLabel?.text = myFiltered[indexPath.row].time
        case 2:
            cell.textLabel?.text = otherFiltered[indexPath.row].destination
            cell.detailTextLabel?.text = otherFiltered[indexPath.row].time
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
            let listing = acceptedFiltered[indexPath.row]
            performSegue(withIdentifier: "showIt2", sender: listing)
        case 1:
            let listing = myFiltered[indexPath.row]
            performSegue(withIdentifier: "showIt2", sender: listing)
        case 2:
            let listing = otherFiltered[indexPath.row]
            performSegue(withIdentifier: "showIt2", sender: listing)
        default:
            break
        }
    }
}
