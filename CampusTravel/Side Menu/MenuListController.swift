//
//  MenuListController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 8/26/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SafariServices
import FirebaseAuth

class MenuListController: UITableViewController {
    
    private var items = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items.removeAll()
        tableView.backgroundColor = UIColor(red: 33 / 255.0, green: 33 / 255.0, blue: 33 / 255.0, alpha: 1)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell2")
        items.append("Welcome " + (UserDefaults.standard.string(forKey: "Name") ?? "Failed to Retrieve Name") + "!")
        items.append(UserDefaults.standard.string(forKey: "Email") ?? "Failed to Retrieve Email")
        items.append(UserDefaults.standard.string(forKey: "Phone") ?? "Failed to Retrieve Phone")
        items.append(" ")
        items.append("Edit Profile")
        items.append("About")
        items.append("Tutorial")
        items.append("Sign Out")
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        items.removeAll()
        items.append("Welcome " + (UserDefaults.standard.string(forKey: "Name") ?? "Failed to Retrieve Name") + "!")
        items.append(UserDefaults.standard.string(forKey: "Email") ?? "Failed to Retrieve Email")
        items.append(UserDefaults.standard.string(forKey: "Phone") ?? "Failed to Retrieve Phone")
        items.append(" ")
        items.append("Edit Profile")
        items.append("About")
        items.append("Tutorial")
        items.append("Sign Out")
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 125
        default:
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.font = UIFont(name: "PerspectiveSansBlack", size: 30)
        } else {
            cell.textLabel?.font = UIFont(name: "PerspectiveSans", size: 20)
        }
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.numberOfLines = 3
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        if indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7 {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }
        if indexPath.row == 7 {
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 4:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "edit")
            vc.modalPresentationStyle = .automatic
            present(vc, animated: true)
        case 5:
            showSafariVC(for: "https://github.com/andrewmo15/GTTravel")
        case 6:
            let page = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            page.modalPresentationStyle = .fullScreen
            present(page, animated: true)
        case 7:
            let confirm = UIAlertController(title: "Are You Sure?", message: "Do you want to sign out?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
                guard let strongSelf = self else {
                    return
                }
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    strongSelf.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                } catch {
                    let alert = UIAlertController(title: "Error!", message: "Failed to sign out", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    strongSelf.present(alert, animated: true)
                }
            }
            let no = UIAlertAction(title: "No", style: .default, handler: nil)
            confirm.addAction(yes)
            confirm.addAction(no)
            present(confirm, animated: true, completion: nil)
        default:
            break
        }
    }
    
    private func showSafariVC(for url: String) {
        guard let url = URL(string: url) else {
            let alert = UIAlertController(title: "Error!", message: "Could not open Safari", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
